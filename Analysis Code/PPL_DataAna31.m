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
% Adjusted on May 08, Focuses on the ending error analysis, especially how
%                     to quantify my results
% Adjusted on May 17, Keep focusing on ending error analysis. Results are
%                     fixation point center now
% Adjusted on July 22, Keep focusing on ending error analysis. Results are
%                     initial eye location center now
% Adjusted on Aug 20, Add new analysis respect to error to target at
%                       different time, also ploted the eye traces 2E
% Adjusted on Aug 27, Check the velocity with ending error
% Adjusted on Sep 23, for some figures that I might used in SFN poster
% Adjusted on Mar 26, I'm tired of always looking for the plots I need...
%                     here is a combination of all the required plots
% Adjusted on Jun 04, Redo the bootstrap ending error and 
%                     KL Divergence for target dir
% Adjusted on Jun 09, tried different ways to do the RT regression
%% Txt information
global iniT LegText colorRGB colorRGB1 colorRGB2 rScalar
LegText = [{'Stationary'},{'CCW 15°/s'},{'CCW 30°/s'},{'CCW 45°/s'},{'CW 15°/s'},{'CW 30°/s'},{'CW 45°/s'}];
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

    % remove RT < 80ms and larger than 400, duration >=150ms, start radius >=4, end radius <=4,
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
        elseif Dataf1(iTrial).SacTimeGoc2(end,1)>400
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
Rlim1 = [-1,1];
Rlim2 = [-2,2];
Rlim3 = [0,2];
rScalar = ceil(deg2rad(30)*10)/10;

%% 1.1 Bootstrap on Err with Targ at Sacc End
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Targ_2E_XY_Norm_BootS';

    winSize = pi/4;
    stepSize = winSize/10;
    % winRange = [-winSize+stepSize, 2*pi-stepSize];
    winRange = [0,2*pi];

    Fig7Ax = gobjects(4,2);

    for iCond = CondI
        Fig7Ax(iCond) = nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            Fig7Ax(iCond) = nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        XV = []; YV = []; XAve = []; YAve = []; YStd = [];
        XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,pi*2);
        YV = sbd.SacEndErrAng2ESignDeSta(datas1);
        
        hold on
        % I need to plot on the xy coordinates
        scatter(XV,YV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');

        % plot the bootstrap sliding window
        SampS = floor(length(XV)*1);
        SacEndErrAngBootS(iCond) = F_BootSCartSlidWin2(XV',YV',SampS,1000,winSize,stepSize,winRange);

        % clean space for the variables
        SampXAveAve = []; SampYAveAve = [];SampYLCI95 = []; SampYUCI95 = [];
        SampYLCI90 = []; SampYUCI90 = []; SampYUCI95Ave = []; SampYLCI95Ave = []; SampYStdErr = [];

        % assign data
        SampXAveAve = []; SampYAveAve = []; SampYLCI95Ave = []; SampYUCI95Ave = [];
        SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve; SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
        SampYLCI95Ave = SacEndErrAngBootS(iCond).SampYLCI95Ave; SampYUCI95Ave = SacEndErrAngBootS(iCond).SampYUCI95Ave;

        % use boundedline to plot which can also skip the nan point
        [hl1,hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
        set(hl1,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
        
        xline(pi/2,'LineWidth',1.5,'LineStyle','--');
        xline(pi,'LineWidth',1.5,'LineStyle','--');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle','--');

        xlim([-pi/18,2*pi+pi/18]);
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        xticklabels({90,180,270,0,90});
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        yticklabels({-45,-30,-15,0,15,30,45});

        if iCond == 1
            xlabel('Targ Direction at Sacc End')
            ylabel('De-Sta-Trend Sacc-Targ End Direction Difference')
        end
        
        hold off

        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 2 add shuffle on the data
% SecNum = SecNum+1;
% % SacEndErrAngShuff = [];
% if ismember(SecNum,SecPlots)
    figure(iFigAcc)
    SaveName = [];
    SaveName = '/SacEndErr_Sac_2E_XY_Norm_BootS_Shuff2';

    % do the shuffling:
    winSize = pi/4;
    stepSize = winSize/10;
    % winRange = [-winSize+stepSize, 2*pi-stepSize];
    winRange = [0, 2*pi];

    for iCond = CondI
        % load data first
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        XV = []; YV = []; XAve = []; YAve = []; YStd = [];
        XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,pi*2);
        YV = sbd.SacEndErrAng2ESignDeSta(datas1);

        SacEndErrAngShuff(iCond) = F_ShuffTest1(XV',YV',1000,winSize,stepSize,winRange);

        ShuffXAveAve = []; ShuffYAveAve = []; ShuffYLCI95Ave = []; ShuffYUCI95Ave = [];
        ShuffXAveAve = SacEndErrAngShuff(iCond).ShuffXAveAve; ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;
        ShuffYLCI95Ave = SacEndErrAngShuff(iCond).ShuffYLCI95Ave; ShuffYUCI95Ave = SacEndErrAngShuff(iCond).ShuffYUCI95Ave;

        hold(Fig7Ax(iCond), 'on')
        % plot(Fig7Ax(iCond), ShuffXAve(1,:),ShuffYAveAve,'k','LineStyle','--','LineWidth',1.5);
        % plot(Fig7Ax(iCond), ShuffXAve(1,:),ShuffYUCI,'k','LineStyle',':','LineWidth',1.5);
        % plot(Fig7Ax(iCond), ShuffXAve(1,:),ShuffYLCI,'k','LineStyle',':','LineWidth',1.5);
        % plot(Fig7Ax(iCond), ShuffXAve(1,:),ShuffYAveAve+ShuffYStdErr,'k','LineStyle','-.','LineWidth',1.5);
        % use boundedline to plot which can also skip the nan point
        [hl,hp] = boundedline(ShuffXAveAve,ShuffYAveAve,[ShuffYLCI95Ave;ShuffYUCI95Ave]',Fig7Ax(iCond));
        set(hl,'color','k','LineStyle','--','LineWidth',1.5);
        set(hp,'FaceColor',[209 209 209]./255,'FaceAlpha',0.6,'EdgeColor','none')
        hold (Fig7Ax(iCond),'off')

        if iCond == 1
            legend(Fig7Ax(iCond),[hl1,hl],{'Moving ave after 1000 bootstrap','Moving ave after 1000 shuffling'},'FontSize',14,'AutoUpdate','off')
        end
    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end


%% 3 label the part above the threshold
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    figure(iFigAcc)
    SaveName = [];
    SaveName = '/SacEndErr_Sac_2E_XY_Norm_BootS_Shuff_Marked';
    for iCond = CondI
        % load the bootstrap result
        SampXAveAve = []; SampYAveAve = [];
        SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
        SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;

        % load the shuffling result
        ShuffXAveAve = []; ShuffYAveAve = []; ShuffYLCI95 = []; ShuffYUCI95 = []; ShuffYLCI90 = []; ShuffYUCI90 = [];
        ShuffXAveAve = SacEndErrAngShuff(iCond).ShuffXAveAve;
        ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;
        ShuffYLCI95 = SacEndErrAngShuff(iCond).ShuffYCI95(1,:);
        ShuffYUCI95 = SacEndErrAngShuff(iCond).ShuffYCI95(2,:);

        % test with 95% and 90%
        % I'm going to write a logic vector 
        Samp2Shuff95 = SampYAveAve >= ShuffYUCI95 | SampYAveAve <= ShuffYLCI95;
        SacEndErrAngShuff(iCond).Samp2Shuff95 = Samp2Shuff95;
        
        % plot in a thicker red line chuncks
        MarkC = [205, 45, 48]/255;
        
        % Find starts and ends of blocks of 95% CI
        starts = find(diff([0, Samp2Shuff95]) == 1);
        ends = find(diff([Samp2Shuff95, 0]) == -1);

        % hold on % why hold on is not working?
        hold(Fig7Ax(iCond), 'on') % hold on certain axis
        % also include the data between starts and starts-1
        for iChunk = 1:length(starts)
            %plot 95% first
            starts(iChunk) = max(1,starts(iChunk));
            ends(iChunk) = min(length(SampXAveAve),ends(iChunk));
            plot(Fig7Ax(iCond),SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
                '-','Color',MarkC,'LineWidth',3);
        end
        hold (Fig7Ax(iCond),'off')
    
    end
    sbd.SacEndErrAngBootS = SacEndErrAngBootS;
    sbd.SacEndErrAngShuff = SacEndErrAngShuff;
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 4 KL-divergence on target location
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);

    SaveName = [];
    SaveName = '/TargDir2EKL';
    TitleName = [];
    % TitleName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    TitleName = 'SacDirKLdiver kernel: 0.3 rad, step: 5 deg';

    klDivgTarg = [];
    vfPDFSamples = sbd.vfPDFSamples;

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        vfEstimate2 = []; vfEstimate2 = sbd.vfEstimateTarg(iCond,:);
        vfEstimate1 = []; vfEstimate1 = sbd.vfEstimateTarg(1,:);
        klDivgTarg(iCond,:) = circ_kldivergence(vfEstimate2,vfEstimate1,vfPDFSamples);
        p2 = polarplot(vfPDFSamples,klDivgTarg(iCond,:),'LineWidth',2,'Color',colorRGB(iCond,:));
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-0.15,0.3])
        hold on
    end
    sbd.klDivgTarg = klDivgTarg;
    % sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 5 Ending error distribution
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);

    SaveName = [];
    SaveName = '/SacEndErrDist';
    TitleName = [];

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        XV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1));
        histogram(XV,'BinWidth',5,'FaceColor',colorRGB(iCond,:),'EdgeColor','none');
        xlim([-60,60])
        xticks(-60:30:60)
        ylim([0,50])
        yticks(0:10:50)
        xline(0,'k--','LineWidth',1.5)
        title(LegText{iCond},'FontWeight','normal','FontSize',15)
        if iCond == 1
            xlabel('Saccade Ending Error, deg')
        end
        set(gca,'FontSize',15)
    end
    % sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 6 Better way to do the RT regression
% I'm using the robust linear regression, which is by itteration to get the
% weight of each points and reduce the effects of outliers
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_SacEndErr2E_RobustLinear';

    RTErrRbstMdl = cell(size(CondI));
    RTErrMdl = cell(size(CondI));

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        YV = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = []; XVZs = [];
        XV = sbd.SacRTGoc1DeSta(datas1);
        YV = sbd.SacEndErrAng2ESignDeSta(datas1);

        hold on
        % I need to plot on the xy coordinates
        YLim = [-pi/4,pi/4]; XLim = [-200,200];
        scatter(XV,YV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
        XDots = linspace(min(XV), max(XV), 100)';
        
        % classic regression fitting
        RTErrMdl{iCond} = fitlm(XV,YV);
        [YPred1, YCI951] = predict(RTErrMdl{iCond}, XDots);
        hline1 = plot(XDots, YPred1,'k--','linewidth',2); 
        r21 = RTErrMdl{iCond}.Rsquared.Ordinary;
        pval1 = RTErrMdl{iCond}.Coefficients.pValue(2);
        legendStr1 = sprintf('Classic: R^2 = %.2f, p = %.2g', r21, pval1);
        
        % Robust regression fitting
        RTErrRbstMdl{iCond} = fitlm(XV,YV,'RobustOpts','on');
        [YPred2, YCI952] = predict(RTErrRbstMdl{iCond}, XDots);
        hline2 = plot(XDots, YPred2,'r--','linewidth',2);  
        % fill([xq; flipud(xq)], [y_ci(:,1); flipud(y_ci(:,2))],'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');  
        r22 = RTErrRbstMdl{iCond}.Rsquared.Ordinary;
        pval2 = RTErrRbstMdl{iCond}.Coefficients.pValue(2);
        legendStr2 = sprintf('Robust: R^2 = %.2f, p = %.2g', r22, pval2);

        % bootstrap fitting
        YResult = F_BootSLinearR(XV,YV,XDots,length(XV),1000);
        plot(XDots, YResult.y_mean, 'b--', 'LineWidth', 2);

        legend([hline1,hline2], {legendStr1,legendStr2}, 'Location', 'northwest','box','off','AutoUpdate','off');

        xlim(XLim)
        ylim(YLim);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        yticklabels({-45,-30,-15,0,15,30,45});
        if iCond == 1
            xlabel('Reaction time, ms')
            ylabel('SaccEnd-Tar Direction Difference,deg')
        end
        hold off

        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 5 Better way to do the RT regression
% I'm using the robust linear regression, which is by itteration to get the
% weight of each points and reduce the effects of outliers
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_SacEndErr2E_RobustLinear';

    RTErrRbstMdl = cell(size(CondI));
    RTErrMdl = cell(size(CondI));

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        YV = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = []; XVZs = [];
        YV = sbd.SacRTGoc1DeSta(datas1);
        XV = sbd.SacEndErrAng2ESignDeSta(datas1);

        hold on
        % I need to plot on the xy coordinates
        XLim = [-pi/4,pi/4]; YLim = [-200,200];
        scatter(XV,YV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
        XDots = linspace(min(XV), max(XV), 100)';
        
        % classic regression fitting
        RTErrMdl{iCond} = fitlm(XV,YV);
        [YPred1, YCI951] = predict(RTErrMdl{iCond}, XDots);
        hline1 = plot(XDots, YPred1,'k--','linewidth',2); 
        r21 = RTErrMdl{iCond}.Rsquared.Ordinary;
        pval1 = RTErrMdl{iCond}.Coefficients.pValue(2);
        legendStr1 = sprintf('Classic: R^2 = %.2f, p = %.2g', r21, pval1);
        
        % Robust regression fitting
        RTErrRbstMdl{iCond} = fitlm(XV,YV,'RobustOpts','on');
        [YPred2, YCI952] = predict(RTErrRbstMdl{iCond}, XDots);
        hline2 = plot(XDots, YPred2,'r--','linewidth',2);  
        % fill([xq; flipud(xq)], [y_ci(:,1); flipud(y_ci(:,2))],'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');  
        r22 = RTErrRbstMdl{iCond}.Rsquared.Ordinary;
        pval2 = RTErrRbstMdl{iCond}.Coefficients.pValue(2);
        legendStr2 = sprintf('Robust: R^2 = %.2f, p = %.2g', r22, pval2);

        % bootstrap fitting
        YResult = F_BootSLinearR(XV,YV,XDots,length(XV),1000);
        plot(XDots, YResult.y_mean, 'b--', 'LineWidth', 2);

        legend([hline1,hline2], {legendStr1,legendStr2}, 'Location', 'southwest','box','off','AutoUpdate','off');

        xlim(XLim)
        ylim(YLim);
        xticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        xticklabels({-45,-30,-15,0,15,30,45});
        if iCond == 1
            ylabel('Reaction time, ms')
            xlabel('SaccEnd-Tar Direction Difference,deg')
        end
        hold off

        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end





