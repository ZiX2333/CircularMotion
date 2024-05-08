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
LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';
CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondIComp1 = [0,1,3,5; 0,2,4,6]; % When I want to compare with stationary
iCondIAll = [1,2,3,4;1,5,6,7];
CondIComp1Name = {'CCW','CW'};
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

%% 1 Plot the KDE on saccade directions
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacAllDirKDE';

    TiteName = []; TiteName = [];
    TiteName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    % TiteName2 = 'SacDirKLdiver kernel: 0.3 rad, step: 5 deg';

    StepSZ = deg2rad(2); % the size of step
    fSigma = 0.3;
    vfEstimate = [];
    klDivg = [];
    for iCond = CondI
        nexttile
        iCondI = iCondI+1;
        if iCondI == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = [];
        datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EyeEndTta = zeros(size(datas1));
        iTriali = 0;
        for iTrial = datas1
            iTriali = iTriali+1;
            % EyeLocPol = [];
            % EyeLocPol = sbd.EyeLocMovPol{iTrial};
            EyeEndTta(iTriali) = wrapTo2Pi(sbd.SacAllDir(iTrial));
            % EyeEndTta(iTriali) = wrapTo2Pi(sbd.SacEndTR(1,iTrial));
        end
        vfPDFSamples = 0:StepSZ:2*pi;
        vfEstimate(iCondI,:) = circ_ksdensity(EyeEndTta, vfPDFSamples, [0, 2*pi], fSigma);
        p1 = polarplot(vfPDFSamples,vfEstimate(iCondI,:),'LineWidth',1,'Color',colorRGB(iCondI,:));
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([0, 0.5])
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 plot the KL divergence
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacAllDirKL';

    TiteName = [];
    % TiteName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    TiteName = 'SacDirKLdiver kernel: 0.3 rad, step: 5 deg';

    StepSZ = deg2rad(2); % the size of step
    klDivg = [];

    for iCond = CondI
        nexttile
        iCondI = iCondI+1;
        if iCondI == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        vfPDFSamples = 0:StepSZ:2*pi;
        klDivg(iCondI,:) = circ_kldivergence(vfEstimate(iCondI,:),vfEstimate(1,:),vfPDFSamples);
        p2 = polarplot(vfPDFSamples,klDivg(iCondI,:),'LineWidth',1,'Color',colorRGB(iCondI,:));
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-0.2,0.3])
        hold on
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 3 plot the KL divergence across conditions
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacAllDirKLCrossCondi';

    TiteName = [];
    % TiteName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    TiteName = 'SacDirKLdiver kernel: 0.3 rad, step: 5 deg';

    StepSZ = deg2rad(2); % the size of step
    KlDAveAng = zeros(length(CondI),2); % first column is left, second column is right
    KlDStdAng = zeros(length(CondI),2); % Standard deviation

    for iDir = 1:2
        nexttile
        ImRegret = 0; % Why I set the condition like this?
        for iCond = CondIComp1(iDir,:)
            % calculate the mean and 95% confidence limit
            % CCW and CW have slightly different calculation ways
            ImRegret = ImRegret+1;
            iCondI = iCondIAll(iDir,ImRegret);

            p2 = polarplot(vfPDFSamples,klDivg(iCondI,:),'LineWidth',1,'Color',colorRGB(iCondI,:));
            hold on
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-0.2,0.3])
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 4 plot the saccade ending error as target end location add the moving averaging
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacEndErr_TarLoc';

    TiteName = [];
    TiteName = 'Sacc Ending Error Distribution as Target Location';

    % Define the angular range of the window (in radians)
    winRange = pi/3;  % 60 degrees (pi/3 radians)
    % Define the step size for sliding the window (in radians)
    stepSize = pi/18;  % 10 degrees (pi/18 radians)

    RadioAxis = sbd.SacEndErrAng2CSign2;
    ThetaAxis = sbd.SacAllDir;

    SacEndErrPolarAll

    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 5 Before Zscore, normalized by stationary condition
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacEndErr_TarLoc_BaseSta';

    TiteName = [];
    TiteName = 'Sacc Ending Error Distribution as Target Location, based on Stationary';
    SacEndErrAveDeCen = SacEndErrAve;

    for iDir = 1:2
        nexttile
        ImRegret = 0; % Why I set the condition like this?
        for iCond = CondIComp1(iDir,:)
            % calculate the mean and 95% confidence limit
            % CCW and CW have slightly different calculation ways
            ImRegret = ImRegret+1;
            iCondI = iCondIAll(iDir,ImRegret);
            if iDir == 1
                SacEndErrAveDeCen{iCondI} = SacEndErrAve{iCondI} - SacEndErrAve{1};
            elseif iDir == 2 && iCondI ~=1
                SacEndErrAveDeCen{iCondI} = SacEndErrAve{iCondI} + SacEndErrAve{1};
            end
            AveDir = []; AveRad = []; StdRad = [];
            AveDir = EyeEndTtaAve{iCondI};
            AveRad = SacEndErrAveDeCen{iCondI};
            StdRad = SacEndErrStd{iCondI};
            p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB(iCondI,:),'LineStyle','-');
            hold on
            % p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
            % p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-2,2])
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 6 saccade ending error Zscore the data first
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacEndErrZsc_TarLoc';

    TiteName = [];
    TiteName = 'Sacc Ending Error Zscore Distribution as Target Location';

    % Define the angular range of the window (in radians)
    winRange = pi/3;  % 60 degrees (pi/3 radians)
    % Define the step size for sliding the window (in radians)
    stepSize = pi/18;  % 10 degrees (pi/18 radians)

    RadioAxis = sbd.SacEndErrAng2CSign2;
    ThetaAxis = sbd.SacAllDir;

    SacEndErrPolarAllZscore
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 7 after Zscore, normalized by stationary condition
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacEndErrZsc_TarLoc_BaseSta';

    TiteName = [];
    TiteName = 'Sacc Ending Error Zscore Distribution as Target Location, based on Stationary';
    SacEndErrAveDeCenZS = SacEndErrAveZS;

    for iDir = 1:2
        nexttile
        ImRegret = 0; % Why I set the condition like this?
        for iCond = CondIComp1(iDir,:)
            % calculate the mean and 95% confidence limit
            % CCW and CW have slightly different calculation ways
            ImRegret = ImRegret+1;
            iCondI = iCondIAll(iDir,ImRegret);
            if iDir == 1
                SacEndErrAveDeCenZS{iCondI} = SacEndErrAveZS{iCondI} - SacEndErrAveZS{1};
            elseif iDir == 2 && iCondI ~=1
                SacEndErrAveDeCenZS{iCondI} = SacEndErrAveZS{iCondI} + SacEndErrAveZS{1};
            end
            AveDir = []; AveRad = []; StdRad = [];
            AveDir = EyeEndTtaAveZS{iCondI};
            AveRad = SacEndErrAveDeCenZS{iCondI};
            StdRad = SacEndErrStdZS{iCondI};
            p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB(iCondI,:),'LineStyle','-');
            hold on
            % p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
            % p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-2,2])
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 8 plot the saccade Initial error as target end location add the moving averaging
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacIniErr_TarLoc';

    TiteName = [];
    TiteName = 'Sacc Initial Error Distribution as Target Location';

    % Define the angular range of the window (in radians)
    winRange = pi/3;  % 60 degrees (pi/3 radians)
    % Define the step size for sliding the window (in radians)
    stepSize = pi/18;  % 10 degrees (pi/18 radians)

    for iCond = CondI
        nexttile
        iCondI = iCondI+1;
        if iCondI == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = [];
        datas1 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5);
        SacIniErr = [];
        % TarLocEnd = zeros(size(datas1));
        SacIniErr = sbd.SacIniErrAng2ESign(datas1);
        % for iTriali = 1:length(datas1)
        %     TarLocEnd(iTriali) = Dataf1(datas1(iTriali)).SacTarGoc1(end,3);
        % end
        EyeEndTta = zeros(size(datas1));
        iTriali = 0;
        for iTrial = datas1
            iTriali = iTriali+1;
            % EyeLocPol = [];
            % EyeLocPol = sbd.EyeLocMovPol{iTrial};
            EyeEndTta(iTriali) = wrapTo2Pi(sbd.SacAllDir(iTrial));
        end

        % Initialize vectors to hold the moving average results
        AveDir = [];
        AveRad = [];
        StdRad = [];

        % Define the start and end points of the moving window
        for startAngle = 0:stepSize:2*pi
            endAngle = startAngle + winRange;

            % Find the indices of theta that fall within the current window
            if endAngle > 2*pi
                winIndices = EyeEndTta >= startAngle & EyeEndTta <= 2*pi |...
                    EyeEndTta < wrapTo2Pi (endAngle) & EyeEndTta >= 0;
            else
                winIndices = EyeEndTta >= startAngle & EyeEndTta < endAngle;
            end
            winTheta = EyeEndTta(winIndices);
            winRadi = SacIniErr(winIndices);

            % Skip if no data points fall within the window range
            if isempty(winTheta)
                continue;
            end

            AveDir1 = [];
            AveRad1 = [];
            % Calculate mean direction for the window
            AveDir1 = circ_mean(winTheta');

            % Calculate mean vector length for the window
            AveRad1 = mean(winRadi);
            StdRad1 = std(winRadi);

            % Store the results
            AveDir = [AveDir AveDir1];
            AveRad = [AveRad AveRad1];
            StdRad = [StdRad StdRad1];
        end

        EyeEndTtaAve{iCondI} = AveDir;
        SacIniErrAve{iCondI} = AveRad;
        SacIniErrStd{iCondI} = StdRad;

        p1 = polarscatter(EyeEndTta,SacIniErr,'MarkerFaceColor',colorRGB(iCondI,:),'MarkerEdgeColor','none',...
            'MarkerFaceAlpha',0.5);
        % p1 = polarscatter(EyeEndTta,SacIniErr,'MarkerEdgeColor',colorRGB(iCondI,:),'LineWidth',1);
        hold on
        p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB2(iCondI,:),'LineStyle','-');
        p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB2(iCondI,:),'LineStyle','--');
        p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB2(iCondI,:),'LineStyle','--');
        p3 = polarplot(0:stepSize/10:2*pi,zeros(size(0:stepSize/10:2*pi)),'LineWidth',1,'Color','k','LineStyle','--');
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-1,1])
        hold off
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 9 Before Zscore, normalized by stationary condition
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacIniErr_TarLoc_BaseSta';

    TiteName = [];
    TiteName = 'Sacc Initial Error Distribution as Target Location, based on Stationary';
    SacIniErrAveDeCen = SacIniErrAve;

    for iDir = 1:2
        nexttile
        ImRegret = 0; % Why I set the condition like this?
        for iCond = CondIComp1(iDir,:)
            % calculate the mean and 95% confidence limit
            % CCW and CW have slightly different calculation ways
            ImRegret = ImRegret+1;
            iCondI = iCondIAll(iDir,ImRegret);
            if iDir == 1
                SacIniErrAveDeCen{iCondI} = SacIniErrAve{iCondI} - SacIniErrAve{1};
            elseif iDir == 2 && iCondI ~=1
                SacIniErrAveDeCen{iCondI} = SacIniErrAve{iCondI} + SacIniErrAve{1};
            end
            AveDir = []; AveRad = []; StdRad = [];
            AveDir = EyeEndTtaAve{iCondI};
            AveRad = SacIniErrAveDeCen{iCondI};
            StdRad = SacIniErrStd{iCondI};
            p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB(iCondI,:),'LineStyle','-');
            hold on
            % p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
            % p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-1,1])
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 10 saccade Initial error Zscore the data first
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacIniErrZsc_TarLoc';

    TiteName = [];
    TiteName = 'Sacc Initial Error Zscore Distribution as Target Location';

    % Define the angular range of the window (in radians)
    winRange = pi/3;  % 60 degrees (pi/3 radians)
    % Define the step size for sliding the window (in radians)
    stepSize = pi/18;  % 10 degrees (pi/18 radians)

    for iCond = CondI
        nexttile
        iCondI = iCondI+1;
        if iCondI == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = [];
        datas1 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5);
        SacIniErr = []; 
        SacIniErr = sbd.SacIniErrAng2ESign(datas1);
        % TarLocEnd = zeros(size(datas1));
        SacIniErr = zscore(SacIniErr(~isnan(SacIniErr)));
        % for iTriali = 1:length(datas1)
        %     TarLocEnd(iTriali) = Dataf1(datas1(iTriali)).SacTarGoc1(end,3);
        % end
        EyeEndTta = zeros(size(datas1));
        iTriali = 0;
        for iTrial = datas1
            iTriali = iTriali+1;
            % EyeLocPol = [];
            % EyeLocPol = sbd.EyeLocMovPol{iTrial};
            EyeEndTta(iTriali) = wrapTo2Pi(sbd.SacAllDir(iTrial));
        end
        EyeEndTta = EyeEndTta(~isnan(sbd.SacIniErrAng2ESign(datas1)));

        % Initialize vectors to hold the moving average results
        AveDir = [];
        AveRad = [];
        StdRad = [];

        % Define the start and end points of the moving window
        for startAngle = 0:stepSize:2*pi
            endAngle = startAngle + winRange;

            % Find the indices of theta that fall within the current window
            if endAngle > 2*pi
                winIndices = EyeEndTta >= startAngle & EyeEndTta <= 2*pi |...
                    EyeEndTta < wrapTo2Pi (endAngle) & EyeEndTta >= 0;
            else
                winIndices = EyeEndTta >= startAngle & EyeEndTta < endAngle;
            end
            winTheta = EyeEndTta(winIndices);
            winRadi = SacIniErr(winIndices);

            % Skip if no data points fall within the window range
            if isempty(winTheta)
                continue;
            end

            AveDir1 = [];
            AveRad1 = [];
            % Calculate mean direction for the window
            AveDir1 = circ_mean(winTheta');

            % Calculate mean vector length for the window
            AveRad1 = mean(winRadi);
            StdRad1 = std(winRadi);

            % Store the results
            AveDir = [AveDir AveDir1];
            AveRad = [AveRad AveRad1];
            StdRad = [StdRad StdRad1];
        end

        EyeEndTtaAveZS{iCondI} = AveDir;
        SacIniErrAveZS{iCondI} = AveRad;
        SacIniErrStdZS{iCondI} = StdRad;

        p1 = polarscatter(EyeEndTta,SacIniErr,'MarkerFaceColor',colorRGB(iCondI,:),'MarkerEdgeColor','none',...
            'MarkerFaceAlpha',0.5);
        % p1 = polarscatter(EyeEndTta,SacIniErr,'MarkerEdgeColor',colorRGB(iCondI,:),'LineWidth',1);
        hold on
        p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB2(iCondI,:),'LineStyle','-');
        p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB2(iCondI,:),'LineStyle','--');
        p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB2(iCondI,:),'LineStyle','--');
        p3 = polarplot(0:stepSize/10:2*pi,zeros(size(0:stepSize/10:2*pi)),'LineWidth',1,'Color','k','LineStyle','--');
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-2,2])
        hold off
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 11 after Zscore, normalized by stationary condition
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacIniErrZsc_TarLoc_BaseSta';

    TiteName = [];
    TiteName = 'Sacc Initial Error Zscore Distribution as Target Location, based on Stationary';
    SacIniErrAveDeCenZS = SacIniErrAveZS;

    for iDir = 1:2
        nexttile
        ImRegret = 0; % Why I set the condition like this?
        for iCond = CondIComp1(iDir,:)
            % calculate the mean and 95% confidence limit
            % CCW and CW have slightly different calculation ways
            ImRegret = ImRegret+1;
            iCondI = iCondIAll(iDir,ImRegret);
            if iDir == 1
                SacIniErrAveDeCenZS{iCondI} = SacIniErrAveZS{iCondI} - SacIniErrAveZS{1};
            elseif iDir == 2 && iCondI ~=1
                SacIniErrAveDeCenZS{iCondI} = SacIniErrAveZS{iCondI} + SacIniErrAveZS{1};
            end
            AveDir = []; AveRad = []; StdRad = [];
            AveDir = EyeEndTtaAveZS{iCondI};
            AveRad = SacIniErrAveDeCenZS{iCondI};
            StdRad = SacIniErrStdZS{iCondI};
            p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB(iCondI,:),'LineStyle','-');
            hold on
            % p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
            % p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-2,2])
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 12 plot the saccade ending error as target end location add the moving averaging
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacEndErr_TarLoc_2C';

    TiteName = [];
    TiteName = 'Sacc Ending Error Distribution as Target Location, Target';

    % Define the angular range of the window (in radians)
    winRange = pi/3;  % 60 degrees (pi/3 radians)
    % Define the step size for sliding the window (in radians)
    stepSize = pi/18;  % 10 degrees (pi/18 radians)

    RadioAxis = sbd.SacEndErrAng2CSign2;
    ThetaAxis = sbd.SacAllDir;

    SacEndErrPolarAll

    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 13 Before Zscore, normalized by stationary condition
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacEndErr_TarLoc_BaseSta_2C';

    TiteName = [];
    TiteName = 'Sacc Ending Error Distribution as Target Location, based on Stationary';
    SacEndErrAveDeCen = SacEndErrAve;

    for iDir = 1:2
        nexttile
        ImRegret = 0; % Why I set the condition like this?
        for iCond = CondIComp1(iDir,:)
            % calculate the mean and 95% confidence limit
            % CCW and CW have slightly different calculation ways
            ImRegret = ImRegret+1;
            iCondI = iCondIAll(iDir,ImRegret);
            if iDir == 1
                SacEndErrAveDeCen{iCondI} = SacEndErrAve{iCondI} - SacEndErrAve{1};
            elseif iDir == 2 && iCondI ~=1
                SacEndErrAveDeCen{iCondI} = SacEndErrAve{iCondI} + SacEndErrAve{1};
            end
            AveDir = []; AveRad = []; StdRad = [];
            AveDir = EyeEndTtaAve{iCondI};
            AveRad = SacEndErrAveDeCen{iCondI};
            StdRad = SacEndErrStd{iCondI};
            p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB(iCondI,:),'LineStyle','-');
            hold on
            % p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
            % p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-2,2])
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 14 saccade ending error Zscore the data first
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacEndErrZsc_TarLoc_2C';

    TiteName = [];
    TiteName = 'Sacc Ending Error Zscore Distribution as Target Location';

    % Define the angular range of the window (in radians)
    winRange = pi/3;  % 60 degrees (pi/3 radians)
    % Define the step size for sliding the window (in radians)
    stepSize = pi/18;  % 10 degrees (pi/18 radians)

    RadioAxis = sbd.SacEndErrAng2CSign2;
    ThetaAxis = sbd.SacAllDir;

    SacEndErrPolarAllZscore
    
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 15 after Zscore, normalized by stationary condition
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCondI = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacEndErrZsc_TarLoc_BaseSta_2C';

    TiteName = [];
    TiteName = 'Sacc Ending Error Zscore Distribution as Target Location, based on Stationary';
    SacEndErrAveDeCenZS = SacEndErrAveZS;

    for iDir = 1:2
        nexttile
        ImRegret = 0; % Why I set the condition like this?
        for iCond = CondIComp1(iDir,:)
            % calculate the mean and 95% confidence limit
            % CCW and CW have slightly different calculation ways
            ImRegret = ImRegret+1;
            iCondI = iCondIAll(iDir,ImRegret);
            if iDir == 1
                SacEndErrAveDeCenZS{iCondI} = SacEndErrAveZS{iCondI} - SacEndErrAveZS{1};
            elseif iDir == 2 && iCondI ~=1
                SacEndErrAveDeCenZS{iCondI} = SacEndErrAveZS{iCondI} + SacEndErrAveZS{1};
            end
            AveDir = []; AveRad = []; StdRad = [];
            AveDir = EyeEndTtaAveZS{iCondI};
            AveRad = SacEndErrAveDeCenZS{iCondI};
            StdRad = SacEndErrStdZS{iCondI};
            p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB(iCondI,:),'LineStyle','-');
            hold on
            % p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
            % p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        end
        hold off
        title(CondIComp1Name{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-2,2])
    end
    sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end
