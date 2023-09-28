function [sbd,Dataf1,iDrop4,trialNum] = BehaviorAna(Dataf1,GocC)

% This code here is for behavior analysis
% input dataf1, output is behavior data, adjusted dataf1 and dropped data
% and related trial number
% first edition on Sep 14 2023, Xuan

%% Basic Component, Reaction time and so on
sbd.SacAmpGoc1 = zeros(size(Dataf1));
sbd.SacEndGoc1 = zeros(size(Dataf1));
sbd.SacDurGoc1 = zeros(size(Dataf1));
sbd.SacRTGoc1 = zeros(size(Dataf1));
sbd.SacSTmGoc1 = zeros(size(Dataf1));
sbd.SacETmGoc1 = zeros(size(Dataf1));
sbd.SacPvelGoc1 = zeros(size(Dataf1));
sbd.SacEAngGoc1 = zeros(size(Dataf1));

for iTrial = 1:size(Dataf1,2)
    % X, Y, Rho, Theta, Disp, Acc Disp
    sbd.SacAmpGoc1(iTrial) = Dataf1(iTrial).SacLocGoc1(3,2) - Dataf1(iTrial).SacLocGoc1(3,1);
    sbd.SacEndGoc1(iTrial) = Dataf1(iTrial).SacLocGoc1(3,2);
    sbd.SacEAngGoc1(iTrial) = Dataf1(iTrial).SacLocGoc1(4,2);
    % STime, ETime, Dur, RT
    sbd.SacSTmGoc1(iTrial) = Dataf1(iTrial).SacTimeGoc1(1);
    sbd.SacETmGoc1(iTrial) = Dataf1(iTrial).SacTimeGoc1(2);
    sbd.SacDurGoc1(iTrial) = Dataf1(iTrial).SacTimeGoc1(3);
    sbd.SacRTGoc1(iTrial) = Dataf1(iTrial).SacTimeGoc1(4);
    sbd.SacPvelGoc1(iTrial) = Dataf1(iTrial).SacPvelGoc1;
    % get the mean acc disp velocity after 70ms of saccade offset, 50ms range
    sbd.SmPVelGoc1(iTrial) = mean(Dataf1(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+70:sbd.SacETmGoc1(iTrial)+120));
end

%% Calculate saccade ending error (by radius distance and angular) with target loc at sac offset
% centered on target

% find the nearest frame to the event time
% always find the first frame before the time
for iTrial = 1:size(Dataf1,2)
    % align to 100ms before Saccade onset
    Dataf1(iTrial).TarPathXReal(3,:) = Dataf1(iTrial).TarPathXReal(2,:) - (sbd.SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf1(iTrial).TarPathXReal(4,:) = Dataf1(iTrial).TarPathXReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf1(iTrial).TarPathXReal(5,:) = Dataf1(iTrial).TarPathXReal(2,:) - sbd.SacETmGoc1(iTrial);
    % align to gocue onset
    Dataf1(iTrial).TarPathXReal(6,:) = Dataf1(iTrial).TarPathXReal(2,:) - Dataf1(iTrial).TimeGocOn;

    % align to 100ms before Saccade onset
    Dataf1(iTrial).TarPathYReal(3,:) = Dataf1(iTrial).TarPathYReal(2,:) - (sbd.SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf1(iTrial).TarPathYReal(4,:) = Dataf1(iTrial).TarPathYReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf1(iTrial).TarPathYReal(5,:) = Dataf1(iTrial).TarPathYReal(2,:) - sbd.SacETmGoc1(iTrial);
    % align to gocue onset
    Dataf1(iTrial).TarPathYReal(6,:) = Dataf1(iTrial).TarPathYReal(2,:) - Dataf1(iTrial).TimeGocOn;

    % align to 100ms before Saccade onset
    Dataf1(iTrial).TarPathAngReal(3,:) = Dataf1(iTrial).TarPathAngReal(2,:) - (sbd.SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf1(iTrial).TarPathAngReal(4,:) = Dataf1(iTrial).TarPathAngReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf1(iTrial).TarPathAngReal(5,:) = Dataf1(iTrial).TarPathAngReal(2,:) - sbd.SacETmGoc1(iTrial);
    % align to gocue onset
    Dataf1(iTrial).TarPathAngReal(6,:) = Dataf1(iTrial).TarPathAngReal(2,:) - Dataf1(iTrial).TimeGocOn;

    % find the target location, always find the first frame before the time
    % each row: 100ms before saccade onset, saccade onset, saccade offset,
    % gocue onset
    for iRow = 3:6
        iCom = find(Dataf1(iTrial).TarPathXReal(iRow,:) == ...
            max(Dataf1(iTrial).TarPathXReal(iRow,Dataf1(iTrial).TarPathXReal(iRow,:)<=0)));
        % X Y location need to transefer to visual degree
        Dataf1(iTrial).SacTarGoc1(iRow-2,:) = ...
            [(Dataf1(iTrial).TarPathXReal(1,iCom) - Dataf1(iTrial).center(1))/Dataf1(iTrial).ppd(1),...
            (Dataf1(iTrial).TarPathYReal(1,iCom) - Dataf1(iTrial).center(2))/Dataf1(iTrial).ppd(2),...
            Dataf1(iTrial).TarPathAngReal(1,iCom)];
    end
end

sbd.SacEndErrX = zeros(size(Dataf1));
sbd.SacEndErrY = zeros(size(Dataf1));
sbd.SacEndErrAng2Tar = zeros(size(Dataf1)); % centered on Target
sbd.SacEndErrRho = zeros(size(Dataf1)); % centered on Target
sbd.SacEndErrRhoSign1 = zeros(size(Dataf1)); % left and right sign
sbd.SacEndErrRhoSign2 = zeros(size(Dataf1)); % up and down sign (overshoot or undershoot)
sbd.SacEndErrAng = zeros(size(Dataf1)); % centered on center point
sbd.SacEndErrAngSign1 = zeros(size(Dataf1));

iDrop4 = []; % for too large ending error
trialNum = []; % collect drop trial number
for iTrial = 1:size(Dataf1,2)
    SacEndLoc = [];
    TimeS = [];
    TimeE = [];
    % X, Y, Rho, Theta, Disp, AccDisp
    SacEndLoc = Dataf1(iTrial).SacLocGoc1(:,2);
    sbd.SacEndErrX(iTrial) = SacEndLoc(1) - Dataf1(iTrial).SacTarGoc1(3,1);
    sbd.SacEndErrY(iTrial) = SacEndLoc(2) - Dataf1(iTrial).SacTarGoc1(3,2);
    [sbd.SacEndErrAng2Tar(iTrial),sbd.SacEndErrRho(iTrial)] = cart2pol(sbd.SacEndErrX(iTrial),sbd.SacEndErrY(iTrial));
    sbd.SacEndErrAng(iTrial) = wrapToPi(SacEndLoc(4)-Dataf1(iTrial).SacTarGoc1(3,3));

    % the sbd.SacEndErrRho is the distance, doesn't have location information
    % if I want to know whether the target is at the right or left location
    % of the target, I'm going to add a sign on it:left negative, right
    % Positive
    % left:
    % addjust to lag behind is negative, go to future is positive
    % if wrapToPi(SacEndLoc(4)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) > deg2rad(90) && rem(Dataf1(iTrial).TarDir+1,2) == 0
    %     sbd.SacEndErrRhoSign1(iTrial) = +sbd.SacEndErrRho(iTrial);
    % elseif wrapToPi(SacEndLoc(4)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) <= deg2rad(90) && rem(Dataf1(iTrial).TarDir+1,2) == 0
    %     sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
    % elseif wrapToPi(SacEndLoc(4)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) >= deg2rad(90) && rem(Dataf1(iTrial).TarDir+1,2) == 1
    %     sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
    % elseif wrapToPi(SacEndLoc(4)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) < deg2rad(90) && Dataf1(iTrial).TarDir == 1
    %     sbd.SacEndErrRhoSign1(iTrial) = sbd.SacEndErrRho(iTrial);
    % end
    % [1,     2,    3,     4,    5,     6,    7] trialtype = tardir+1
    % [0,     1     2      3     4      5     6] tardir
    % [Sta, ccw15, cw15, ccw30, cw30, ccw45, cw45]
    if wrapToPi(SacEndLoc(4)) > wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)) && rem(Dataf1(iTrial).TarDir+1,2) == 0
        sbd.SacEndErrRhoSign1(iTrial) = +sbd.SacEndErrRho(iTrial);
        sbd.SacEndErrAngSign1(iTrial) = +sbd.SacEndErrAng(iTrial);
    elseif wrapToPi(SacEndLoc(4)) <= wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)) && rem(Dataf1(iTrial).TarDir+1,2) == 0
        sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
        sbd.SacEndErrAngSign1(iTrial) = +sbd.SacEndErrAng(iTrial);
    elseif wrapToPi(SacEndLoc(4)) >= wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)) && rem(Dataf1(iTrial).TarDir+1,2) == 1
        sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
        sbd.SacEndErrAngSign1(iTrial) = -sbd.SacEndErrAng(iTrial);
    elseif wrapToPi(SacEndLoc(4)) < wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)) && rem(Dataf1(iTrial).TarDir+1,2) == 1
        sbd.SacEndErrRhoSign1(iTrial) = +sbd.SacEndErrRho(iTrial);
        sbd.SacEndErrAngSign1(iTrial) = -sbd.SacEndErrAng(iTrial);
    end



    % the sbd.SacEndErrRho is the distance, doesn't have undershoot or
    % overshoot info
    % if I need to calculate the overshoot or undershoot info, I need to
    % include amplitude information
    if Dataf1(iTrial).SacLocGoc1(3,2) > Dataf1(iTrial).TarEcc % overshoot
        sbd.SacEndErrRhoSign2(iTrial) = sbd.SacEndErrRho(iTrial);
    else
        sbd.SacEndErrRhoSign2(iTrial) = -sbd.SacEndErrRho(iTrial);
    end

    % delete Ending err too large
    if abs(sbd.SacEndErrRho(iTrial)) >=5
        iDrop4 = [iDrop4,iTrial];
        trialNum = [trialNum,Dataf1(iTrial).TrialNumAll];
    end

end

%% Calculate the dynamic saccade relation with the target location at saccade offset
% Anglular error between saccade initial direction and ending direction

% SacDynErrX = zeros(size(Dataf1)); % Saccade Dynamic Error X
% SacDynErrY = zeros(size(Dataf1)); % Saccade Dynamic Error Y
sbd.EyeCartGoc2Z = cell(size(Dataf1)); %2Z = 2 zero
sbd.EyePolrGocTan = cell(size(Dataf1)); % tangent angular
sbd.TarPolrGoc2Z = cell(size(Dataf1)); % align target location at saccade end to saccade ini lac
sbd.SacDynErrAngTan = cell(size(Dataf1)); % Saccade Dynamic angular Error
sbd.SacIniErrAngTan = zeros(size(Dataf1));
sbd.SacEndErrAngTan = zeros(size(Dataf1));
sbd.SacIniErrAngTanSign = zeros(size(Dataf1));
sbd.SacEndErrAngTanSign = zeros(size(Dataf1));
% SacDynErrRho = zeros(size(Dataf1)); % Saccade Dynamic Radius Error

for iTrial = 1:size(Dataf1,2)
    EyeLocGoc = []; % whole eye traces
    % sbd.EyeCartGoc2Zero = []; % whole eye traces (X-Y location) relative to zero point
    % EyePolrGoc2Zero = []; % whole eye traces (theta and rho)
    SacIniLoc = []; % Saccade Initial location
    SacEndLoc = []; % saccade end location
    TimeS = [];
    TimeE = [];
    TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
    TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
    % rows: X, Y, Rho, Theta, Disp, AccDisp, VelX, VelY, VelRho, don't need
    % velocity mark
    EyeLocGoc = Dataf1(iTrial).EyeLocRGoc(1:9,TimeS:TimeE);
    SacIniLoc = Dataf1(iTrial).EyeLocRGoc(1:9,TimeS);
    SacEndLoc = Dataf1(iTrial).SacLocGoc1(:,2);
    sbd.EyeCartGoc2Z{iTrial} = EyeLocGoc(1:2,:) - SacIniLoc(1:2,1);

    [sbd.TarPolrGoc2Z{iTrial}(1),sbd.TarPolrGoc2Z{iTrial}(2)] = ...
        cart2pol(Dataf1(iTrial).SacTarGoc1(3,1)-SacIniLoc(1,1),Dataf1(iTrial).SacTarGoc1(3,2)-SacIniLoc(2,1));
    % sbd.EyeCartGoc2Z{iTrial} = EyeLocGoc(1:2,1) - EyeLocGoc(1:2,1:end-1);

    % atan2(y,x)
    sbd.EyePolrGocTan{iTrial} = atan2(EyeLocGoc(8,:),EyeLocGoc(7,:));
    sbd.SacDynErrAngTan{iTrial}  = wrapToPi(sbd.EyePolrGocTan{iTrial} - sbd.TarPolrGoc2Z{iTrial}(1));

    sbd.SacIniErrAngTan(iTrial) = sbd.SacDynErrAngTan{iTrial}(10);
    sbd.SacEndErrAngTan(iTrial) = sbd.SacDynErrAngTan{iTrial}(end);

    if wrapToPi(SacEndLoc(4)) > wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)) && rem(Dataf1(iTrial).TarDir+1,2) == 0
        sbd.SacIniErrAngTanSign(iTrial) = +sbd.SacIniErrAngTan(iTrial);
        sbd.SacEndErrAngTanSign(iTrial) = +sbd.SacEndErrAngTan(iTrial);
    elseif wrapToPi(SacEndLoc(4)) <= wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)) && rem(Dataf1(iTrial).TarDir+1,2) == 0
        sbd.SacIniErrAngTanSign(iTrial) = +sbd.SacIniErrAngTan(iTrial);
        sbd.SacEndErrAngTanSign(iTrial) = +sbd.SacEndErrAngTan(iTrial);
    elseif wrapToPi(SacEndLoc(4)) >= wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)) && rem(Dataf1(iTrial).TarDir+1,2) == 1
        sbd.SacIniErrAngTanSign(iTrial) = -sbd.SacIniErrAngTan(iTrial);
        sbd.SacEndErrAngTanSign(iTrial) = -sbd.SacEndErrAngTan(iTrial);
    elseif wrapToPi(SacEndLoc(4)) < wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)) && rem(Dataf1(iTrial).TarDir+1,2) == 1
        sbd.SacIniErrAngTanSign(iTrial) = -sbd.SacIniErrAngTan(iTrial);
        sbd.SacEndErrAngTanSign(iTrial) = -sbd.SacEndErrAngTan(iTrial);
    end
end

end

