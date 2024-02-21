% Data Processing
% This script is used for data processing
% Analysis based on prepro 4
% adjusted on Oct 12, exclude several figures and add some new figures
% Data Save in Result/ Oct12
% Adjusted on Oct 28, add sinwave fit
% Adjusted on Oct 31, adjust the way of doing averaging
% Adjusted on Nov 5, just realize that I confounded the left and right
% Adjusted on Jan 29, make it useful for single subject
% Adjusted on Feb 12, Add new Normalization ways, Change the iniT to 15,
% Change the resample method

%% Load Data
userID = 'EM01';
userDate = '100124';

%%
load([userID,'_',userDate,'_','PreProcessed3.mat'])

%% MKDIR and Condition choose

DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/',userID,'/'];
AnaData = 'Feb12';
ResultDir = [DataDir,'ResultFig/',AnaData,'/'];

LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';
CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondIComp1 = [0,1,3,5; 0,2,4,6]; % When I want to compare with stationary
CondIComp1Name = {'CCW','CW'};
CondName = '_1';

ifDoBasic = 1;

%% basic settings
if ifDoBasic
    mkdir(ResultDir);

    colorRGB = [0 0.4470 0.7410;... % blue
        0.9290 0.6940 0.1250;... %yellow
        0.4660 0.6740 0.1880;... % green;
        0.8500 0.3250 0.0980;...
        0.9290 0.6940 0.1250;... %yellow
        0.4660 0.6740 0.1880;... % green;
        0.8500 0.3250 0.0980];% orange
    % light one
    colorRGB1 = [202, 218, 237;...
        248, 222, 126;... % 246, 219, 117
        206, 232, 195;...
        246, 210, 168;...
        248, 222, 126;... % 246, 219, 117
        206, 232, 195;...
        246, 210, 168]/255;
    % dark one
    colorRGB2 = [72, 128, 184;... %blue
        194, 123, 55;... % yellow 238, 169, 60
        85, 161, 92;... % green),2)
        213, 95, 43;...
        194, 123, 55;... % yellow 238, 169, 60
        85, 161, 92;... % green),2)
        213, 95, 43]/255; %pink/orange

    % Legend setting
    LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];

    FixW = [-100,900];
    TarW = [-400,600];
    GocW = [-500,500];
    SacW = [-500,500];

    GocC = find(GocW(1):GocW(2) == 0);

    %% PreProcessed of data
    Dataf1 = Dataf;

    % % remove Dataf that TrialStatus ~=1
    % Dataf1([Dataf.TrialStatus]~=1) = [];
    %
    % % remove trials that peak velocity < 50 deg/sec
    % Dataf1([Dataf1.SacPvelGoc1]<50) = [];

    % remove RT < 100ms >400, duration >=100ms, start radius >=4, end radius <=4,
    % amplitude <4
    % peak velocity < 50, have microsaccade 100ms before gocue (after already excluded)
    iDrop1 = []; % for trials that already detected before
    iDrop2 = []; % for trials that are going to detected now/ doesnt satisfied the criteria
    iDrop3 = []; % for trials that are manually checked.. I need to find an easy way!!!
    for iTrial = 1:size(Dataf1,2)
        if Dataf1(iTrial).TrialStatus ~=1 && Dataf1(iTrial).TrialStatus ~=5
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif isempty(Dataf1(iTrial).SacTimeGoc2)
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacTimeGoc2(end,1)<80 || Dataf1(iTrial).SacTimeGoc2(end,1)>400
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacTimeGoc2(end-1,1)>=150
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacLocGoc2{1}(3,1) >=4
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacLocGoc2{1}(3,end) <=4
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif abs(Dataf1(iTrial).SacLocGoc2{1}(3,end)-Dataf1(iTrial).SacLocGoc2{1}(3,1)) <=3
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif abs(Dataf1(iTrial).SacPvelGoc2(1)) <50
            iDrop2 = [iDrop2,iTrial];
            continue
        end
        % SacSeqTemp = Dataf(iTrial).SaccSeqInfo{3}(2,:)-Dataf(iTrial).TimeGocOn;
        % within 100ms before gocue
        % MicroSacLoc = find(SacSeqTemp>=-100 & SacSeqTemp<=0);
        % have to last at least 5ms
        % if ~isempty(MicroSacLoc) & Dataf(iTrial).SaccSeqInfo{3}(3,MicroSacLoc) >=5
        %     iDrop2 = [iDrop2,iTrial];
        % continue
        % end
    end

    iDropDataf1 = unique([iDrop1,iDrop2]);
    % iDropDataf2 = unique([iDrop2,iDrop3]);

    Dataf1(iDropDataf1) = [];

    for iDrop = 1:length(iDrop2)
        Dataf(iDrop2(iDrop)).TrialStatus = -1; % doesn't apply criteria
    end

    %% behavior analysis
    iniT = 15; % select first 10ms for the first saccade
    [sbd,Dataf1,iDrop4] = BehaviorAna(Dataf1,iniT);

    % drop relevent data
    Dataf1(iDrop4) = [];

    sbdfieldNames = fieldnames(sbd);
    % Loop through each field and delete the element
    for iField = 1:length(sbdfieldNames)
        field = sbdfieldNames{iField};
        sbd.(field)(iDrop4) = [];
    end
end

iFigAcc = 0;

Xlim1 = -3*pi/2;
Xlim2 = pi/2;

windSize = pi/9; % 20 deg
increm = pi/18; % 10 deg
XGroup1 = -3*pi/2:increm:(-pi/2-windSize);
XGroup2 = (-3*pi/2+windSize):increm:-pi/2;
XGroup3 = -pi/2:increm:(pi/2-windSize);
XGroup4 = (-pi/2+windSize):increm:pi/2;

%% Find the average trace, time warping, interpolation and down sampling
% I also need to find a way to reduce outliers
iCondI = 0;

resampleRate = 1; % resample every 1ms
AveDur = 1:resampleRate:round(mean(sbd.SacDurGoc1)); % overall mean duration
% AveTime = linspace(0, 1, length(AveDur));

sbd.EyeLocReSXY = cell(1,size(Dataf1,2));
sbd.EyeLocReSPol = cell(1,size(Dataf1,2));

for iCond = CondI
    iCondI = iCondI+1;
    datas = [];
    datas = find([Dataf1.TarDir] == iCond);

    for iTrial = datas
        EyeLocCart = [];
        EyeLocPolr = [];
        EyeLocCart = sbd.EyeLocMovXY{iTrial};
        EyeLocPolr = sbd.EyeLocMovPol{iTrial};
        CurDur = [];
        CurDur = 1:length(EyeLocCart(1,:));
        step = [];
        newX = [];
        newY = [];
        newT = [];
        newR = [];
        NormTime = [];
        NormTime = linspace(1, length(CurDur), length(AveDur));
        % cubic interpolation for shorter trajectories
        if length(CurDur) ~= length(AveDur)
            newX = interp1(CurDur, double(EyeLocCart(1,:)), NormTime,'pchip');
            newY = interp1(CurDur, double(EyeLocCart(2,:)), NormTime,'pchip');
        elseif length(CurDur) == length(AveDur)
            newX = EyeLocCart(1,:);
            newY = EyeLocCart(2,:);
        end

        sbd.EyeLocReSXY{iTrial} = [newX ; newY];
        [newT, newR] = cart2pol(newX, newY);
        sbd.EyeLocReSPol{iTrial} = [newT; newR];
    end
end

%% Group the Data
% group the data by three ways: ending, intial and target location

SegNum = 12; % seperate into 12 segments
AngLinspace = linspace(-pi,pi,SegNum+1);

for iTrial = 1:size(Dataf1,2)
    sbd.SacIniDirRes(1,iTrial) = sbd.EyeLocReSPol{iTrial}(1,iniT);
    sbd.TarDirSacEnd(1,iTrial) = wrapToPi(Dataf1(iTrial).SacTarGoc1(4,3));
end

% sbd.AngIndc_End = discretize(sbd.SacAllDir, AngLinspace);
% sbd.AngIndc_Ini = discretize(sbd.SacIniDirRes, AngLinspace);
% sbd.AngIndc_Tar = discretize(sbd.TarDirSacEnd, AngLinspace);
sbd.AngIndc = [discretize(sbd.SacAllDir, AngLinspace);discretize(sbd.SacIniDirRes, AngLinspace);...
    discretize(sbd.TarDirSacEnd, AngLinspace)];
% Row 1 is grouped by ending location, row 2 is grouped by initial
% location, row 3 is grouped by target location

% sbd.AveTrace_End = cell(length(CondI),SegNum);
% sbd.AveTrace_Ini = cell(length(CondI),SegNum);
% sbd.AveTrace_Tar = cell(length(CondI),SegNum);
sbd.TraceAve = {cell(length(CondI),SegNum),cell(length(CondI),SegNum),cell(length(CondI),SegNum)};
sbd.TraceStd = {cell(length(CondI),SegNum),cell(length(CondI),SegNum),cell(length(CondI),SegNum)};

SaveName = [];
SaveName = {'/EyeTra_Warp_Ave_Ending','/EyeTra_Warp_Ave_Initial','/EyeTra_Warp_Ave_Target'};

TitleName = [];
TitleName = {'Averaging Trace by Saccade End, ', 'Averaging Trace by Saccade Initial, ',...
    'Averaging Trace by Target Location, '};

for iGroup = 1:3
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    for iCond = CondI
        nexttile
        iCondI = iCondI+1;
        if iCondI == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas = [];
        AngIndices = [];

        datas = find([Dataf1.TarDir] == iCond);
        % AngIndices = discretize(sbd.SacAllDir(datas), AngLinspace);
        AngIndices = sbd.AngIndc(iGroup,datas);

        for iSeg = 1:SegNum
            iTriali = 0;
            newT = [];
            newR = [];
            newX = [];
            newY = [];
            newTAve = []; newTStd = [];
            newRAve = []; newRStd = [];
            newXAve = []; newXStd = [];
            newYAve = []; newYStd = [];
            for iTrial = datas(AngIndices == iSeg)
                iTriali = iTriali+1;
                newT(iTriali,:) = sbd.EyeLocReSPol{iTrial}(1,:);
                newR(iTriali,:) = sbd.EyeLocReSPol{iTrial}(2,:);
                newX(iTriali,:) = sbd.EyeLocReSXY{iTrial}(1,:);
                newY(iTriali,:) = sbd.EyeLocReSXY{iTrial}(2,:);
            end
            
            if length(datas(AngIndices == iSeg))>1
                newXAve = mean(newX);
                newYAve = mean(newY);
                newXStd = std(newX);
                newYStd = std(newY);
                newTStd = std(newT);
                newRStd = std(newR);
            else
                newXAve = newX;
                newYAve = newY;
                newXStd = zeros(size(newXAve));
                newYStd = zeros(size(newXAve));
                newTStd = zeros(size(newXAve));
                newRStd = zeros(size(newXAve));
            end
            [newTAve,newRAve] = cart2pol(newXAve,newYAve);
            sbd.TraceAve{iGroup}{iCondI,iSeg} = [newXAve;newYAve;newTAve;newRAve];
            sbd.TraceStd{iGroup}{iCondI,iSeg} = [newXStd;newYStd;newTStd;newRStd];
            p1 = polarplot(newTAve,newRAve,'LineWidth',1,'Color',colorRGB(iCondI,:));
            hold on
            % p2 = polarplot(newTAve+newTStd,newRAve,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
            % p3 = polarplot(newTAve-newTStd,newRAve,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
            % plot(newXAve,newYAve,'LineWidth',1,'Color',colorRGB(iCondI,:))
        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([0,10])
    end
    hold off
    sgtitle([TitleName{iGroup}, userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iGroup},CondName,'Subj_', userID,'.fig'])
end


%% Try to normalize 1
% iCondI = 0;
% iFigAcc = iFigAcc+1;
% figure(iFigAcc)
% set(gcf,'Position',[-1919 228 1486 651]);
sbd.EyeTraDeCur1 = {cell(length(CondI),SegNum),cell(length(CondI),SegNum),cell(length(CondI),SegNum)};

SaveName = [];
SaveName = {'/EyeTra_Norm1_Ending','/EyeTra_Norm1_Initial','/EyeTra_Norm1_Target'};

TitleName = [];
TitleName = {'Grouped by Saccade End, Subtraction Normalization, ',...
    'Grouped by Saccade Initial, Subtraction Normalization, ',...
    'Grouped by Target Location, Subtraction Normalization, '};

for iGroup = 1:3
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    for iCond = CondI
        nexttile
        iCondI = iCondI+1;
        if iCondI == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas = [];
        AngIndices = [];
        datas = find([Dataf1.TarDir] == iCond);
        % AngIndices = discretize(sbd.SacAllDir(datas), AngLinspace);
        AngIndices = sbd.AngIndc(datas);
        for iSeg = 1:SegNum
            EyeLocCart = [];
            EyeLocPolr = [];
            EyeLocThtNew = [];
            TangAng = [];
            OverAllAng = [];
            if isempty(sbd.TraceAve{iGroup}{iCondI,iSeg})
                continue
            end
            EyeLocCart = sbd.TraceAve{iGroup}{iCondI,iSeg}(1:2,:);
            EyeLocPolr = sbd.TraceAve{iGroup}{iCondI,iSeg}(3:4,:);
            if iCondI == 1
                TangAngBase(iSeg,:) = EyeLocPolr(1,:);
            end
            EyeLocThtNew = wrapToPi(EyeLocPolr(1,:)-TangAngBase(iSeg,:));
            sbd.EyeTraDeCur1{iGroup}{iCondI,iSeg} = [EyeLocThtNew;EyeLocPolr(2,:)];
            p1 = polarplot(EyeLocThtNew,EyeLocPolr(2,:),'LineWidth',1,'Color',colorRGB(iCondI,:));
            hold on
        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([0,10])
    end
    hold off
    sgtitle([TitleName{iGroup}, userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iGroup},CondName,'Subj_', userID,'.fig'])
end

%% Try to normalize 1, Averaging and Velocity
% iCondI = 0;
% iFigAcc = iFigAcc+1;
% figure(iFigAcc)
% set(gcf,'Position',[-1919 228 1486 651]);
SaveName = [];
SaveName = {'/EyeTra_Norm1_Ave_Ending','/EyeTra_Norm1_Ave_Initial','/EyeTra_Norm1_Ave_Target'};

TitleName = [];
TitleName = {'Grouped by Saccade End, Subtraction Normalization, Averaging, ',...
    'Grouped by Saccade Initial, Subtraction Normalization, Averaging, ',...
    'Grouped by Target Location, Subtraction Normalization, Averaging, '};
iCondIAll = [1,2,3,4;1,5,6,7];

sbd.EyeTraDeCur1Ave = {cell(1,length(CondI)),cell(1,length(CondI)),cell(1,length(CondI))};

for iGroup = 1:3
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    for iDir = 1:2 % two Direction
        nexttile
        iCondIi = 0;
        for iCond = CondIComp1(iDir,:)
            iCondIi = iCondIi+1;
            iCondI = iCondIAll(iDir,iCondIi);
            datas = [];
            AngIndices = [];
            datas = find([Dataf1.TarDir] == iCond);
            % AngIndices = discretize(sbd.SacAllDir(datas), AngLinspace);
            AngIndices = sbd.AngIndc(datas);
            EyeLocT = []; EyeLocTAve = []; EyeLocXAve = [];
            EyeLocR = []; EyeLocRAve = []; EyeLocYAve = [];
            for iSeg = 1:SegNum
                if isempty(sbd.EyeTraDeCur1{iGroup}{iCondI,iSeg})
                    continue
                end
                EyeLocT(iSeg,:) = sbd.EyeTraDeCur1{iGroup}{iCondI,iSeg}(1,:);
                EyeLocR(iSeg,:) = sbd.EyeTraDeCur1{iGroup}{iCondI,iSeg}(2,:);
            end
            EyeLocTAve = mean(EyeLocT);
            EyeLocRAve = mean(EyeLocR);
            [EyeLocXAve,EyeLocYAve] = pol2cart(EyeLocTAve,EyeLocRAve);
            sbd.EyeTraDeCur1Ave{iGroup}{iCondI} = [EyeLocXAve;EyeLocYAve;EyeLocTAve;EyeLocRAve];
            p1 = polarplot(EyeLocTAve,EyeLocRAve,'LineWidth',1.5,'Color',colorRGB(iCondI,:));
            hold on            
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        % legend(LegText{CondIComp1(iDir,:)},'Box','off')
        set(gca,'FontSize',14)
        rlim([0,8])
        thetalim([-30 30])
    end
    
    sgtitle([TitleName{iGroup}, userID],'FontSize',15)
    % saveas(gcf,[ResultDir,SaveName{iGroup},CondName,'Subj_', userID,'.fig'])
end

%% Try to normalize 1, Averaging and Velocity
% iCondI = 0;
% iFigAcc = iFigAcc+1;
% figure(iFigAcc)
% set(gcf,'Position',[-1919 228 1486 651]);
SaveName = [];
SaveName = {'/EyeTra_Norm1_Ave_Vel_Ending','/EyeTra_Norm1_Ave_Vel_Initial','/EyeTra_Norm1_Ave_Vel_Target'};

TitleName = [];
TitleName = {'Grouped by Saccade End, Subtraction Normalization, Averaging, Velocity ',...
    'Grouped by Saccade Initial, Subtraction Normalization, Averaging, Velocity ',...
    'Grouped by Target Location, Subtraction Normalization, Averaging, Velocity '};
iCondIAll = [1,2,3,4;1,5,6,7];

for iGroup = 1:3
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    for iDir = 1:2 % two Direction
        nexttile
        iCondIi = 0;
        for iCond = CondIComp1(iDir,:)
            iCondIi = iCondIi+1;
            iCondI = iCondIAll(iDir,iCondIi);
            datas = [];
            datas = find([Dataf1.TarDir] == iCond);
            % AngIndices = discretize(sbd.SacAllDir(datas), AngLinspace);
            EyeLocTAve = []; EyeLocXAve = [];
            EyeLocRAve = []; EyeLocYAve = [];
            EyeLocDis = [];
            EyeLocDisVel = [];
            dx = []; dy = [];

            EyeLocTAve = sbd.EyeTraDeCur1Ave{iGroup}{iCondI}(3,:);
            EyeLocRAve = sbd.EyeTraDeCur1Ave{iGroup}{iCondI}(4,:);
            EyeLocXAve = sbd.EyeTraDeCur1Ave{iGroup}{iCondI}(1,:);
            EyeLocYAve = sbd.EyeTraDeCur1Ave{iGroup}{iCondI}(2,:);

            % EyeLocDis = cumsum([0,sqrt((EyeLocXAve(2:end) - EyeLocXAve(1:end-1)).^2 ...
            %     + (EyeLocYAve(2:end) - EyeLocYAve(1:end-1)).^2)]);
            % EyeLocDisVel = diff(EyeLocDis)*1000;
            dx = diff(EyeLocXAve);
            dy = diff(EyeLocYAve);
            EyeLocDisVel = sqrt(dx.^2+dy.^2)*1000;
            % p1 = polarplot(EyeLocTAve,EyeLocRAve,'LineWidth',1.5,'Color',colorRGB(iCondI,:));
            plot(1:length(EyeLocDisVel),EyeLocDisVel,'LineWidth',1.5,'Color',colorRGB(iCondI,:))
            hold on            
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        % legend(LegText{CondIComp1(iDir,:)},'Box','off')
        set(gca,'FontSize',14)
    end
    sgtitle([TitleName{iGroup}, userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iGroup},CondName,'Subj_', userID,'.fig'])
end

% %% Try to normalize 2 I will think about this later
% TangAngBase = [];
% for iGroup = 1:3
%     iCondI = 0;
%     iFigAcc = iFigAcc+1;
%     figure(iFigAcc)
%     set(gcf,'Position',[-1919 228 1486 651]);
%     for iCond = CondI
%         nexttile
%         iCondI = iCondI+1;
%         if iCondI == 5
%             set(gca, 'Visible', 'off'); % This hides the (2,1) tile
%             nexttile; % This creates the (2,1) tile
%         end
%         datas = [];
%         AngIndices = [];
%         EyeLocTht = [];
%         EyeLocRad = [];
% 
%         datas = find([Dataf1.TarDir] == iCond);
%         % AngIndices = discretize(sbd.SacAllDir(datas), AngLinspace);
%         AngIndices = sbd.AngIndc(datas);
% 
%         for iSeg = 1:SegNum
%             EyeLocCart = [];
%             EyeLocPolr = [];
%             EyeLocThtNew = [];
%             OverAllAng = [];
%             dx = [];
%             dy = [];
%             TangAng = [];
%             OverAllAng = [];
%             if isempty(sbd.TraceAve{iGroup}{iCondI,iSeg})
%                 continue
%             end
%             EyeLocCart = sbd.TraceAve{iGroup}{iCondI,iSeg}(1:2,:);
%             EyeLocPolr = sbd.TraceAve{iGroup}{iCondI,iSeg}(3:4,:);
%             % Calculate differences (discrete derivatives)
%             dx = diff(smooth(EyeLocCart(1,:))');
%             dy = diff(smooth(EyeLocCart(2,:))');
%             TangAng = atan2(dy, dx);
%             OverAllAng = EyeLocPolr(1,end);
% 
%             if iCondI == 1
%                 TangAngBase(iSeg,:) = TangAng;
%             end
% 
%             % TangAngNew = wrapToPi(TangAng-TangAngBase(iSeg,:));
%             % EyeLocThtNew = wrapToPi([0,cumsum(TangAngNew)+0]);
%             % EyeLocThtNew = [0,TangAngNew];
%             EyeLocThtNew = [0,TangAng./TangAngBase(iSeg,:).*OverAllAng];
%             p1 = polarplot(EyeLocThtNew,EyeLocPolr(2,:),'LineWidth',1,'Color',colorRGB(iCondI,:));
% 
%             hold on
%         end
%         hold off
%         title(LegText{iCond+1},'FontWeight','normal')
%         set(gca,'FontSize',14)
%         rlim([0, 10])
%     end
% end
