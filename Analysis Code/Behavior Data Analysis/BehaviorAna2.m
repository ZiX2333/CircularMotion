function [sbd,Dataf,iDrop4,trialNum] = BehaviorAna(Dataf,iniT)

% This code here is for behavior analysis
% input dataf1, output is behavior data, adjusted dataf1 and dropped data
% and related trial number
% first edition on Sep 14 2023, Xuan
% second edition on Sep 28 2023, Xuan
    % Contain 3 parts: Saccade Para, Sac Ending Error, Sac Dynamic relation
    % with target location
% Third edition on Oct 6 2023, Xuan
    % add curvature analysis
% Fourth edition on Feb 12 Xuan
    % add align intial location
% Fifth edition on Feb 20 Xuan
    % added target location align to saccade initial
% Sixth edition on Feb 24 Xuan
    % adjust the order of theta and R (used to be R and theta)
% Seven edition on Feb 27 Xuan
    % Initially create NaN matrix

%% Basic Component, Reaction time and so on
% for the first saccade after gocue
sbd.SacAmpGoc1 = NaN(size(Dataf)); % first saccade amplitude
sbd.SacRTGoc1 = NaN(size(Dataf)); % first saccade reaction time
sbd.SacDurGoc1 = NaN(size(Dataf)); % first saccade duration time
sbd.SacSTmGoc1 = NaN(size(Dataf)); % first saccade start time
sbd.SacETmGoc1 = NaN(size(Dataf)); % frist saccade end time
sbd.SacPvelGoc1 = NaN(size(Dataf)); % first saccade peak velocity
sbd.SacPvelTmGoc1 = NaN(size(Dataf)); % first saccade peak velocity time
sbd.SacDurGoc12 = NaN(size(Dataf)); % duration between frist saccade and second saccade
sbd.SmPVelGoc1 = NaN(size(Dataf)); % velocity between first saccade and second saccade, +30ms to -30ms
sbd.SacTraGoc1 = cell(size(Dataf)); % Saccade Trajectory

for iTrial = 1:size(Dataf,2)
    if isempty(Dataf(iTrial).SacLocGoc2)
        continue
    end
    % X, Y, Theta, Rho, Disp, Acc Disp
    sbd.SacAmpGoc1(iTrial) = Dataf(iTrial).SacLocGoc2{1}(4,end) - Dataf(iTrial).SacLocGoc2{1}(4,1);
    sbd.SacRTGoc1(iTrial) = Dataf(iTrial).SacTimeGoc2(4,1);
    sbd.SacDurGoc1(iTrial) = Dataf(iTrial).SacTimeGoc2(3,1);
    sbd.SacSTmGoc1(iTrial) = Dataf(iTrial).SacTimeGoc2(1,1);
    sbd.SacETmGoc1(iTrial) = Dataf(iTrial).SacTimeGoc2(2,1);
    sbd.SacPvelGoc1(iTrial) = Dataf(iTrial).SacPvelGoc2(1,1);
    sbd.SacPvelTmGoc1(iTrial) = Dataf(iTrial).SacPvelGoc2(2,1);
    if size(Dataf(iTrial).SacTimeGoc2,2) >1 %if have second saccade
        sbd.SacDurGoc12(iTrial) = Dataf(iTrial).SacTimeGoc2(1,2)- Dataf(iTrial).SacTimeGoc2(2,1);
        % get the mean acc disp velocity after 30ms of first saccade offset,
        % 30ms before second saccade onset
        if sbd.SacDurGoc12(iTrial) >=70
            sbd.SmPVelGoc1(iTrial) = mean(Dataf(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+30:Dataf(iTrial).SacTimeGoc2(1,2)-30));
        else
            sbd.SmPVelGoc1(iTrial) = nan;
        end
    else % if doesn't have second saccade
        sbd.SacDurGoc12(iTrial) = 0;
        sbd.SmPVelGoc1(iTrial) = mean(Dataf(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+30:end));
    end
    sbd.SacTraGoc1{iTrial} = Dataf(iTrial).SacLocGoc2{1};
end

%% Calculate saccade ending error (by radius distance and angular) with target loc at sac offset
% centered on target

% find the nearest frame to the event time
% always find the first frame before the time
for iTrial = 1:size(Dataf,2)
    if isempty(Dataf(iTrial).SacLocGoc2)
        continue
    end
    % align to gocue onset
    Dataf(iTrial).TarPathXReal(3,:) = Dataf(iTrial).TarPathXReal(2,:) - Dataf(iTrial).TimeGocOn;
    % align to 100ms before Saccade onset
    Dataf(iTrial).TarPathXReal(4,:) = Dataf(iTrial).TarPathXReal(2,:) - (sbd.SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf(iTrial).TarPathXReal(5,:) = Dataf(iTrial).TarPathXReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf(iTrial).TarPathXReal(6,:) = Dataf(iTrial).TarPathXReal(2,:) - sbd.SacETmGoc1(iTrial);

    % align to gocue onset
    Dataf(iTrial).TarPathYReal(3,:) = Dataf(iTrial).TarPathYReal(2,:) - Dataf(iTrial).TimeGocOn;
    % align to 100ms before Saccade onset
    Dataf(iTrial).TarPathYReal(4,:) = Dataf(iTrial).TarPathYReal(2,:) - (sbd.SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf(iTrial).TarPathYReal(5,:) = Dataf(iTrial).TarPathYReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf(iTrial).TarPathYReal(6,:) = Dataf(iTrial).TarPathYReal(2,:) - sbd.SacETmGoc1(iTrial);

    % align to gocue onset
    Dataf(iTrial).TarPathAngReal(3,:) = Dataf(iTrial).TarPathAngReal(2,:) - Dataf(iTrial).TimeGocOn;
    % align to 100ms before Saccade onset
    Dataf(iTrial).TarPathAngReal(4,:) = Dataf(iTrial).TarPathAngReal(2,:) - (sbd.SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf(iTrial).TarPathAngReal(5,:) = Dataf(iTrial).TarPathAngReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf(iTrial).TarPathAngReal(6,:) = Dataf(iTrial).TarPathAngReal(2,:) - sbd.SacETmGoc1(iTrial);

    sbd.TarPath{iTrial}(1,:) = (Dataf(iTrial).TarPathXReal(1,:) - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1); %X
    sbd.TarPath{iTrial}(2,:) = (Dataf(iTrial).TarPathYReal(1,:) - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2); %Y
    [sbd.TarPath{iTrial}(3,:),sbd.TarPath{iTrial}(4,:)] = cart2pol(sbd.TarPath{iTrial}(1,:),sbd.TarPath{iTrial}(2,:)); % Theta & R
    sbd.TarPath{iTrial}(5,:) = Dataf(iTrial).TarPathXReal(2,:); % Time

    % find the target location, always find the first frame before the time
    % for some trials there is no first frame before the trial, find the
    % closed frame
    % each row: 100ms before saccade onset, saccade onset, saccade offset,
    % gocue onset
    for iRow = 3:6
        try
            iCom = find(Dataf(iTrial).TarPathXReal(iRow,:) == ...
                max(Dataf(iTrial).TarPathXReal(iRow,Dataf(iTrial).TarPathXReal(iRow,:)<=0)));
        catch
            iCom = find(Dataf(iTrial).TarPathXReal(iRow,:) == ...
                min(Dataf(iTrial).TarPathXReal(iRow,Dataf(iTrial).TarPathXReal(iRow,:)>=0)));
        end
        % X Y location need to transefer to visual degree
        Dataf(iTrial).SacTarGoc1(iRow-2,:) = ...
            [(Dataf(iTrial).TarPathXReal(1,iCom) - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1),...
            (Dataf(iTrial).TarPathYReal(1,iCom) - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2),...
            Dataf(iTrial).TarPathAngReal(1,iCom)];
    end
end

sbd.SacEndErrX = NaN(size(Dataf));
sbd.SacEndErrY = NaN(size(Dataf));
sbd.SacEndErrAng2Tar = NaN(size(Dataf)); % centered on Target
sbd.SacEndErrRho = NaN(size(Dataf)); % centered on Target
sbd.SacEndErrRhoSign1 = NaN(size(Dataf)); % left and right sign
sbd.SacEndErrRhoSign2 = NaN(size(Dataf)); % up and down sign (overshoot or undershoot)
sbd.SacEndErrAng2C = NaN(size(Dataf)); % centered on center point
sbd.SacEndErrAng2CSign1 = NaN(size(Dataf));

iDrop4 = []; % for too large ending error
trialNum = []; % collect drop trial number
for iTrial = 1:size(Dataf,2)
    if isempty(Dataf(iTrial).SacLocGoc2)
        continue
    end
    SacEndLoc = [];
    SacIniLoc = [];
    TimeS = [];
    TimeE = [];
    % X, Y, Theta, Rho, Disp, AccDisp
    SacEndLoc = sbd.SacTraGoc1{iTrial}(:,end);
    SacIniLoc = sbd.SacTraGoc1{iTrial}(:,1); % to target ending location
    sbd.SacEndErrX(iTrial) = SacEndLoc(1) - Dataf(iTrial).SacTarGoc1(end,1);
    sbd.SacEndErrY(iTrial) = SacEndLoc(2) - Dataf(iTrial).SacTarGoc1(end,2);
    [sbd.SacEndErrAng2Tar(iTrial),sbd.SacEndErrRho(iTrial)] = cart2pol(sbd.SacEndErrX(iTrial),sbd.SacEndErrY(iTrial));
    sbd.SacEndErrAng2C(iTrial) = wrapToPi(SacEndLoc(3)-Dataf(iTrial).SacTarGoc1(end,3));
    % the sbd.SacEndErrRho is the distance, doesn't have location information
    % if I want to know whether the target is at the right or left location
    % of the target, I'm going to add a sign on it:left negative, right
    % Positive
    % left:
    % addjust to lag behind is negative, go to future is positive
    % if wrapToPi(SacEndLoc(3)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) > deg2rad(90) && rem(Dataf1(iTrial).TarDir+1,2) == 0
    %     sbd.SacEndErrRhoSign1(iTrial) = +sbd.SacEndErrRho(iTrial);
    % elseif wrapToPi(SacEndLoc(3)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) <= deg2rad(90) && rem(Dataf1(iTrial).TarDir+1,2) == 0
    %     sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
    % elseif wrapToPi(SacEndLoc(3)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) >= deg2rad(90) && rem(Dataf1(iTrial).TarDir+1,2) == 1
    %     sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
    % elseif wrapToPi(SacEndLoc(3)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) < deg2rad(90) && Dataf1(iTrial).TarDir == 1
    %     sbd.SacEndErrRhoSign1(iTrial) = sbd.SacEndErrRho(iTrial);
    % end
    % [1,     2,    3,     4,    5,     6,    7] trialtype = tardir+1
    % [0,     1     2      3     4      5     6] tardir
    % [Sta, ccw15, cw15, ccw30, cw30, ccw45, cw45]
    if wrapToPi(SacEndLoc(3)) > wrapToPi(Dataf(iTrial).SacTarGoc1(end,3)) && rem(Dataf(iTrial).TarDir+1,2) == 0
        sbd.SacEndErrRhoSign1(iTrial) = +sbd.SacEndErrRho(iTrial);
        sbd.SacEndErrAng2CSign1(iTrial) = +sbd.SacEndErrAng2C(iTrial);
    elseif wrapToPi(SacEndLoc(3)) <= wrapToPi(Dataf(iTrial).SacTarGoc1(end,3)) && rem(Dataf(iTrial).TarDir+1,2) == 0
        sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
        sbd.SacEndErrAng2CSign1(iTrial) = +sbd.SacEndErrAng2C(iTrial);
    elseif wrapToPi(SacEndLoc(3)) >= wrapToPi(Dataf(iTrial).SacTarGoc1(end,3)) && rem(Dataf(iTrial).TarDir+1,2) == 1
        sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
        sbd.SacEndErrAng2CSign1(iTrial) = -sbd.SacEndErrAng2C(iTrial);
    elseif wrapToPi(SacEndLoc(3)) < wrapToPi(Dataf(iTrial).SacTarGoc1(end,3)) && rem(Dataf(iTrial).TarDir+1,2) == 1
        sbd.SacEndErrRhoSign1(iTrial) = +sbd.SacEndErrRho(iTrial);
        sbd.SacEndErrAng2CSign1(iTrial) = -sbd.SacEndErrAng2C(iTrial);
    end
    % the sbd.SacEndErrRho is the distance, doesn't have undershoot or
    % overshoot info
    % if I need to calculate the overshoot or undershoot info, I need to
    % include amplitude information
    if Dataf(iTrial).SacLocGoc2{1}(4,end) > Dataf(iTrial).TarEcc % overshoot
        sbd.SacEndErrAng2CSign2(iTrial) = sbd.SacEndErrRho(iTrial);
    else
        sbd.SacEndErrAng2CSign2(iTrial) = -sbd.SacEndErrRho(iTrial);
    end
    % detect Ending err too large
    if abs(sbd.SacEndErrRho(iTrial)) >=5
        iDrop4 = [iDrop4,iTrial];
        trialNum = [trialNum,Dataf(iTrial).TrialNumAll];
    end
end

%% Calculate the dynamic saccade relation with the target location at saccade offset
% all of the saccade mentioned below are the first saccade after gocue
% Anglular error between saccade initial direction and ending direction
% iniT = 10; checked initial time, maybe 10ms

% SacDynErrX = NaN(size(Dataf1)); % Saccade Dynamic Error X
% SacDynErrY = NaN(size(Dataf1)); % Saccade Dynamic Error Y
sbd.EyeCartGoc2E = cell(size(Dataf)); %2E to the eye initial location
sbd.EyePolrGoc2E = cell(size(Dataf)); %2E to the eye initial location
sbd.TarPolrGocEnd2E = cell(size(Dataf)); % align target location at saccade end to saccade ini lac
sbd.EyePolrGocTan = cell(size(Dataf)); % tangent angular
sbd.SacDynErrAngTan = cell(size(Dataf)); % Saccade Dynamic angular Error
sbd.SacIniErrAngTan = NaN(size(Dataf));
sbd.SacEndErrAngTan = NaN(size(Dataf));
sbd.SacIniErrAngTanSign = NaN(size(Dataf));
sbd.SacEndErrAngTanSign = NaN(size(Dataf));
sbd.SacIniDir = NaN(size(Dataf)); % Saccade initial direction at 10ms
sbd.SacAllDir = NaN(size(Dataf)); % Saccade Overall direction
sbd.SacCurPara1 = NaN(size(Dataf)); % first curvature parameters: All dir - Ini Dir
% SacDynErrRho = NaN(size(Dataf1)); % Saccade Dynamic Radius Error

for iTrial = 1:size(Dataf,2)
    if isempty(Dataf(iTrial).SacLocGoc2)
        continue
    end
    EyeLocGoc = []; % whole eye traces
    % sbd.EyeCartGoc2Zero = []; % whole eye traces (X-Y location) relative to zero point
    % EyePolrGoc2Zero = []; % whole eye traces (theta and rho)
    SacIniLoc = []; % Saccade Initial location
    SacEndLoc = []; % saccade end location
    TimeS = [];
    TimeE = [];
    TimeS = sbd.SacSTmGoc1(iTrial);
    TimeE = sbd.SacETmGoc1(iTrial);
    % rows: X, Y, Rho, Theta, Disp, AccDisp, VelX, VelY, VelRho, don't need
    % velocity mark
    EyeLocGoc = sbd.SacTraGoc1{iTrial};
    SacIniLoc = EyeLocGoc(:,1);
    SacEndLoc = EyeLocGoc(:,end);
    sbd.EyeCartGoc2E{iTrial} = EyeLocGoc(1:2,:) - SacIniLoc(1:2);
    [sbd.EyePolrGoc2E{iTrial}(1,:),sbd.EyePolrGoc2E{iTrial}(2,:)] = ...
        cart2pol(sbd.EyeCartGoc2E{iTrial}(1,:),sbd.EyeCartGoc2E{iTrial}(2,:));

    [sbd.TarPolrGocEnd2E{iTrial}(1),sbd.TarPolrGocEnd2E{iTrial}(2)] = ...
        cart2pol(Dataf(iTrial).SacTarGoc1(end,1)-SacIniLoc(1,1),Dataf(iTrial).SacTarGoc1(end,2)-SacIniLoc(2,1));
    sbd.TarPath2E{iTrial}(1,:) = sbd.TarPath{iTrial}(1,:) - SacIniLoc(1,1); % x location
    sbd.TarPath2E{iTrial}(2,:) = sbd.TarPath{iTrial}(2,:) - SacIniLoc(2,1); % y location
    [sbd.TarPath2E{iTrial}(3,:),sbd.TarPath2E{iTrial}(4,:)] = ...
        cart2pol(sbd.TarPath2E{iTrial}(1,:),sbd.TarPath2E{iTrial}(2,:)); % theta and r location
    sbd.TarPath2E{iTrial}(5,:) = sbd.TarPath{iTrial}(5,:); % time
    % sbd.EyeCartGoc2E{iTrial} = EyeLocGoc(1:2,1) - EyeLocGoc(1:2,1:end-1);
    

    % atan2(y,x) % velocity y and velocity x
    % need to find a new way to calculate this
    sbd.EyePolrGocTan{iTrial} = atan2(EyeLocGoc(8,:),EyeLocGoc(7,:));
    sbd.SacDynErrAngTan{iTrial}  = wrapToPi(sbd.EyePolrGocTan{iTrial} - sbd.TarPolrGocEnd2E{iTrial}(1));
    
    if iniT >= sbd.SacDurGoc1(iTrial)
        sbd.SacIniErrAngTan(iTrial) = nan;
        sbd.SacEndErrAngTan(iTrial) = nan;
    else
        sbd.SacIniErrAngTan(iTrial) = sbd.SacDynErrAngTan{iTrial}(iniT);
        sbd.SacEndErrAngTan(iTrial) = sbd.SacDynErrAngTan{iTrial}(end);
        if wrapToPi(SacEndLoc(3)) > wrapToPi(Dataf(iTrial).SacTarGoc1(end,3)) && rem(Dataf(iTrial).TarDir+1,2) == 0
            sbd.SacIniErrAngTanSign(iTrial) = +sbd.SacIniErrAngTan(iTrial);
            sbd.SacEndErrAngTanSign(iTrial) = +sbd.SacEndErrAngTan(iTrial);
        elseif wrapToPi(SacEndLoc(3)) <= wrapToPi(Dataf(iTrial).SacTarGoc1(end,3)) && rem(Dataf(iTrial).TarDir+1,2) == 0
            sbd.SacIniErrAngTanSign(iTrial) = +sbd.SacIniErrAngTan(iTrial);
            sbd.SacEndErrAngTanSign(iTrial) = +sbd.SacEndErrAngTan(iTrial);
        elseif wrapToPi(SacEndLoc(3)) >= wrapToPi(Dataf(iTrial).SacTarGoc1(end,3)) && rem(Dataf(iTrial).TarDir+1,2) == 1
            sbd.SacIniErrAngTanSign(iTrial) = -sbd.SacIniErrAngTan(iTrial);
            sbd.SacEndErrAngTanSign(iTrial) = -sbd.SacEndErrAngTan(iTrial);
        elseif wrapToPi(SacEndLoc(3)) < wrapToPi(Dataf(iTrial).SacTarGoc1(end,3)) && rem(Dataf(iTrial).TarDir+1,2) == 1
            sbd.SacIniErrAngTanSign(iTrial) = -sbd.SacIniErrAngTan(iTrial);
            sbd.SacEndErrAngTanSign(iTrial) = -sbd.SacEndErrAngTan(iTrial);
        end

        sbd.SacIniDir(iTrial) = wrapToPi(sbd.EyePolrGoc2E{iTrial}(1,iniT)); % Saccade initial direction
        sbd.SacAllDir(iTrial) = wrapToPi(sbd.EyePolrGoc2E{iTrial}(1,end)); % Saccade Overall direction
        sbd.SacCurPara1(iTrial) = wrapToPi(sbd.SacAllDir(iTrial)-sbd.SacIniDir(iTrial));
    end

end

%% move the eye trace to have all same initial location
% sbd.EyeLocMovXY = cell(1,size(Dataf,2));
% sbd.EyeLocMovPol = cell(1,size(Dataf,2));
sbd.EyeLocRttPol = cell(1,size(Dataf,2));

for iTrial = 1:size(Dataf,2)
    if isempty(Dataf(iTrial).SacLocGoc2)
        continue
    end
    EyeLoc = [];
    EyeLocRtt = [];
    EyeLocMovPol = [];
    EyeLocMovX = [];
    EyeLocMovY = [];
    EyeLoc = sbd.SacTraGoc1{iTrial};
    EyeLocMovX = EyeLoc(1,:) - EyeLoc(1,1); % Move X location to center
    EyeLocMovY = EyeLoc(2,:) - EyeLoc(2,1); % Move Y location to center
    [EyeLocMovPol(1,:),EyeLocMovPol(2,:)] = cart2pol(EyeLocMovX,EyeLocMovY); % to [-Pi, Pi]
    EyeLocRtt = wrapToPi(EyeLocMovPol(1,:) - sbd.SacIniDir(iTrial));

    % sbd.EyeLocMovXY{iTrial} = [EyeLocMovX;EyeLocMovY];
    % sbd.EyeLocMovPol{iTrial} = EyeLocMovPol;
    sbd.EyeLocRttPol{iTrial} = [EyeLocRtt;EyeLocMovPol(2,:)];
end

%% Calculate the Saccade Curvature mor component
sbd.SacMaxCurSize_PPD = NaN(size(Dataf)); % use prependicular distance method to calculate
sbd.SacMaxCurTime_PPD = NaN(size(Dataf)); % Saccade Maxium curvatue duration
sbd.SacMaxCurTra1_PPD = cell(size(Dataf)); % Saccade tarce befor maximum curvature
sbd.SacMaxCurTra2_PPD = cell(size(Dataf)); % Saccade tarce after maximum curvature
sbd.EyePolrGoc2E1_PPD = cell(size(Dataf)); % Saccade polar eye trace to Eye, befor maximum curvature
sbd.EyePolrGoc2E2_PPD = cell(size(Dataf)); % Saccade polar eye trace to Eye, after maximum curvature
sbd.EyeCartGoc2E1_PPD = cell(size(Dataf)); % Saccade Cart eye trace to Eye, befor maximum curvature
sbd.EyeCartGoc2E2_PPD = cell(size(Dataf)); % Saccade Cart eye trace to Eye, befor maximum curvature
sbd.SacMaxCurAllDir1_PPD = NaN(size(Dataf)); % from initial to max direction
sbd.SacMaxCurAllDir2_PPD = NaN(size(Dataf)); % from max direction to ending
sbd.SacMaxCurDir_PPD = NaN(size(Dataf));

for iTrial = 1:size(Dataf,2)
    if isempty(Dataf(iTrial).SacLocGoc2)
        continue
    end
    EyeLocGoc = []; % whole eye traces
    % sbd.EyeCartGoc2Zero = []; % whole eye traces (X-Y location) relative to zero point
    % EyePolrGoc2Zero = []; % whole eye traces (theta and rho)
    SacIniLoc = []; % Saccade Initial location
    SacEndLoc = []; % saccade end location
    TimeS = [];
    TimeE = [];
    TimeS = sbd.SacSTmGoc1(iTrial);
    TimeE = sbd.SacETmGoc1(iTrial);
    % rows: X, Y, Rho, Theta, Disp, AccDisp, VelX, VelY, VelRho, don't need
    % velocity mark
    EyeLocGoc = sbd.SacTraGoc1{iTrial};
    SacIniLoc = EyeLocGoc(:,1);
    SacEndLoc = EyeLocGoc(:,end);

    % Calculate the equation of the line segment formed by trace 1
    a = SacIniLoc(2) - SacEndLoc(2);
    b = SacEndLoc(1) - SacIniLoc(1);
    c = SacIniLoc(1) * SacEndLoc(2) - SacEndLoc(1) * SacIniLoc(2);

    % Loop through each point in trace2 and calculate perpendicular distances
    for i = 1:size(EyeLocGoc,2)
        x2 = EyeLocGoc(1,i);
        y2 = EyeLocGoc(2,i);

        % Calculate perpendicular distance to the line segment
        perpendicular_distance(i) = abs(a * x2 + b * y2 + c) / sqrt(a^2 + b^2);
    end

    sbd.SacMaxCurSize_PPD(iTrial) = max(perpendicular_distance);
    MaxLoc = find(perpendicular_distance == max(perpendicular_distance));
    sbd.SacMaxCurTime_PPD(iTrial) = MaxLoc;

end

end

