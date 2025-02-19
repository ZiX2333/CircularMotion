function [sbd,iDropAll] = BehaviorAnaM(Datax)
% This code is used for behavior analysis
% Behavior Ana Monkey
% input Datax, output is behavior data (sbd, saccade behavior data)
% I'm going to make sbd a table variable

% Created on Feb 7, 2025, Xuan, Analysis basic saccade info

%% Basic Component, Reaction time and so on
sbd.SacAmpGoc1 = NaN(size(Datax,1),1); % first saccade amplitude
sbd.SacRTGoc1 = NaN(size(Datax,1),1); % first saccade reaction time
sbd.SacDurGoc1 = NaN(size(Datax,1),1); % first saccade duration time
sbd.SacSTmGoc1 = NaN(size(Datax,1),1); % first saccade start time
sbd.SacETmGoc1 = NaN(size(Datax,1),1); % frist saccade end time
sbd.SacPvelGoc1 = NaN(size(Datax,1),1); % first saccade peak velocity
sbd.SacPvelTmGoc1 = NaN(size(Datax,1),1); % first saccade peak velocity time
sbd.SacDurGoc12 = NaN(size(Datax,1),1); % duration between frist saccade and second saccade
sbd.SmPLVelGoc1 = NaN(size(Datax,1),3); % linear velocity [50ms, 120ms]/[120ms, 200ms]/[200ms, 300ms] after the first sacc
sbd.SmPAVelGoc1 = NaN(size(Datax,1),3); % Angular velocity [50ms, 120ms]/[120ms, 200ms]/[200ms, 300ms] after the first sacc
sbd.SacTraGoc1 = cell(size(Datax,1),1); % Saccade Trajectory
sbd.SacTraGoc11 = cell(size(Datax,1),1); % Saccade Trajectory front minus 1 and back plus 1
sbd = struct2table(sbd);

iDropA = []; % Drops for blinks or All other issues for the first saccade after gocue

for iTrial = 1:size(Datax,1)
    if isempty(Datax.SacLocGoc2{iTrial})
        iDropA = [iDropA, iTrial];
        continue
    end
    % X, Y, THeta, Rho, Disp, Acc Disp
    % Datax Goc2 means the second saccade after gocue, sbd Goc1 means the
    % first saccade after gocue... this is silly why I did that...
    sbd.SacAmpGoc1(iTrial) = Datax.SacLocGoc2{iTrial}{1}(4,end) - Datax.SacLocGoc2{iTrial}{1}(4,1);
    sbd.SacRTGoc1(iTrial) = Datax.SacTimeGoc2{iTrial}(4,1);
    sbd.SacDurGoc1(iTrial) = Datax.SacTimeGoc2{iTrial}(3,1);
    sbd.SacSTmGoc1(iTrial) = Datax.SacTimeGoc2{iTrial}(1,1);
    sbd.SacETmGoc1(iTrial) = Datax.SacTimeGoc2{iTrial}(2,1);
    sbd.SacPvelGoc1(iTrial) = Datax.SacPvelGoc2{iTrial}(1,1);
    sbd.SacPvelTmGoc1(iTrial) = Datax.SacPvelGoc2{iTrial}(2,1);
    sbd.SacTraGoc1{iTrial} = Datax.SacLocGoc2{iTrial}{1}';
    sbd.SacTraGoc11{iTrial} = Datax.EyeLoc{iTrial}(:,(sbd.SacSTmGoc1(iTrial)-1):(sbd.SacETmGoc1(iTrial)+1))';
    % make the trajectory into pi, wrapToPi
    sbd.SacTraGoc1{iTrial}(:,3) = wrapToPi(sbd.SacTraGoc1{iTrial}(:,3));
    sbd.SacTraGoc11{iTrial}(:,3) = wrapToPi(sbd.SacTraGoc11{iTrial}(:,3));

    % for Blink:
    if max(sbd.SacTraGoc1{iTrial}(:,4))>30
        iDropA = [iDropA,iTrial];
    end
end

% calculate the smooth pursuit speed

%% calculate target location at different time point
sbd.TargVel = NaN(size(Datax,1),1); % Target velocity
sbd.TargPath = cell(size(Datax,1),1); % target path
sbd.TargTime = cell(size(Datax,1),1); % target time, 80ms before saccade, saccade onset, saccade offset
% this is to save different target location at different check point
sbd.TargLocCheckP = cell(size(Datax,1),1);
sbd.TargLocCheckPAtcp = cell(size(Datax,1),1); % at different check point but compensate the frame lag

iDropB = []; % collect trials without target traj

for iTrial = 1:size(Datax,1)
    sbd.TargVel(iTrial) = deg2rad(Datax.TargVel(iTrial));
    if isempty(Datax.T1LocReal{iTrial})
        iDropB = [iDropB,iTrial];
        continue
    else
        sbd.TargPath{iTrial}(:,1:4) = Datax.T1LocReal{iTrial}; %X Y Theta Rho
        % wrap to pi
        sbd.TargPath{iTrial}(:,3) = wrapToPi(sbd.TargPath{iTrial}(:,3));
        sbd.TargTime{iTrial}(:,1) = Datax.T1TimeReal{iTrial}; % Time
    end
    % time difference: 80ms before saccade on, saccade on, saccade off
    sbd.TargTime{iTrial}(:,2) = sbd.TargTime{iTrial}(:,1) - (sbd.SacSTmGoc1(iTrial)-80);
    sbd.TargTime{iTrial}(:,3) = sbd.TargTime{iTrial}(:,1) - sbd.SacSTmGoc1(iTrial);
    sbd.TargTime{iTrial}(:,4) = sbd.TargTime{iTrial}(:,1) - sbd.SacETmGoc1(iTrial);

    % find the target location, always find the closest frame
    for iCol = 2:size(sbd.TargTime{iTrial},2)
        TargLocCheckP = []; TargLocCheckPAtcp = [];
        [~, TminIdx] = min(abs(sbd.TargTime{iTrial}(:,iCol))); % find the min value index
        TDiff = sbd.TargTime{iTrial}(TminIdx,iCol); % find the value
        % save the target location at the check point
        TargLocCheckP = sbd.TargPath{iTrial}(TminIdx,1:4);
        sbd.TargLocCheckP{iTrial}(iCol-1,:) = TargLocCheckP;
        % X, Y, THeta, Rho, save the target location at check p with frame lag compensation
        TargLocCheckPAtcp(3) = TargLocCheckP(3) - wrapToPi(TDiff*(sbd.TargVel(iTrial)/1000));
        TargLocCheckPAtcp(4) = TargLocCheckP(4); % radius shouldn't change
        [TargLocCheckPAtcp(1),TargLocCheckPAtcp(2)] = pol2cart (TargLocCheckPAtcp(3),TargLocCheckPAtcp(4));
        sbd.TargLocCheckPAtcp{iTrial}(iCol-1,:) = TargLocCheckPAtcp;
    end
end

%% calculate the saccadic ending error with target location at saccade off, fix Point center
sbd.SacEndXY = NaN(size(Datax,1),2); % record the ending location
sbd.SacEndTR = NaN(size(Datax,1),2);
sbd.SacIniXY = NaN(size(Datax,1),2); % record the initial location
sbd.SacIniTR = NaN(size(Datax,1),2);
sbd.SacEndErrX = NaN(size(Datax,1),1);
sbd.SacEndErrY = NaN(size(Datax,1),1);
sbd.SacEndErrAng2C = NaN(size(Datax,1),1); % centered on center point
sbd.SacEndErrAng2CSign = NaN(size(Datax,1),1);
sbd.SacEndErrRho = NaN(size(Datax,1),1); % radius ending error

iDropC = []; % for too large ending error
for iTrial = 1:size(Datax,1)
    if isempty(Datax.SacLocGoc2{iTrial}) || isempty(Datax.T1LocReal{iTrial})
        continue
    end
    SacEndLoc = [];
    SacIniLoc = [];
    TimeS = [];
    TimeE = [];
    % X, Y, Theta, Rho, Disp, AccDisp
    % saccade end location, 3 ms range, [-1,1]
    SacEndLoc = mean(sbd.SacTraGoc11{iTrial}(end-2:end,1:2)); % 3 ms range, [-1,1]
    sbd.SacEndXY(iTrial,1:2) = SacEndLoc; % record the ending location
    [SacEndLoc(3),SacEndLoc(4)] = cart2pol(SacEndLoc(1),SacEndLoc(2));
    sbd.SacEndTR(iTrial,1:2) = [wrapToPi(SacEndLoc(3));SacEndLoc(4)];

    % saccade ini location, 3 ms range, [-1,1]
    SacIniLoc = mean(sbd.SacTraGoc11{iTrial}(1:3,1:2)); % to target ending location, 3ms[-1,1]
    sbd.SacIniXY(iTrial,1:2) = SacIniLoc; % record the initial location
    [SacIniLoc(3),SacIniLoc(4)] = cart2pol(SacIniLoc(1),SacIniLoc(2));
    sbd.SacIniTR(iTrial,1:2) = [wrapToPi(SacIniLoc(3));SacIniLoc(4)];

    % Now calculate the ending error
    sbd.SacEndErrX(iTrial) = SacEndLoc(1) - sbd.TargLocCheckPAtcp{iTrial}(end,1);
    sbd.SacEndErrY(iTrial) = SacEndLoc(2) - sbd.TargLocCheckPAtcp{iTrial}(end,2);
    sbd.SacEndErrAng2C(iTrial) = wrapToPi(SacEndLoc(3)-sbd.TargLocCheckPAtcp{iTrial}(end,3));

    % Sign the location
    if sbd.TargVel < 0 % CW reverse direction
        sbd.SacEndErrAng2CSign(iTrial) = -sbd.SacEndErrAng2C(iTrial);
    else
        sbd.SacEndErrAng2CSign(iTrial) = sbd.SacEndErrAng2C(iTrial);
    end

    [~, sbd.SacEndErrRho2C(iTrial)] = cart2pol(sbd.SacEndErrX(iTrial),sbd.SacEndErrY(iTrial));
    % detect Ending err too large
    if abs(sbd.SacEndErrRho2C(iTrial)) >=10
        iDropC = [iDropC,iTrial];
    end
end

%% Calculate saccade ending error to eye center
sbd.SacEndXY2E = NaN(size(Datax,1),2); % record the ending location with eye center
sbd.SacEndTR2E = NaN(size(Datax,1),2);
sbd.SacIniXY2E = NaN(size(Datax,1),2); % record the initial location with eye center
sbd.SacIniTR2E = NaN(size(Datax,1),2);
% saccade trajectory to eye center
sbd.SacTraGoc2E1 = cell(size(Datax,1),1); %2E to the eye initial location
sbd.SacTraGoc2E11 = cell(size(Datax,1),1); %2E to the eye initial location with +- 1 at the back and front
% record the target location with eye center
sbd.TargLocCheckP2E = cell(size(Datax,1),1);
sbd.TargLocCheckPAtcp2E = cell(size(Datax,1),1);
sbd.TargLocSacEndTR2E = NaN(size(Datax,1),2); % record target location at saccade end specificlly
sbd.TargLocSacEndAtcpTR2E = NaN(size(Datax,1),2);
% saccade ending error
sbd.SacEndErrAng2E = NaN(size(Datax,1),1);
sbd.SacEndErrAng2ESign = NaN(size(Datax,1),1);


for iTrial  = 1:size(Datax,1)
    if isempty(Datax.SacLocGoc2{iTrial}) || isempty(Datax.T1LocReal{iTrial})
        continue
    end
    EyeLocGoc = []; % whole eye traces
    EyeLocGoc1 = []; % whole eye traces with +- 1 at the initial and the end
    % sbd.EyeCartGoc2Zero = []; % whole eye traces (X-Y location) relative to zero point
    % EyePolrGoc2Zero = []; % whole eye traces (theta and rho)
    SacIniLoc = []; % Saccade Initial location
    SacEndLoc = []; % saccade end location
    % rows: X, Y, Theta, Rho, Disp, AccDisp, VelX, VelY, VelRho, don't need
    % velocity mark
    EyeLocGoc = sbd.SacTraGoc1{iTrial};
    EyeLocGoc1 = sbd.SacTraGoc11{iTrial};
    SacIniLoc = sbd.SacIniXY(iTrial,1:2);
    SacEndLoc = sbd.SacEndXY(iTrial,1:2);

    % write saccade trajectory
    sbd.SacTraGoc2E1{iTrial} = EyeLocGoc(:,1:2) - SacIniLoc(1:2);
    [sbd.SacTraGoc2E1{iTrial}(:,3),sbd.SacTraGoc2E1{iTrial}(:,4)] = ...
        cart2pol(sbd.SacTraGoc2E1{iTrial}(:,1),sbd.SacTraGoc2E1{iTrial}(:,2));
    sbd.SacTraGoc2E11{iTrial} = EyeLocGoc1(:,1:2) - SacIniLoc(1:2);
    [sbd.SacTraGoc2E11{iTrial}(:,3),sbd.SacTraGoc2E11{iTrial}(:,4)] = ...
        cart2pol(sbd.SacTraGoc2E11{iTrial}(:,1),sbd.SacTraGoc2E11{iTrial}(:,2));

    sbd.SacEndXY2E(iTrial,1:2) = mean(sbd.SacTraGoc2E11{iTrial}(end-2:end,1:2)); % 3 ms range, [-1,1]
    [sbd.SacEndTR2E(iTrial,1),sbd.SacEndTR2E(iTrial,2)] = cart2pol(sbd.SacEndXY2E(iTrial,1),sbd.SacEndXY2E(iTrial,2));

    sbd.SacIniXY2E(iTrial,1:2) = mean(sbd.SacTraGoc2E11{iTrial}(1:3,1:2)); % 3 ms range, [-1,1]
    [sbd.SacIniTR2E(iTrial,1),sbd.SacIniTR2E(iTrial,2)] = cart2pol(sbd.SacIniXY2E(iTrial,1),sbd.SacIniXY2E(iTrial,2));

    % write target location at diff check points to E
    for iRow = 1:size(sbd.TargLocCheckP{iTrial},1)
        sbd.TargLocCheckP2E{iTrial}(iRow,1:2) = sbd.TargLocCheckP{iTrial}(iRow,1:2) - SacIniLoc(1:2);
        [sbd.TargLocCheckP2E{iTrial}(iRow,3),sbd.TargLocCheckP2E{iTrial}(iRow,4)] = ...
            cart2pol(sbd.TargLocCheckP2E{iTrial}(iRow,1),sbd.TargLocCheckP2E{iTrial}(iRow,2));
        sbd.TargLocCheckPAtcp2E{iTrial}(iRow,1:2) = sbd.TargLocCheckPAtcp{iTrial}(iRow,1:2) - SacIniLoc(1:2);
        [sbd.TargLocCheckPAtcp2E{iTrial}(iRow,3),sbd.TargLocCheckPAtcp2E{iTrial}(iRow,4)] = ...
            cart2pol(sbd.TargLocCheckPAtcp2E{iTrial}(iRow,1),sbd.TargLocCheckPAtcp2E{iTrial}(iRow,2));
    end

    sbd.TargLocSacEndTR2E(iTrial,:) = sbd.TargLocCheckP2E{iTrial}(end,3:4);
    sbd.TargLocSacEndAtcpTR2E(iTrial,:) = sbd.TargLocCheckPAtcp2E{iTrial}(end,3:4);

    % write the eye direction difference
    sbd.SacEndErrAng2E(iTrial) = wrapToPi(sbd.SacEndTR2E(iTrial,1)-sbd.TargLocCheckPAtcp2E{iTrial}(end,3));
    % Sign the location
    if sbd.TargVel < 0 % CW reverse direction
        sbd.SacEndErrAng2ESign(iTrial) = -sbd.SacEndErrAng2E(iTrial);
    else
        sbd.SacEndErrAng2ESign(iTrial) = sbd.SacEndErrAng2E(iTrial);
    end
end

iDropAll = unique([iDropA,iDropB,iDropC]);

end




% end