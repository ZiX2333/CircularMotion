function [sbd,DatafN,iDrop4] = BehaviorAna(DatafN)
iniT = 5;
% This code here is for behavior analysis
% input dataf1, output is behavior data, adjusted dataf1 and dropped data
% and related trial number
% DatafN is a specific Dataf that used in function (cause Dataf is global)
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
% Eight edition on Feb 29 Xuan
    % Add target location more content
% Ninth edition on Mar 21 Xuan
    % edited the ending error calculation. Initial and ending location: the
    % first three
% Ten edition on May 13 Xuan
    % add the de-stationary-trend ending error calculation
% 11th edition on July 22
    % Edited the ending error calculation on how to get the initial and
    % ending location: [-1,1]
    % Add the KDE analysis for Sacc end to eye center
% 12th edition on July 24
    % Add the Grouping order output in the normalization/ compare to stationary
    % part
% 13th edition on Aug 09
    % Add the de-stationary-trend ending error calculation with x axis the
    % saccade location
% 14th edition on Aug 12
    % Adjust the smooth pursuit calculation method
    % before is velocity between first saccade and second saccade, +30ms to -30ms
    % between 50ms to 120ms
% 15th edition on Aug 19
    % I'm going to check target location at different time, right now I'm
    % interested in target location at saccade offset, saccade onset, 100ms
    % before saccade onset, or 80ms, 60, 40, 20 before saccade onset
    % And I also add the predicted target location
% 16th edition on Aug 19
    % I changed all the ending error calculation related to target
    % predicted location. Basically all the DatafN.SacTarGoc1 to DatafN.SacTarGoc1Atcp
    % Remove the de-stationary trend 2C, remove the 2C sign1 cause I don't
    % know what I'm doing in that codes
% 17th edition on Aug 22
    % I added the angular velocity calculation of smooth pursuit
% 18th edition on Sep 18
    % Label the iDrop4, add the RT ZScore
% 19th edition on Sep 20
    % add the target displace calculation during RT in Two ways: RT * speed
    % or Target end - target sacc on
% 20th edition on Mar 04 2025
    % a big change on how I store the de-stationary-trend data, all
    % PPL_DataAna before version 25 should use BehaviorAna8
    % add velocity traces
% 21st edition on Apr 08 2025
    % de trend the RT to stationary data
% 22nd edition on Jul 02 2025
    % add the angular speed to linear speed
% 23rd edition on Jul 16 2025
    % add zero mean of the ending error fo each condition and combined condition

%% Basic Component, Reaction time and so on
% for the first saccade after gocue
sbd.SacAmpGoc1 = NaN(size(DatafN)); % first saccade amplitude
sbd.SacRTGoc1 = NaN(size(DatafN)); % first saccade reaction time
sbd.SacDurGoc1 = NaN(size(DatafN)); % first saccade duration time
sbd.SacSTmGoc1 = NaN(size(DatafN)); % first saccade start time
sbd.SacETmGoc1 = NaN(size(DatafN)); % frist saccade end time
sbd.SacPvelGoc1 = NaN(size(DatafN)); % first saccade peak velocity
sbd.SacPvelTmGoc1 = NaN(size(DatafN)); % first saccade peak velocity time
sbd.SacDurGoc12 = NaN(size(DatafN)); % duration between frist saccade and second saccade
sbd.SmPLVelAllGoc1 = NaN(size(DatafN,2),500); % smooth pursuit velocity 500ms after saccade
sbd.SmPLAccAllGoc1 = NaN(size(DatafN,2),500); % smooth pursuit velocity 500ms after saccade
sbd.SmPA2LVelAllGoc1 = NaN(size(DatafN,2),500); % angular 2 linear smooth pursuit velocity 500ms after saccade
sbd.SmPA2LAccAllGoc1 = NaN(size(DatafN,2),500); % angular 2 linear smooth pursuit Accleration 500ms after saccade
preSacPurLen = 200;
sbd.AngVelGov1 = cell(size(DatafN)); % recalculate the angular velcotiy
sbd.SmPLVelAllGoc0 = NaN(size(DatafN,2),preSacPurLen); % smooth pursuit velocity 300ms before saccade, end as sacc on
sbd.SmPLAccAllGoc0 = NaN(size(DatafN,2),preSacPurLen); % smooth pursuit velocity 300ms before saccade
sbd.SmPLVelGoc1 = NaN(3,size(DatafN,2)); % linear velocity [50ms, 120ms]/[120ms, 200ms]/[200ms, 300ms] after the first sacc
sbd.SmPAVelGoc1 = NaN(3,size(DatafN,2)); % Angular velocity [50ms, 120ms]/[120ms, 200ms]/[200ms, 300ms] after the first sacc
sbd.SacTraGoc1 = cell(size(DatafN)); % Saccade Trajectory
sbd.SacTraGoc11 = cell(size(DatafN)); % Saccade Trajectory front minus 1 and back plus 1
iDropA = []; % for blinks
for iTrial = 1:size(DatafN,2)
    if isempty(DatafN(iTrial).SacLocGoc2)
        continue
    end
    % X, Y, Theta, Rho, Disp, Acc Disp
    sbd.SacAmpGoc1(iTrial) = DatafN(iTrial).SacLocGoc2{1}(4,end) - DatafN(iTrial).SacLocGoc2{1}(4,1);
    sbd.SacRTGoc1(iTrial) = DatafN(iTrial).SacTimeGoc2(4,1);
    sbd.SacDurGoc1(iTrial) = DatafN(iTrial).SacTimeGoc2(3,1);
    sbd.SacSTmGoc1(iTrial) = DatafN(iTrial).SacTimeGoc2(1,1);
    sbd.SacETmGoc1(iTrial) = DatafN(iTrial).SacTimeGoc2(2,1);
    sbd.SacPvelGoc1(iTrial) = DatafN(iTrial).SacPvelGoc2(1,1);
    sbd.SacPvelTmGoc1(iTrial) = DatafN(iTrial).SacPvelGoc2(2,1);
    sbd.SacTraGoc1{iTrial} = DatafN(iTrial).SacLocGoc2{1};
    sbd.SacTraGoc11{iTrial} = DatafN(iTrial).EyeLocR(:,(sbd.SacSTmGoc1(iTrial)-1):(sbd.SacETmGoc1(iTrial)+1));
    
    % calculate saccade angular velocity
    AngLoc = DatafN(iTrial).EyeLocR(3,:);
    sbd.AngVelGov1{iTrial} = zeros(size(DatafN(iTrial).EyeRTime));
    for iTime = 3: length(sbd.AngVelGov1{iTrial})-2
        sbd.AngVelGov1{iTrial}(iTime) = (angle(exp(1i*(AngLoc(iTime+2) - AngLoc(iTime-2)))) +...
            angle(exp(1i*(AngLoc(iTime+1) - AngLoc(iTime-1)))))/6 * 1000;
    end

    % calculate post-saccade pursuit vel
    if sbd.SacETmGoc1(iTrial)+500 <= length(DatafN(iTrial).EyeLocRVel(6,:))
        sbd.SmPLVelAllGoc1(iTrial,:) = DatafN(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+1:sbd.SacETmGoc1(iTrial)+500);
        sbd.SmPLAccAllGoc1(iTrial,:) = DatafN(iTrial).EyeLocRAcc(6,sbd.SacETmGoc1(iTrial)+1:sbd.SacETmGoc1(iTrial)+500)*1000;
        % calculate for the radius velocity transfer to angular velocity
        % linear speed to r*ang vel
        sbd.SmPA2LVelAllGoc1(iTrial,:) = sbd.AngVelGov1{iTrial}(sbd.SacETmGoc1(iTrial)+1:sbd.SacETmGoc1(iTrial)+500)...
            .*DatafN(iTrial).EyeLocR(4,sbd.SacETmGoc1(iTrial)+1:sbd.SacETmGoc1(iTrial)+500);
        SmPA2LAccAllGoc1 = diff(sbd.SmPA2LVelAllGoc1(iTrial,:))*1000;
        SmPA2LAccAllGoc1 = [SmPA2LAccAllGoc1,SmPA2LAccAllGoc1(end)];
        sbd.SmPA2LAccAllGoc1(iTrial,:) = SmPA2LAccAllGoc1;
    else
        sbd.SmPLVelAllGoc1(iTrial,1:length(DatafN(iTrial).EyeLocRAcc(6,:))-(sbd.SacETmGoc1(iTrial))) = ...
            DatafN(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+1:end);
        sbd.SmPLAccAllGoc1(iTrial,1:length(DatafN(iTrial).EyeLocRAcc(6,:))-(sbd.SacETmGoc1(iTrial))) = ...
            DatafN(iTrial).EyeLocRAcc(6,sbd.SacETmGoc1(iTrial)+1:end)*1000;
        % calculate for the radius velocity transfer to angular velocity
        % linear speed to r*ang vel
        sbd.SmPA2LVelAllGoc1(iTrial,1:length(DatafN(iTrial).EyeLocRAcc(6,:))-(sbd.SacETmGoc1(iTrial))) = ...
            sbd.AngVelGov1{iTrial}(sbd.SacETmGoc1(iTrial)+1:end).*DatafN(iTrial).EyeLocR(4,sbd.SacETmGoc1(iTrial)+1:end);
        SmPA2LAccAllGoc1 = diff(sbd.SmPA2LVelAllGoc1(iTrial,1:length(DatafN(iTrial).EyeLocRAcc(6,:))-(sbd.SacETmGoc1(iTrial))))*1000;
        SmPA2LAccAllGoc1 = [SmPA2LAccAllGoc1,SmPA2LAccAllGoc1(end)];
        sbd.SmPA2LAccAllGoc1(iTrial,1:length(DatafN(iTrial).EyeLocRAcc(6,:))-(sbd.SacETmGoc1(iTrial))) = SmPA2LAccAllGoc1;
    end
    % calculate pre-saccade pursuit vel, ignore 0 delay trials
    if ~isnan(DatafN(iTrial).TimeGocOn)
        if sbd.SacSTmGoc1(iTrial)-preSacPurLen >= DatafN(iTrial).TimeGocOn
            sbd.SmPLVelAllGoc0(iTrial,:) = DatafN(iTrial).EyeLocRVel(6,sbd.SacSTmGoc1(iTrial)-preSacPurLen:sbd.SacSTmGoc1(iTrial)-1);
            sbd.SmPLAccAllGoc0(iTrial,:) = DatafN(iTrial).EyeLocRAcc(6,sbd.SacSTmGoc1(iTrial)-preSacPurLen:sbd.SacSTmGoc1(iTrial)-1)*1000;
        else
            sbd.SmPLVelAllGoc0(iTrial,preSacPurLen-sbd.SacRTGoc1(iTrial)+1:end) = ...
                DatafN(iTrial).EyeLocRVel(6,sbd.SacSTmGoc1(iTrial)-sbd.SacRTGoc1(iTrial):sbd.SacSTmGoc1(iTrial)-1);
            sbd.SmPLAccAllGoc0(iTrial,preSacPurLen-sbd.SacRTGoc1(iTrial)+1:end) = ...
                DatafN(iTrial).EyeLocRAcc(6,sbd.SacSTmGoc1(iTrial)-sbd.SacRTGoc1(iTrial):sbd.SacSTmGoc1(iTrial)-1)*1000;
        end
    end
    % find Blink:
    if max(sbd.SacTraGoc1{iTrial}(4,:))>30
        iDropA = [iDropA,iTrial];
    end
end

AccThrs = 8000; % set the Acc threshold at 8000 deg/s^2
VelThrs = 15; %deg/sec
DurThrs = 10; % 10 ms
VelAvd = 100;
% assgin the smooth pursuit value
for iTrial = 1:size(DatafN,2)
    sbd.SmPLVelAllGoc1(iTrial,:) = ...
        F_SmPDeSacc(sbd.SmPLVelAllGoc1(iTrial,:),sbd.SmPLAccAllGoc1(iTrial,:),DurThrs,VelThrs,AccThrs,VelAvd);
    sbd.SmPLVelAllGoc0(iTrial,:) = ...
        F_SmPDeSacc(sbd.SmPLVelAllGoc0(iTrial,:),sbd.SmPLAccAllGoc0(iTrial,:),DurThrs,VelThrs,AccThrs,VelAvd);
    % angular to linear speed
    sbd.SmPA2LVelAllGoc1(iTrial,:) = ...
        F_SmPDeSacc(sbd.SmPA2LVelAllGoc1(iTrial,:),sbd.SmPA2LAccAllGoc1(iTrial,:),DurThrs,VelThrs,AccThrs,VelAvd);
end

% found the smp section first, for [50, 120], [120,200], [200,300]
ST = [50,120,200]; ET = [120,200,300]; % Start and End time
% calculate the smp velocity [50,120], remove the saccade within
for iTrial = 1:size(DatafN,2)
    VelThrsA = VelThrs/DatafN(iTrial).TarEcc;
    AccThrsA = AccThrs/DatafN(iTrial).TarEcc;
    VelAvdA = VelAvd/DatafN(iTrial).TarEcc;

    % if the first saccade blink or just no saccade in this conditon
    if isempty(DatafN(iTrial).SacLocGoc2) || ismember(iTrial,iDropA)
        continue
    end

    for iSelc = 1:length(ST)
        % if the trial end toward the smp time start < 50 then skip
        if size(DatafN(iTrial).EyeLocRAcc,2)-sbd.SacETmGoc1(iTrial)+ST(iSelc) < 50
            continue
        end

        % I hate acceleration method
        SmPLVSec = []; SmPLASec = []; SmPAVSec = []; SmPAASec = [];
        try
            SmPLVSec = DatafN(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+ST(iSelc):sbd.SacETmGoc1(iTrial)+ET(iSelc));
            SmPAVSec = DatafN(iTrial).EyeLocRVel(3,sbd.SacETmGoc1(iTrial)+ST(iSelc):sbd.SacETmGoc1(iTrial)+ET(iSelc));
            % I may need Acc to find the saccade during smooth pursuit. I didnt
            % * 1000 in ReadEyeLoc.m
            SmPLASec = DatafN(iTrial).EyeLocRAcc(6,sbd.SacETmGoc1(iTrial)+ST(iSelc):sbd.SacETmGoc1(iTrial)+ET(iSelc))*1000;
            SmPAASec = DatafN(iTrial).EyeLocRAcc(3,sbd.SacETmGoc1(iTrial)+ST(iSelc):sbd.SacETmGoc1(iTrial)+ET(iSelc))*1000;
        catch % if the trial end before 120ms
            SmPLVSec = DatafN(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+ST(iSelc):end);
            SmPLASec = DatafN(iTrial).EyeLocRAcc(6,sbd.SacETmGoc1(iTrial)+ST(iSelc):end)*1000;
            SmPAVSec = DatafN(iTrial).EyeLocRVel(3,sbd.SacETmGoc1(iTrial)+ST(iSelc):end);
            SmPAASec = DatafN(iTrial).EyeLocRAcc(3,sbd.SacETmGoc1(iTrial)+ST(iSelc):end)*1000;
        end
        sbd.SmPLVelGoc1(iSelc,iTrial) = F_SmPCalcu(SmPLVSec,SmPLASec,DurThrs,VelThrs,AccThrs,VelAvd,'linear');
        sbd.SmPAVelGoc1(iSelc,iTrial) = F_SmPCalcu(SmPAVSec,SmPAASec,DurThrs,VelThrsA,AccThrsA,VelAvdA,'Angular');
        % if the value is too large then means that it may not be the real
        % smooth pursuit
        % and velocity equals zero this is the calculation issue I need to fix
        % set a specific requirement for stationary
        if sbd.SmPLVelGoc1(iSelc,iTrial) >=80 || (DatafN(iTrial).TarSpeed == 0 && sbd.SmPLVelGoc1(iSelc,iTrial) >=50)
            sbd.SmPLVelGoc1(iSelc,iTrial) = nan;
        end
        if abs(sbd.SmPAVelGoc1(iSelc,iTrial)) >= 80/DatafN(iTrial).TarEcc || ...
                (DatafN(iTrial).TarSpeed == 0 && sbd.SmPAVelGoc1(iSelc,iTrial) >=50/DatafN(iTrial).TarEcc)
            sbd.SmPAVelGoc1(iSelc,iTrial) = nan;
        end
    end

end

%% Calculate target location at different time point
% centered on target
% find the nearest frame to the event time
% always find the first frame before the time

% find target at gocue first
for iTrial = 1:size(DatafN,2)

    if isempty (DatafN(iTrial).TarPathXReal)
        sbd.TarPath{iTrial} = [];
    else
        sbd.TarPath{iTrial}(1,:) = (DatafN(iTrial).TarPathXReal(1,:) - DatafN(iTrial).center(1))/DatafN(iTrial).ppd(1); %X
        sbd.TarPath{iTrial}(2,:) = (DatafN(iTrial).TarPathYReal(1,:) - DatafN(iTrial).center(2))/DatafN(iTrial).ppd(2); %Y
        [sbd.TarPath{iTrial}(3,:),sbd.TarPath{iTrial}(4,:)] = cart2pol(sbd.TarPath{iTrial}(1,:),sbd.TarPath{iTrial}(2,:)); % Theta & R
        sbd.TarPath{iTrial}(5,:) = DatafN(iTrial).TarPathXReal(2,:); % Time
    end

    if isnan(DatafN(iTrial).TimeGocOn)
        continue
    end
    % align to gocue onset
    DatafN(iTrial).TarPathXReal(3,:) = DatafN(iTrial).TarPathXReal(2,:) - DatafN(iTrial).TimeGocOn;
    % align to gocue onset
    DatafN(iTrial).TarPathYReal(3,:) = DatafN(iTrial).TarPathYReal(2,:) - DatafN(iTrial).TimeGocOn;
    % align to gocue onset
    DatafN(iTrial).TarPathAngReal(3,:) = DatafN(iTrial).TarPathAngReal(2,:) - DatafN(iTrial).TimeGocOn;

    % gocue onset
    % always find the time after the gocue onset because the recording
    % order (first present gocue, then record that time)
    iRow = size(DatafN(iTrial).TarPathAngReal,1);
    TarX = [];TarY = [];TarAng = [];TarRho = [];
    try
        iCom = find(DatafN(iTrial).TarPathXReal(iRow,:) == ...
            min(DatafN(iTrial).TarPathXReal(iRow,DatafN(iTrial).TarPathXReal(iRow,:)>=0)));
    catch
        iCom = find(DatafN(iTrial).TarPathXReal(iRow,:) == ...
            max(DatafN(iTrial).TarPathXReal(iRow,DatafN(iTrial).TarPathXReal(iRow,:)<=0)));
    end
    % X Y location need to transefer to visual degree
    TarX = (DatafN(iTrial).TarPathXReal(1,iCom) - DatafN(iTrial).center(1))/DatafN(iTrial).ppd(1);
    TarY = (DatafN(iTrial).TarPathYReal(1,iCom) - DatafN(iTrial).center(2))/DatafN(iTrial).ppd(2);
    [TarAng,TarRho] = cart2pol(TarX,TarY);
    DatafN(iTrial).SacTarGoc1(iRow-2,:) = [TarX,TarY,TarAng,TarRho,DatafN(iTrial).TarPathXReal(iRow,iCom),iCom];

    % I need to add a predict target location, use variable Name add 1 as prediction
    TLag = DatafN(iTrial).TarPathXReal(iRow,iCom); TVel = DatafN(iTrial).TarSpeed;
    TarAng1 = TarAng - TVel*(TLag/1000); % added predicted time
    TarRho1 = TarRho;
    [TarX1,TarY1] = pol2cart(TarAng1,TarRho1);
    DatafN(iTrial).SacTarGoc1Atcp(iRow-2,:) = [TarX1,TarY1,TarAng1,TarRho1];

end

% target other locations that is related to saccade
for iTrial = 1:size(DatafN,2)
    if isempty(DatafN(iTrial).SacLocGoc2)
        continue
    end
    NowRow = size(DatafN(iTrial).TarPathAngReal,1); 
    BinSize = 20; MaxWin = 100; NowWin = MaxWin + BinSize; % 100ms max window size, 20ms bin size
    for iRow = NowRow+1 : MaxWin/BinSize + NowRow
        NowWin = NowWin-BinSize; % 100, 80, 60, 40, 20
        % align to 100ms before Saccade onset
        DatafN(iTrial).TarPathXReal(iRow,:) = DatafN(iTrial).TarPathXReal(2,:) - (sbd.SacSTmGoc1(iTrial)-NowWin);
    end
    % align to saccade onset
    DatafN(iTrial).TarPathXReal(iRow+1,:) = DatafN(iTrial).TarPathXReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    DatafN(iTrial).TarPathXReal(iRow+2,:) = DatafN(iTrial).TarPathXReal(2,:) - sbd.SacETmGoc1(iTrial);

    NowWin = MaxWin + BinSize; 
    for iRow = NowRow+1 : MaxWin/BinSize + NowRow
        NowWin = NowWin-BinSize; % 100, 80, 60, 40, 20
        % align to 100ms before Saccade onset
        DatafN(iTrial).TarPathYReal(iRow,:) = DatafN(iTrial).TarPathYReal(2,:) - (sbd.SacSTmGoc1(iTrial)-NowWin);
    end
    % align to saccade onset
    DatafN(iTrial).TarPathYReal(iRow+1,:) = DatafN(iTrial).TarPathYReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    DatafN(iTrial).TarPathYReal(iRow+2,:) = DatafN(iTrial).TarPathYReal(2,:) - sbd.SacETmGoc1(iTrial);

    NowWin = MaxWin + BinSize; 
    for iRow = NowRow+1 : MaxWin/BinSize + NowRow
        NowWin = NowWin-BinSize; % 100, 80, 60, 40, 20
        % align to 100ms before Saccade onset
        DatafN(iTrial).TarPathAngReal(iRow,:) = DatafN(iTrial).TarPathAngReal(2,:) - (sbd.SacSTmGoc1(iTrial)-NowWin);
    end
    % align to saccade onset
    DatafN(iTrial).TarPathAngReal(iRow+1,:) = DatafN(iTrial).TarPathAngReal(2,:) - sbd.SacSTmGoc1(iTrial);
    % align to saccade offset
    DatafN(iTrial).TarPathAngReal(iRow+2,:) = DatafN(iTrial).TarPathAngReal(2,:) - sbd.SacETmGoc1(iTrial);

    % find the target location, always find the first frame before the saccade time
    % for some trials there is no first frame before the trial, find the
    % closed frame
    % each row: 60ms, 80ms, 100ms before saccade onset, saccade onset, saccade offset,
    for iRow = 4:size(DatafN(iTrial).TarPathAngReal,1)
        TarX = [];TarY = [];TarAng = [];TarRho = [];
        try
            iCom = find(DatafN(iTrial).TarPathXReal(iRow,:) == ...
                max(DatafN(iTrial).TarPathXReal(iRow,DatafN(iTrial).TarPathXReal(iRow,:)<=0)));
        catch
            iCom = find(DatafN(iTrial).TarPathXReal(iRow,:) == ...
                min(DatafN(iTrial).TarPathXReal(iRow,DatafN(iTrial).TarPathXReal(iRow,:)>=0)));
        end
        % X Y location need to transefer to visual degree
        TarX = (DatafN(iTrial).TarPathXReal(1,iCom) - DatafN(iTrial).center(1))/DatafN(iTrial).ppd(1);
        TarY = (DatafN(iTrial).TarPathYReal(1,iCom) - DatafN(iTrial).center(2))/DatafN(iTrial).ppd(2);
        [TarAng,TarRho] = cart2pol(TarX,TarY);
        DatafN(iTrial).SacTarGoc1(iRow-2,:) = [TarX,TarY,TarAng,TarRho,DatafN(iTrial).TarPathXReal(iRow,iCom),iCom];

        % I need to add a predict target location, use variable Name add 1 as prediction
        TLag = DatafN(iTrial).TarPathXReal(iRow,iCom); TVel = DatafN(iTrial).TarSpeed;
        TarAng1 = TarAng - TVel*(TLag/1000); % added predicted time
        TarRho1 = TarRho;
        [TarX1,TarY1] = pol2cart(TarAng1,TarRho1);
        DatafN(iTrial).SacTarGoc1Atcp(iRow-2,:) = [TarX1,TarY1,TarAng1,TarRho1];
    end
end

%% Calculate the target displace during RT and Sacc Duration
for iTrial = 1:size(DatafN,2)
    if isempty(DatafN(iTrial).SacLocGoc2)
        continue
    end
    % Target displacement during saccade, this is calculated by the
    % difference of different time point From end to gocue
    sbd.TarSaccDisp1(iTrial,:) = DatafN(iTrial).SacTarGoc1Atcp(end,:) - DatafN(iTrial).SacTarGoc1Atcp(1,:);
    sbd.TarSaccDisp2(iTrial) = (sbd.SacRTGoc1(iTrial)+sbd.SacDurGoc1(iTrial))/1000 * DatafN(iTrial).TarSpeed;
end

%% Calculate saccade ending error (by radius distance and angular) with target loc at sac offset
sbd.SacEndXY = NaN(2,length(DatafN)); % record the ending location
sbd.SacEndTR = NaN(2,length(DatafN));
sbd.SacIniXY = NaN(2,length(DatafN)); % record the initial location
sbd.SacIniTR = NaN(2,length(DatafN));
sbd.TarEndXY = NaN(2,length(DatafN));
sbd.TarEndTR = NaN(2,length(DatafN));
% record target location at gocue:
sbd.TarGocXY = NaN(2,length(DatafN));
sbd.TarGocTR = NaN(2,length(DatafN));

sbd.TarTMrkXY = cell(size(DatafN));
sbd.TarTMrkTR = cell(size(DatafN));

sbd.SacEndErrX = NaN(size(DatafN));
sbd.SacEndErrY = NaN(size(DatafN));
sbd.SacEndErrAng2Tar = NaN(size(DatafN)); % centered on Target
sbd.SacEndErrRho = NaN(size(DatafN)); % centered on Target
sbd.SacEndErrRhoSign1 = NaN(size(DatafN)); % left and right sign
sbd.SacEndErrRhoSign2 = NaN(size(DatafN)); % up and down sign (overshoot or undershoot)
sbd.SacEndErrAng2C = NaN(size(DatafN)); % centered on center point
sbd.SacEndErrAng2CSign1 = NaN(size(DatafN));
sbd.SacEndErrAng2CSign2 = NaN(size(DatafN));

iDropB = []; % for too large ending error
trialNum = []; % collect drop trial number
for iTrial = 1:size(DatafN,2)
    if isempty(DatafN(iTrial).SacLocGoc2)
        continue
    end
    SacEndLoc = [];
    SacIniLoc = [];
    TimeS = [];
    TimeE = [];
    % X, Y, Theta, Rho, Disp, AccDisp
    SacEndLoc = mean(sbd.SacTraGoc11{iTrial}(1:2,end-2:end),2); % 3 ms range, [-1,1]
    sbd.SacEndXY(1:2,iTrial) = SacEndLoc; % record the ending location
    [SacEndLoc(3),SacEndLoc(4)] = cart2pol(SacEndLoc(1),SacEndLoc(2));
    sbd.SacEndTR(1:2,iTrial) = [SacEndLoc(3);SacEndLoc(4)];

    SacIniLoc = mean(sbd.SacTraGoc11{iTrial}(1:2,1:3),2); % to target ending location, 3ms[-1,1]
    sbd.SacIniXY(1:2,iTrial) = SacIniLoc; % record the initial location
    [SacIniLoc(3),SacIniLoc(4)] = cart2pol(SacIniLoc(1),SacIniLoc(2));
    sbd.SacIniTR(1:2,iTrial) = [SacIniLoc(3);SacIniLoc(4)];

    sbd.SacEndErrX(iTrial) = SacEndLoc(1) - DatafN(iTrial).SacTarGoc1Atcp(end,1);
    sbd.SacEndErrY(iTrial) = SacEndLoc(2) - DatafN(iTrial).SacTarGoc1Atcp(end,2);
    % at saccade end
    sbd.TarEndXY(1:2,iTrial) = [DatafN(iTrial).SacTarGoc1Atcp(end,1);DatafN(iTrial).SacTarGoc1Atcp(end,2)];
    sbd.TarEndTR(1:2,iTrial) = [DatafN(iTrial).SacTarGoc1Atcp(end,3);DatafN(iTrial).SacTarGoc1Atcp(end,4)];
    % at Go cue
    sbd.TarGocXY(1:2,iTrial) = [DatafN(iTrial).SacTarGoc1Atcp(1,1);DatafN(iTrial).SacTarGoc1Atcp(1,2)];
    sbd.TarGocTR(1:2,iTrial) = [DatafN(iTrial).SacTarGoc1Atcp(1,3);DatafN(iTrial).SacTarGoc1Atcp(1,4)];
    sbd.TarTMrkXY{iTrial} = DatafN(iTrial).SacTarGoc1Atcp(:,1:2);
    sbd.TarTMrkTR{iTrial} = DatafN(iTrial).SacTarGoc1Atcp(:,3:4);

    [sbd.SacEndErrAng2Tar(iTrial),sbd.SacEndErrRho(iTrial)] = cart2pol(sbd.SacEndErrX(iTrial),sbd.SacEndErrY(iTrial));
    sbd.SacEndErrAng2C(iTrial) = wrapToPi(SacEndLoc(3)-DatafN(iTrial).SacTarGoc1Atcp(end,3));
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
    % What I'm writing here?
    % if wrapToPi(SacEndLoc(3)) > wrapToPi(DatafN(iTrial).SacTarGoc1Atcp(end,3)) && rem(DatafN(iTrial).TarDir+1,2) == 0
    %     sbd.SacEndErrRhoSign1(iTrial) = +sbd.SacEndErrRho(iTrial);
    %     sbd.SacEndErrAng2CSign1(iTrial) = +sbd.SacEndErrAng2C(iTrial);
    % elseif wrapToPi(SacEndLoc(3)) <= wrapToPi(DatafN(iTrial).SacTarGoc1Atcp(end,3)) && rem(DatafN(iTrial).TarDir+1,2) == 0
    %     sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
    %     sbd.SacEndErrAng2CSign1(iTrial) = +sbd.SacEndErrAng2C(iTrial);
    % elseif wrapToPi(SacEndLoc(3)) >= wrapToPi(DatafN(iTrial).SacTarGoc1Atcp(end,3)) && rem(DatafN(iTrial).TarDir+1,2) == 1
    %     sbd.SacEndErrRhoSign1(iTrial) = -sbd.SacEndErrRho(iTrial);
    %     sbd.SacEndErrAng2CSign1(iTrial) = -sbd.SacEndErrAng2C(iTrial);
    % elseif wrapToPi(SacEndLoc(3)) < wrapToPi(DatafN(iTrial).SacTarGoc1Atcp(end,3)) && rem(DatafN(iTrial).TarDir+1,2) == 1
    %     sbd.SacEndErrRhoSign1(iTrial) = +sbd.SacEndErrRho(iTrial);
    %     sbd.SacEndErrAng2CSign1(iTrial) = -sbd.SacEndErrAng2C(iTrial);
    % end
    % the sbd.SacEndErrRho is the distance, doesn't have undershoot or
    % overshoot info
    
    % Since the SacEndErrAng2C = SacLoc - TarLoc, thus in CW, < 0 is
    % anticipate and > 0 is lag; in CCW, > 0 is anticipate and < 0 is lag
    % So I'm going to reverse the sign of CW, make in all condition, > 0 is
    % anticipate and < 0 is lag
    if DatafN(iTrial).TarDir1 >= 5 && DatafN(iTrial).TarDir1 <=7 % CW reverse direction
        sbd.SacEndErrAng2CSign2(iTrial) = -sbd.SacEndErrAng2C(iTrial);
    else
        sbd.SacEndErrAng2CSign2(iTrial) = sbd.SacEndErrAng2C(iTrial);
    end
    % detect Ending err too large
    if abs(sbd.SacEndErrRho(iTrial)) >=10
        iDropB = [iDropB,iTrial];
    end
end

%% Calculate the dynamic saccade relation with the target location at saccade offset
% all of the saccade mentioned below are the first saccade after gocue
% Anglular error between saccade initial direction and ending direction
% iniT = 10; checked initial time, maybe 10ms

% SacDynErrX = NaN(size(Dataf1)); % Saccade Dynamic Error X
% SacDynErrY = NaN(size(Dataf1)); % Saccade Dynamic Error Y
sbd.SacEnd2E = NaN(4,length(DatafN)); % record the ending location with eye center
sbd.SacIni2E = NaN(4,length(DatafN)); % record the initial location with eye center
sbd.TarEnd2E = NaN(4,length(DatafN)); % record the target location with eye center
sbd.TarGoc2E = NaN(4,length(DatafN)); % record the target location with eye center
sbd.TarTMrk2E = cell(size(DatafN)); % Target locations at different marked time
sbd.SacTraGoc2E1 = cell(size(DatafN)); %2E to the eye initial location
sbd.SacTraGoc2E11 = cell(size(DatafN)); %2E to the eye initial location with +- 1 at the back and front
% sbd.TarGocEnd2E = cell(size(DatafN)); % align target location at saccade end to saccade ini lac
sbd.EyePolrGocTan = cell(size(DatafN)); % tangent angular
sbd.SacDynErrAngTan = cell(size(DatafN)); % Saccade Dynamic angular Error
% sbd.SacIniErrAngTan = NaN(size(Dataf));
% sbd.SacEndErrAngTan = NaN(size(Dataf));
% sbd.SacIniErrAngTanSign = NaN(size(Dataf));
% sbd.SacEndErrAngTanSign = NaN(size(Dataf));
sbd.SacIniDir = NaN(size(DatafN)); % Saccade initial direction at 10ms
sbd.SacAllDir = NaN(size(DatafN)); % Saccade Overall direction
sbd.SacCurPara1 = NaN(size(DatafN)); % first curvature parameters: All dir - Ini Dir
sbd.SacIniErrAng2E = NaN(size(DatafN));
sbd.SacEndErrAng2E = NaN(size(DatafN)); 
sbd.SacTMrkErrAng2E = cell(size(DatafN)); % Ending error at different marked time
sbd.SacIniErrAng2ESign = NaN(size(DatafN));
sbd.SacEndErrAng2ESign = NaN(size(DatafN));
sbd.SacTMrkErrAng2ESign = cell(size(DatafN)); % Ending error at different marked time after signed
% SacDynErrRho = NaN(size(Dataf1)); % Saccade Dynamic Radius Error

for iTrial = 1:size(DatafN,2)
    if isempty(DatafN(iTrial).SacLocGoc2)
        continue
    end
    EyeLocGoc = []; % whole eye traces
    EyeLocGoc1 = []; % whole eye traces with +- 1 at the initial and the end
    % sbd.EyeCartGoc2Zero = []; % whole eye traces (X-Y location) relative to zero point
    % EyePolrGoc2Zero = []; % whole eye traces (theta and rho)
    SacIniLoc = []; % Saccade Initial location
    SacEndLoc = []; % saccade end location
    TimeS = [];
    TimeE = [];
    TimeS = sbd.SacSTmGoc1(iTrial);
    TimeE = sbd.SacETmGoc1(iTrial);
    % rows: X, Y, Theta, Rho, Disp, AccDisp, VelX, VelY, VelRho, don't need
    % velocity mark
    EyeLocGoc = sbd.SacTraGoc1{iTrial};
    EyeLocGoc1 = sbd.SacTraGoc11{iTrial};
    SacIniLoc = sbd.SacIniXY(1:2,iTrial);
    SacEndLoc = sbd.SacEndXY(1:2,iTrial);
    
    sbd.SacTraGoc2E1{iTrial} = EyeLocGoc(1:2,:) - SacIniLoc(1:2);
    [sbd.SacTraGoc2E1{iTrial}(3,:),sbd.SacTraGoc2E1{iTrial}(4,:)] = ...
        cart2pol(sbd.SacTraGoc2E1{iTrial}(1,:),sbd.SacTraGoc2E1{iTrial}(2,:));

    sbd.SacTraGoc2E11{iTrial} = EyeLocGoc1(1:2,:) - SacIniLoc(1:2);
    [sbd.SacTraGoc2E11{iTrial}(3,:),sbd.SacTraGoc2E11{iTrial}(4,:)] = ...
        cart2pol(sbd.SacTraGoc2E11{iTrial}(1,:),sbd.SacTraGoc2E11{iTrial}(2,:));

    sbd.SacEnd2E(1:2,iTrial) = mean(sbd.SacTraGoc2E11{iTrial}(1:2,end-2:end),2); % 3 ms range, [-1,1]
    [sbd.SacEnd2E(3,iTrial),sbd.SacEnd2E(4,iTrial)] = cart2pol(sbd.SacEnd2E(1,iTrial),sbd.SacEnd2E(2,iTrial));

    sbd.SacIni2E(1:2,iTrial) = mean(sbd.SacTraGoc2E11{iTrial}(1:2,1:3),2); % 3 ms range, [-1,1]
    [sbd.SacIni2E(3,iTrial),sbd.SacIni2E(4,iTrial)] = cart2pol(sbd.SacIni2E(1,iTrial),sbd.SacIni2E(2,iTrial));

    % Target location also match to eye initial
    % at saccade end
    sbd.TarEnd2E(1:2,iTrial) = [DatafN(iTrial).SacTarGoc1Atcp(end,1)-SacIniLoc(1,1),...
        DatafN(iTrial).SacTarGoc1Atcp(end,2)-SacIniLoc(2,1)];
    [sbd.TarEnd2E(3,iTrial),sbd.TarEnd2E(4,iTrial)] = cart2pol(sbd.TarEnd2E(1,iTrial),sbd.TarEnd2E(2,iTrial));
    % at Gocue
    sbd.TarGoc2E(1:2,iTrial) = [DatafN(iTrial).SacTarGoc1Atcp(1,1)-SacIniLoc(1,1),...
        DatafN(iTrial).SacTarGoc1Atcp(1,2)-SacIniLoc(2,1)];
    [sbd.TarGoc2E(3,iTrial),sbd.TarGoc2E(4,iTrial)] = cart2pol(sbd.TarGoc2E(1,iTrial),sbd.TarGoc2E(2,iTrial));

    sbd.TarTMrk2E{iTrial} = [DatafN(iTrial).SacTarGoc1Atcp(:,1)-SacIniLoc(1,1),...
        DatafN(iTrial).SacTarGoc1Atcp(:,2)-SacIniLoc(2,1)];
    t = []; r = []; [t,r] = cart2pol(sbd.TarTMrk2E{iTrial}(:,1),sbd.TarTMrk2E{iTrial}(:,2));
    sbd.TarTMrk2E{iTrial} = [sbd.TarTMrk2E{iTrial},t,r];
    

    % Target Path
    sbd.TarPath2E{iTrial}(1,:) = sbd.TarPath{iTrial}(1,:) - SacIniLoc(1,1); % x location
    sbd.TarPath2E{iTrial}(2,:) = sbd.TarPath{iTrial}(2,:) - SacIniLoc(2,1); % y location
    [sbd.TarPath2E{iTrial}(3,:),sbd.TarPath2E{iTrial}(4,:)] = ...
        cart2pol(sbd.TarPath2E{iTrial}(1,:),sbd.TarPath2E{iTrial}(2,:)); % theta and r location
    sbd.TarPath2E{iTrial}(5,:) = sbd.TarPath{iTrial}(5,:); % time
    % sbd.SacTraGoc2E1{iTrial} = EyeLocGoc(1:2,1) - EyeLocGoc(1:2,1:end-1);

    % atan2(y,x) % velocity y and velocity x
    % need to find a new way to calculate this
    sbd.EyePolrGocTan{iTrial} = atan2(EyeLocGoc(8,:),EyeLocGoc(7,:));
    sbd.SacDynErrAngTan{iTrial}  = wrapToPi(sbd.EyePolrGocTan{iTrial} - sbd.TarEnd2E(3,iTrial));
    
    % I will give a three ms time range
    if iniT >= sbd.SacDurGoc1(iTrial)
        sbd.SacIniDir(iTrial) = nan; % Saccade initial direction
        sbd.SacAllDir(iTrial) = wrapToPi(circ_mean(sbd.SacTraGoc2E1{iTrial}(3,end-2:end)')); % Saccade Overall direction

    else
        sbd.SacIniDir(iTrial) = wrapToPi(circ_mean(sbd.SacTraGoc2E1{iTrial}(3,iniT-1:iniT+1)')); % Saccade initial direction
        sbd.SacAllDir(iTrial) = wrapToPi(circ_mean(sbd.SacTraGoc2E1{iTrial}(3,end-2:end)')); % Saccade Overall direction
    end

    sbd.SacIniErrAng2E(iTrial) = wrapToPi(sbd.SacIni2E(3,iTrial) - sbd.TarEnd2E(3,iTrial));
    sbd.SacEndErrAng2E(iTrial) = wrapToPi(sbd.SacEnd2E(3,iTrial) - sbd.TarEnd2E(3,iTrial));
    sbd.SacTMrkErrAng2E{iTrial} = wrapToPi(sbd.SacEnd2E(3,iTrial) - sbd.TarTMrk2E{iTrial}(:,3));
    % 
    if DatafN(iTrial).TarDir1 >= 5 && DatafN(iTrial).TarDir1 <=7 % at CW reverse the direction
        sbd.SacIniErrAng2ESign(iTrial) = -sbd.SacIniErrAng2E(iTrial);
        sbd.SacEndErrAng2ESign(iTrial) = -sbd.SacEndErrAng2E(iTrial);
        sbd.SacTMrkErrAng2ESign{iTrial} = -sbd.SacTMrkErrAng2E{iTrial};
    else
        sbd.SacIniErrAng2ESign(iTrial) = sbd.SacIniErrAng2E(iTrial);
        sbd.SacEndErrAng2ESign(iTrial) = sbd.SacEndErrAng2E(iTrial);
        sbd.SacTMrkErrAng2ESign{iTrial} = sbd.SacTMrkErrAng2E{iTrial};
    end

    sbd.SacCurPara1(iTrial) = wrapToPi(sbd.SacAllDir(iTrial)-sbd.SacIniDir(iTrial));
end

%% move the eye trace to have all same initial location
% sbd.EyeLocMovXY = cell(1,size(Dataf,2));
% sbd.EyeLocMovPol = cell(1,size(Dataf,2));
sbd.EyeLocRttPol = cell(1,size(DatafN,2));

for iTrial = 1:size(DatafN,2)
    if isempty(DatafN(iTrial).SacLocGoc2)
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
sbd.SacMaxCurSize_PPD = NaN(size(DatafN)); % use prependicular distance method to calculate
sbd.SacMaxCurTime_PPD = NaN(size(DatafN)); % Saccade Maxium curvatue duration
sbd.SacMaxCurTra1_PPD = cell(size(DatafN)); % Saccade tarce befor maximum curvature
sbd.SacMaxCurTra2_PPD = cell(size(DatafN)); % Saccade tarce after maximum curvature
sbd.EyePolrGoc2E1_PPD = cell(size(DatafN)); % Saccade polar eye trace to Eye, befor maximum curvature
sbd.EyePolrGoc2E2_PPD = cell(size(DatafN)); % Saccade polar eye trace to Eye, after maximum curvature
sbd.EyeCartGoc2E1_PPD = cell(size(DatafN)); % Saccade Cart eye trace to Eye, befor maximum curvature
sbd.EyeCartGoc2E2_PPD = cell(size(DatafN)); % Saccade Cart eye trace to Eye, befor maximum curvature
sbd.SacMaxCurAllDir1_PPD = NaN(size(DatafN)); % from initial to max direction
sbd.SacMaxCurAllDir2_PPD = NaN(size(DatafN)); % from max direction to ending
sbd.SacMaxCurDir_PPD = NaN(size(DatafN));

for iTrial = 1:size(DatafN,2)
    if isempty(DatafN(iTrial).SacLocGoc2)
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

%% Drop Data Session
% need to drop iDrop4 from DatafN here since the following code start using
% datas1
iDrop4 = unique([iDropA,iDropB]);
% label the idrop 4 trials
for iDrop = 1:length(iDrop4)
    DatafN(iDrop4(iDrop)).TrialStatus = -1; % doesn't apply criteria
end

%% Zscore RT
% I will do two Zscore of RT: one for all, one for data I used
datasAll = find([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5);
RTmin = min(sbd.SacRTGoc1(datasAll));
RTmax = max(sbd.SacRTGoc1(datasAll));
sbd.SacRTGoc1Zs = (sbd.SacRTGoc1-RTmin)/(RTmax-RTmin);
% for all the data
RTmin = min(sbd.SacRTGoc1);
RTmax = max(sbd.SacRTGoc1);
sbd.SacRTGoc1ZsAll = (sbd.SacRTGoc1-RTmin)/(RTmax-RTmin);

%% Calculate the de-stationary-trend ending error 2E
% old method, do this section later

%% Calculate the de-stationary-trend ending error 2E, x axis as different target x
% old method, do this section later

%% Calculate the de-stationary-trend ending error 2E, x axis aas target location 
% Remove stationary trend ending error 2E, x axis as target location 
sbd.SacEndErrAng2ESignDeSta = NaN(size(DatafN));
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
winSize = pi/6; % 30 deg
stepSize = winSize;
% sbd.SacEndErrAng2ESign2Normed_TarNoOrder = nan(size(sbd.SacEndErrAng2ESign));
for iCond = CondI
    datas1 = find([DatafN.TarDir1] == iCond & ([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5));
    XV = [];YV = []; RhoVAve = []; RhoVStd = [];
    XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
    YV = sbd.SacEndErrAng2ESign(datas1);
    if iCond == 1
        XVbase = []; YVbase = [];
        XVbase = XV; YVbase = YV;
    end
    % do the normalization
    if iCond <5
        XNorm = []; YNorm = []; XIndAll = [];
        [~, YNorm, ~] = F_CartScaMovNorm(winSize,stepSize,XV',XVbase',YV',YVbase',[0,2*pi-winSize]);
    else
        XNorm = []; YNorm = []; XIndAll = [];
        [~, YNorm, ~] = F_CartScaMovNorm(winSize,stepSize,XV',XVbase',YV',-YVbase',[0,2*pi-winSize]);
    end

    % Record the Origin data
    sbd.SacEndErrAng2ESignDeSta(datas1) = YNorm;
end

%% wrapped and flipped target end 2E location
sbd.TarEnd2EAngWrap = mod(wrapTo2Pi(sbd.TarEnd2E(3,:))-pi/2,pi*2);

% flip the CW direction
sbd.TarEnd2EAngWrapflip = sbd.TarEnd2EAngWrap;
datas1 = find([DatafN.TarDir1] == 5 | [DatafN.TarDir1] == 6 | [DatafN.TarDir1] == 7);
sbd.TarEnd2EAngWrapflip(datas1) = 2*pi - sbd.TarEnd2EAngWrap(datas1);

%% Calculated the de-stationary-trend ending error 2E, centralization
% zero means, under each condition
sbd.SacEndErrAng2ESignDeStaCen1 = NaN(size(DatafN)); 
for iCond = CondI
    datas1 = find([DatafN.TarDir1] == iCond & ([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5));
    YV = sbd.SacEndErrAng2ESignDeSta(datas1);
    YVCen = YV - circ_mean_nan(YV');
    sbd.SacEndErrAng2ESignDeStaCen1(datas1) = YVCen;
end

% zero means, under same speed
sbd.SacEndErrAng2ESignDeStaCen2 = NaN(size(DatafN)); 
CondIComp = [1,2,3,4; 1,5,6,7];
for iCond = CondIComp(1,:)
    datas1 = find(([DatafN.TarDir1] == iCond | [DatafN.TarDir1] == CondIComp(2,iCond)) ...
        & ([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5));
    YV = sbd.SacEndErrAng2ESignDeSta(datas1);
    YVCen = YV - circ_mean_nan(YV');
    sbd.SacEndErrAng2ESignDeStaCen2(datas1) = YVCen;
end

%% Calculate the de-stationary-trend RT, x axis aas target location 
% Remove stationary trend ending error 2E, x axis as target location 
sbd.SacRTGoc1DeSta = NaN(size(DatafN));
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
winSize = pi/6; % 30 deg
stepSize = winSize;
% sbd.SacEndErrAng2ESign2Normed_TarNoOrder = nan(size(sbd.SacEndErrAng2ESign));
for iCond = CondI
    datas1 = find([DatafN.TarDir1] == iCond & ([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5));
    XV = [];YV = []; RhoVAve = []; RhoVStd = [];
    XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
    YV = sbd.SacRTGoc1(datas1);
    if iCond == 1
        XVbase = []; YVbase = [];
        XVbase = XV; YVbase = YV;
    end
    % do the normalization
    XNorm = []; YNorm = []; XIndAll = [];
    [~, YNorm, ~] = F_CartScaMovNorm1(winSize,stepSize,XV',XVbase',YV',YVbase',[0,2*pi-winSize]);

    % Record the Origin data
    sbd.SacRTGoc1DeSta(datas1) = YNorm;
end

%% Calculate the de-statioanry-trend RT zero means, centralization
sbd.SacRTGoc1DeStaCen1 = NaN(size(DatafN));
% zero means, under each condition
sbd.SacRTGoc1DeStaCen1 = NaN(size(DatafN)); 
for iCond = CondI
    datas1 = find([DatafN.TarDir1] == iCond & ([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5));
    YV = sbd.SacRTGoc1DeSta(datas1);
    YVCen = YV - mean(YV,'omitmissing');
    sbd.SacRTGoc1DeStaCen1(datas1) = YVCen;
end

% zero means, under same speed
sbd.SacRTGoc1DeStaCen2 = NaN(size(DatafN)); 
CondIComp = [1,2,3,4; 1,5,6,7];
for iCond = CondIComp(1,:)
    datas1 = find(([DatafN.TarDir1] == iCond | [DatafN.TarDir1] == CondIComp(2,iCond)) ...
        & ([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5));
    YV = sbd.SacRTGoc1DeSta(datas1);
    YVCen = YV - mean(YV,'omitmissing');
    sbd.SacRTGoc1DeStaCen2(datas1) = YVCen;
end

%% Add the KDE analysis to saccade ending 
StepSZ = deg2rad(2); % the size of step
fSigma = 0.3;
vfEstimate = [];
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
for iCond = CondI
    datas1 = [];
    datas1 = find([DatafN.TarDir1] == iCond & ([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5));
    EyeEndTta = zeros(size(datas1));
    EyeEndTta = wrapTo2Pi(sbd.SacEnd2E(3,datas1));
    vfPDFSamples = 0:StepSZ:2*pi;
    vfEstimate(iCond,:) = circ_ksdensity(EyeEndTta, vfPDFSamples, [0, 2*pi], fSigma);
end
sbd.vfEstimate = vfEstimate;
sbd.vfPDFSamples = vfPDFSamples;

end

