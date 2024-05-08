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
% Adjusted on Feb 16, A new analysis way, start with saccade tilting
% Adjusted on Mar 15, New analysis implanted

%% Txt information
global iniT LegText colorRGB colorRGB1 colorRGB2
LegText = [{'Stationary'},{'CCW 15'},{'CCW 30'},{'CCW 45'},{'CW 15'},{'CW 30'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';

% CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
CondIComp = [1,2,3,4; 1,5,6,7]; % When I want to compare with stationary
CondICompName = {'CCW','CW'};
CondName = '_1';

ifDoBasic = 1;

%% basic settings
if ifDoBasic
    % mkdir(ResultDir);

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

    %% PreProcessed of data
    Dataf1 = Dataf; % All trials only with labels
    Dataf2 = Dataf; % delete droped trials

    % % remove Dataf that TrialStatus ~=1
    % Dataf1([Dataf.TrialStatus]~=1) = [];
    %
    % % remove trials that peak velocity < 50 deg/sec
    % Dataf1([Dataf1.SacPvelGoc1]<50) = [];

    % remove RT < 80ms, duration >=150ms, start radius >=4, end radius <=4,
    % amplitude <3, peak velocity < 50
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
        elseif Dataf1(iTrial).SacTimeGoc2(end,1)<80
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacTimeGoc2(end-1,1)>=150
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacLocGoc2{1}(4,1) >=4
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacLocGoc2{1}(4,end) <=4
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif abs(Dataf1(iTrial).SacLocGoc2{1}(4,end)-Dataf1(iTrial).SacLocGoc2{1}(4,1)) <=3
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

    for iDrop = 1:length(iDrop2)
        Dataf1(iDrop2(iDrop)).TrialStatus = -1; % doesn't apply criteria
    end

    %% behavior analysis
    iniT = 5; % select first 10ms for the first saccade
    [sbd,Dataf1,iDrop4] = BehaviorAna(Dataf1);

    % drop data
    iDropDataf = unique([iDrop1,iDrop2,iDrop4]);
    % iDropDataf2 = unique([iDrop2,iDrop3]);
    Dataf2(iDropDataf) = [];

    % label the idrop 4 trials
    for iDrop = 1:length(iDrop4)
        Dataf1(iDrop4(iDrop)).TrialStatus = -1; % doesn't apply criteria
    end

    % sbdfieldNames = fieldnames(sbd);
    % % Loop through each field and delete the element
    % for iField = 1:length(sbdfieldNames)
    %     field = sbdfieldNames{iField};
    %     sbd.(field)(iDrop4) = [];
    % end
end
iFigAcc = 0;
SecNum = 0;
Rlim1 = [-1.2,1.2];
Rlim2 = [-2,2];

%% 1 plot saccade ending error as target end location scatter, to center, no sign
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2C_Nosign';

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));

        ThetaV = []; RhoV = []; RhoVAve = []; RhoVStd = [];
        ThetaV = sbd.TarEndTR(1,datas1);
        RhoV = sbd.SacEndErrAng2CSign2(datas1);

        F_PolarScat(ThetaV, RhoV,iCond,Rlim1);
        hold on
        [RhoVAve,RhoVStd] = F_PolarAveStd1(RhoV',iCond,Rlim1,2,1);
        hold off

        sbd.SacEEA2CS2_Stat1(1:2,iCond) = [RhoVAve;RhoVStd];
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 plot Raw Eye Traces with line to the target location
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    tiledlayout(2,4);

    SaveName = [];
    SaveName = 'RawEyeTra_EndErrTra';

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        % find all success trials
        datas1 = find([Dataf1.TarDir1] == iCond &([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        for iTrial = datas1
            EyeLoc = sbd.SacTraGoc1{iTrial};
            SacEndTR = sbd.SacEndTR(:,iTrial);
            TarEndTR = sbd.TarEndTR(:,iTrial);
            % Polar Plot
            p1 = polarplot(EyeLoc(3,:),EyeLoc(4,:),'LineWidth',0.6,'Color',colorRGB(iCond,:));
            hold on
            s1 = polarscatter(TarEndTR(1),TarEndTR(2),5,'black','filled');
            s3 = polarplot([SacEndTR(1),TarEndTR(1)],[SacEndTR(2),TarEndTR(2)],'LineWidth',0.7,'Color','k');
        end
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([0, 11])
        hold off

    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 3 vector summation? sliding window vector summation
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    tiledlayout(2,4);

    SaveName = [];
    SaveName = 'EndErrVec_Sum';

    winRange = pi/4;  % 45 degrees (pi/4 radians)
    stepSize = pi/18;  % 10 degrees (pi/18 radians)

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        % find all success trials
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        SacEndXY = sbd.SacEndXY(:,datas1);
        TarEndXY = sbd.TarEndXY(:,datas1);
        TarEndTR = sbd.TarEndTR(:,datas1); ThetaV = wrapTo2Pi(TarEndTR(1,:));
        Sac2TarXY = TarEndXY-SacEndXY;
        % find the summed vector
        [AveXY,VecSum] = F_SlidVecSum(ThetaV,SacEndXY',Sac2TarXY',winRange,stepSize);

        hold on
        for iTrial = datas1
            EyeLoc = sbd.SacTraGoc1{iTrial};
            % Plot Traces
            p1 = plot(EyeLoc(1,:),EyeLoc(2,:),'LineWidth',0.6,'Color',colorRGB1(iCond,:));
        end

        s1 = scatter(TarEndXY(1,:),TarEndXY(2,:),5,'black','filled');
        % Plot Vector and summed vector
        s2 = quiver(SacEndXY(1,:),SacEndXY(2,:),Sac2TarXY(1,:),Sac2TarXY(2,:),'Color',colorRGB(iCond,:),'LineWidth',1);
        s3 = quiver(AveXY(:,1),AveXY(:,2),VecSum(:,1),VecSum(:,2),'Color','k','LineWidth',1);
        hold off
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
        xlim([-10,10]);
        ylim([-10,10]);
        axis square
        % rlim([0, 11])
        hold off
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% Maybe normalized thes quiver location and... worked on vector field?

% Sac2TarNorm = zeros(1,length(Sac2Tar));
%     for iTrial = 1:length(Sac2Tar)
%         Sac2TarNorm(iTrial) = norm(Sac2Tar(:,iTrial));
%     end
%     Sac2Tar = Sac2Tar./Sac2TarNorm;

%% 4 smp velocity versus target location, Polar plot
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SmpVel_TarLoc_polar';
    Rlim1 = [0,50];

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));

        ThetaV = []; SmpV = []; RhoV = [];
        ThetaV = wrapTo2Pi(sbd.TarEndTR(1,datas1));
        RhoV = sbd.SacEndErrAng2CSign2(datas1);
        SmpV = sbd.SmPVelGoc1(datas1);

        F_PolarScat(ThetaV, SmpV,iCond,Rlim1);
        hold on
        [RhoVAve,RhoVStd] = F_PolarAveStd1(SmpV',iCond,Rlim1,1,1);
        hold off

    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 5 smp velocity versus target location, Cartesian
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SmpVel_TarLoc_Cart';
    Xlim1 = [-10,370];
    Ylim1 = [0,50];

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));

        XV = []; YV = [];
        XV = rad2deg(wrapTo2Pi(sbd.TarEndTR(1,datas1)));
        YV = sbd.SmPVelGoc1(datas1);

        F_CartScat(XV, YV,iCond,Xlim1,Ylim1);
        hold on
        [XVAve,XVStd] = F_CartAveStd1(YV',iCond,Xlim1,Ylim1,1,1);
        hold off

    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 6 smp velocity versus Saccade Ending Error, Cartesian
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SmpVel_EndErr';
    Xlim1 = [-1,1];
    Ylim1 = [0,50];

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));

        XV = []; YV = [];
        XV = sbd.SacEndErrAng2CSign2(datas1);
        YV = sbd.SmPVelGoc1(datas1);

        F_CartScat(XV, YV,iCond,Xlim1,Ylim1);
        hold on
        [XVAve,XVStd] = F_CartAveStd1(YV',iCond,Xlim1,Ylim1,1,1);
        hold off

    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end
