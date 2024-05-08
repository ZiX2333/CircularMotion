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
% Adjusted on Apr 17, two tilted effect ploting and ellipse fitting
%                     Also check the initial eye location

%% Txt information
global iniT LegText colorRGB colorRGB1 colorRGB2 rScalar
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
Rlim3 = [0,2];

%% 1 Plot the KDE on saccade directions
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iCond = 0;
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacDir2CKDE';

    TitleName = []; TitleName = [];
    TitleName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    % TitleName2 = 'SacDirKLdiver kernel: 0.3 rad, step: 5 deg';

    StepSZ = deg2rad(2); % the size of step
    fSigma = 0.3;
    vfEstimate = [];
    klDivg = [];

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = [];
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EyeEndTta = zeros(size(datas1));
        EyeEndTta = wrapTo2Pi(sbd.SacEndTR(1,datas1));
        vfPDFSamples = 0:StepSZ:2*pi;
        vfEstimate(iCond,:) = circ_ksdensity(EyeEndTta, vfPDFSamples, [0, 2*pi], fSigma);
        p1 = polarplot(vfPDFSamples,vfEstimate(iCond,:),'LineWidth',1,'Color',colorRGB(iCond,:));
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([0, 0.5])
    end
    sbd.vfEstimate = vfEstimate;
    sbd.vfPDFSamples = vfPDFSamples;
    sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 plot the KL divergence
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacDir2CKL';

    TitleName = [];
    % TitleName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    TitleName = 'SacDirKLdiver kernel: 0.3 rad, step: 5 deg';

    klDivg = [];
    vfPDFSamples = sbd.vfPDFSamples;

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        vfEstimate2 = []; vfEstimate2 = sbd.vfEstimate(iCond,:);
        vfEstimate1 = []; vfEstimate1 = sbd.vfEstimate(1,:);
        klDivg(iCond,:) = circ_kldivergence(vfEstimate2,vfEstimate1,vfPDFSamples);
        p2 = polarplot(vfPDFSamples,klDivg(iCond,:),'LineWidth',1,'Color',colorRGB(iCond,:));
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-0.15,0.3])
        hold on
    end
    sbd.klDivg = klDivg;
    sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 3 plot the KL divergence across conditions
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacDir2CKLCrossCondi';

    TitleName = [];
    % TitleName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    TitleName = 'SacDirKLdiver kernel: 0.3 rad, step: 5 deg';
    vfPDFSamples = []; vfPDFSamples = sbd.vfPDFSamples;
    klDivg = []; klDivg = sbd.klDivg;
    for iDir = 1:2
        nexttile
        for iCond = CondIComp(iDir,:)
            % calculate the mean and 95% confidence limit
            % CCW and CW have slightly different calculation ways
            p2 = polarplot(vfPDFSamples,klDivg(iCond,:),'LineWidth',1,'Color',colorRGB(iCond,:));
            hold on
        end
        hold off
        title(CondICompName{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-0.15,0.3])
    end
    sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 4 check the initial eye location
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/EyeIniLoc';

    TitleName = [];
    % TitleName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    TitleName = 'Eye Initial Location When Saccade Onset';

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = [];
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EyeIniPolar = zeros(2,length(datas1));
        EyeIniPolar = sbd.SacIniTR(:,datas1);

        F_PolarScat(EyeIniPolar(1,:), EyeIniPolar(2,:), iCond, Rlim3)

        title(LegText{iCond},'FontWeight','normal')
    end
    sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 5 Eye End Location to Center and Fitted Ellipse
rScalar = 1;
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2C_FitOval';

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
        % I need to plot on the xy coordinates
        [XV,YV] = pol2cart(ThetaV,RhoV+rScalar);

        F_CartScat(XV, YV, iCond, [-2,2],  [-2,2]);
        axis square
        
        hold on
        % plot the fixation point
        plot(0,0,'k','Marker','+','MarkerSize',10,'LineWidth',1.5)
        error_ellipseJPM([XV' YV'], 0.68, 'k');
        fit_ellipse(XV,YV,'k')
        F_CartAveStd2(RhoV',iCond,[-2,2],[-2,2],2,0)
        hold off
        
        % set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin')
        xticks([-2 -1 0 1 2]);
        xticklabels({'1', '0', '-1', '0', '1'});
        yticks([-2 -1 0 1 2]);
        yticklabels({'1', '0', '-1', '0', '1'});

        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

