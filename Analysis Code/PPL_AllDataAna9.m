% Data Processing
% This script is used for data processing for all subject's data
% Created on Jun 19
%   Main use for ending error relevant analysis
% Adjusted on July 23 2024
%   Add the KL divergence cross subject analysis
% Adjusted on Aug 05 2024
%   Add the comparision
% Adjusted on Sep 12 2024
%   Plot the ending error in polar plot
% Adjusted on Sep 16
%   Plot the ending error in polar plot with eye axis
% Adjusted on Sep 18
%   Plot the polar plot of the RT
% Adjusted on Jan 02
%   Plot TMrk polar plot ending error, for -80ms
% Adjusted on Feb 19 2025
%   Plot the Target location at gocue as a function of RT

%% Basic info
LegText = [{'Stationary'},{'CCW 15'},{'CCW 30'},{'CCW 45'},{'CW 15'},{'CW 30'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';

% CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
CondIComp = [1,2,3,4; 1,5,6,7]; % When I want to compare with stationary
CondICompName = {'CCW','CW'};
CondName = '_AllSubj';

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
    206, 137, 56;... % yellow 238, 169, 60 194, 123, 55
    85, 161, 92;... % green),2)
    213, 95, 43;...
    206, 137, 56;... % yellow 238, 169, 60
    85, 161, 92;... % green),2)
    213, 95, 43]/255; %pink/orange

ifDoBasic = 1;
SubjSize = length(DataAll1);
iFigAcc = 0;
SecNum = 0;

% -100, -80, -60, -40, -20, 0, Sacc Off
iTime = 1;

%% 1. plot the linear regression of all subject's RT in each plots
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = 'SacEndErr_RT';
MarkType = {'o','+','*','.','x','|','square','diamond','^','pentagram','hexagram','v','_'};
RTAllCondi = cell(size(CondI)); EndErrAllCondi = cell(size(CondI));
for iCond = CondI
    nexttile;
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile;
    end
    XVAll = []; YVAll = []; XLim = [-250,250]; YLim = [-pi/2,pi/2];
    hold on
    for iSubj = 1:SubjSize
        CurXVAll = []; CurXV = [];  CurYVAll = []; CurYV = [];
        datas1 = [];
        datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
            [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
        CurXVAll = DataAll1(iSubj).sbd.SacRTGoc1DeSta;
        CurXV = CurXVAll(datas1);
        CurYVAll = DataAll1(iSubj).sbd.SacEndErrAng2ESignDeSta;
        CurYV = CurYVAll(datas1);

        scatter(CurXV,CurYV,'Marker',MarkType{iSubj},'MarkerEdgeColor',colorRGB(iCond,:),'LineWidth',1);

        XVAll = [XVAll,CurXV];
        YVAll = [YVAll,CurYV];
    end
    for iSubj = 1:SubjSize
        CurXVAll = []; CurXV = [];  CurYVAll = []; CurYV = [];
        datas1 = [];
        datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
            [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
        CurXVAll = DataAll1(iSubj).sbd.SacRTGoc1DeSta;
        CurXV = CurXVAll(datas1);
        CurYVAll = DataAll1(iSubj).sbd.SacEndErrAng2ESignDeSta;
        CurYV = CurYVAll(datas1);
        F_FitLinearR1(CurXV,CurYV,XLim,YLim)
    end
    RTAllCondi{iCond} = XVAll;
    EndErrAllCondi{iCond} = YVAll;
    title(LegText{iCond},'FontWeight','normal')
    ylim(YLim);
    yticks([-pi/2,-pi/3,-pi/6,0,pi/6,pi/3,pi/2]);
    yticklabels({-90,-60,-30,0,30,60,90});
    xlim(XLim)

    F_FitLinearR(XVAll,YVAll,XLim,YLim)
    yline(0,':',LineWidth=1.5)
    if iCond == 1
        xlabel('RT-Sta, ms'); ylabel('Ending Error-Sta, deg')
    end
    hold off
    set(gca,'FontSize',14)
end
saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end


%% 2. plot the linear regression of all subject's RT together
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = 'SacEndErr_RT_Comp';
MarkType = {'o','+','*','.','x','|','square','diamond','^','pentagram','hexagram','v','_'};
RTAllCondi = cell(size(CondI)); EndErrAllCondi = cell(size(CondI));
XLim = [-250,250]; YLim = [-pi/2,pi/2];
for iDir = 1:2
    subplot(1,2,iDir)
    hl = [];
    XLimTxt = XLim - 100;
    hold on
    for iCond = CondIComp(iDir,1:end)
        XVAll = []; YVAll = [];
        for iSubj = 3
            CurXVAll = []; CurXV = [];  CurYVAll = []; CurYV = [];
            datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
                [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
            CurXVAll = DataAll1(iSubj).sbd.SacRTGoc1DeSta;
            CurXV = CurXVAll(datas1);
            CurYVAll = DataAll1(iSubj).sbd.SacEndErrAng2ESignDeSta;
            CurYV = CurYVAll(datas1);

            scatter(CurXV,CurYV,'Marker',MarkType{iSubj},'MarkerEdgeColor',colorRGB(iCond,:),...
                'LineWidth',2,'MarkerEdgeAlpha',0.7);

            XVAll = [XVAll,CurXV];
            YVAll = [YVAll,CurYV];
        end
        RTAllCondi{iCond} = XVAll;
        EndErrAllCondi{iCond} = YVAll;
    end
    for iCond = CondIComp(iDir,1:end)
        XLimTxt = XLimTxt + 100;
        ylim(YLim);
        yticks([-pi/2,-pi/3,-pi/6,0,pi/6,pi/3,pi/2]);
        yticklabels({-90,-60,-30,0,30,60,90});
        xlim(XLim)
        F_FitLinearR(RTAllCondi{iCond},EndErrAllCondi{iCond},XLimTxt,YLim)
        yline(0,':',LineWidth=0.5)
        if iCond == 1
            xlabel('RT, ms'); ylabel('Ending Error, deg')
        end
    end
    hold off
    set(gca,'FontSize',14)
end
% saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% 3. plot the RT as a function of target location
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = 'SacEndErr2E_RT_TargLoc';
winSize = pi/4;
stepSize = winSize/10;
% winRange = [-winSize+stepSize, 2*pi-stepSize];
winRange = [0, 2*pi];

for iCond = CondI
    nexttile;
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile;
    end
    %% plot the left axis first
    LeftXAve = []; LeftYAve = [];
    hold on
    % plot each subject' End error
    for iSubj = 1:SubjSize
        datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
            [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
        YV1 = []; YV2 = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        XV = mod(wrapTo2Pi(DataAll1(iSubj).sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        YV1 = DataAll1(iSubj).sbd.SacEndErrAng2ESignDeSta(datas1);
        % YV2 = sbd.SacRTGoc1DeSta(datas1);

        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV1',winRange);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(XAve,YAve,YStd);
        set(hl{iCond},'color',colorRGB1(iCond,:),'LineStyle','-.','LineWidth',1,'Marker','none');
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0,'EdgeColor','none')
        LeftXAve = [LeftXAve;XAve];
        LeftYAve = [LeftYAve;YAve];
    end

    LeftXAveAve = wrapTo2Pi(circ_mean_nan(LeftXAve));
    LeftYAveAve = circ_mean_nan(LeftYAve);
    LeftYAveSE = circ_std_nan(LeftYAve)/sqrt(SubjSize);
    [hl1{iCond},hp1] = boundedline(LeftXAveAve,LeftYAveAve,LeftYAveSE);
    set(hl1{iCond},'color',colorRGB2(iCond,:),'LineStyle','-.','LineWidth',2.5,'Marker','none');
    set(hp1,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

    xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
    % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
    xticklabels({'90','180','270','0','90'});
    ylim([-pi/3,pi/6]);
    yticks([-pi/3,-pi/4,-pi/6,-pi/12,0,pi/12,pi/6]);
    % yticklabels({'-pi/9',0,'pi/9'});
    yticklabels({-60,-45,-30,-15,0,15,30});
    if iCond == 1
        xlabel('Targ Dir at Sacc End, deg')
        ylabel('Sacc-End Dir Diff - Sta, deg')
    end
    xline(pi/2,'LineWidth',1.5,'LineStyle',':');
    xline(pi,'LineWidth',1.5,'LineStyle',':');
    xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
    hold off

    %% plot the right axis them
    yyaxis right
    RightXAve = []; RightYAve = [];
    hold on
    % plot each subject' End error
    for iSubj = 1:SubjSize
        datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
            [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
        YV1 = []; YV2 = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        XV = mod(wrapTo2Pi(DataAll1(iSubj).sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        YV2 = DataAll1(iSubj).sbd.SacRTGoc1DeSta(datas1);
        % YV2 = sbd.SacRTGoc1DeSta(datas1);

        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData4(winSize,stepSize,XV',YV2',winRange);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(XAve,YAve,YStd);
        set(hl{iCond},'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',1,'Marker','none');
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0,'EdgeColor','none')
        RightXAve = [RightXAve;XAve];
        RightYAve = [RightYAve;YAve];
    end

    RightXAveAve = wrapTo2Pi(circ_mean_nan(RightXAve));
    RightYAveAve = mean(RightYAve,'omitmissing');
    RightYAveSE = std(RightYAve,'omitmissing')/sqrt(SubjSize);
    [hl2{iCond},hp2] = boundedline(RightXAveAve,RightYAveAve,RightYAveSE);
    set(hl2{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2.5,'Marker','none');
    set(hp2,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')
    ylim([-50,200]);

    if iCond == 1
        ylabel('RT - Sta, ms')
        legend([hl1{1},hl2{1}],{'Ending Error','RT'})
    end
    hold off

    title(LegText{iCond},'FontWeight','normal')
    set(gca,'FontSize',14)
end
saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end


%% 4. Plot the Average Pursuit Vel
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = '/PostSaccSmpLVel_SacEndErr2E';

for iCond = CondI
    h1 = []; h2 = [];
    nexttile
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    SmPLVelAllGrpAveLQ = []; SmPLVelAllGrpAveHQ = []; EndErrGrpAveLQ = []; EndErrGrpAveHQ = [];
    hold on
    for iSubj = 1:SubjSize
        SmPLVelAllGrpAve = DataAll1(iSubj).sbd.SmPLVelAllGrpAve{iCond};
        SmPTime = 1:length(SmPLVelAllGrpAve);
        plot(SmPTime,SmPLVelAllGrpAve(1,:),'color',[0.86,0.86,0.86],'LineStyle','-','LineWidth',1)
        plot(SmPTime,SmPLVelAllGrpAve(4,:),'color',[colorRGB1(iCond,:),0.3],'LineStyle','-','LineWidth',1)
        SmPLVelAllGrpAveLQ = [SmPLVelAllGrpAveLQ; SmPLVelAllGrpAve(1,:)];
        SmPLVelAllGrpAveHQ = [SmPLVelAllGrpAveHQ; SmPLVelAllGrpAve(4,:)];
        EndErrGrpAveLQ = [EndErrGrpAveLQ, DataAll1(iSubj).sbd.EndErrGrpAve{iCond}(1)];
        EndErrGrpAveHQ = [EndErrGrpAveHQ, DataAll1(iSubj).sbd.EndErrGrpAve{iCond}(4)];
    end
    SmPLVelAllGrpAveLQAve = mean(SmPLVelAllGrpAveLQ);
    SmPLVelAllGrpAveLQSE = std(SmPLVelAllGrpAveLQ)/sqrt(SubjSize);
    SmPLVelAllGrpAveHQAve = mean(SmPLVelAllGrpAveHQ);
    SmPLVelAllGrpAveHQSE = std(SmPLVelAllGrpAveHQ)/sqrt(SubjSize);
    EndErrGrpAveLQAve = circ_mean_nan(EndErrGrpAveLQ');
    EndErrGrpAveHQAve = circ_mean_nan(EndErrGrpAveHQ');

    % for lower bound
    [h1,hp] = boundedline(SmPTime,SmPLVelAllGrpAveLQAve,SmPLVelAllGrpAveLQSE);
    set(h1,'color',[0,0,0],'LineStyle','-','LineWidth',2,'Marker','none');
    set(hp,'FaceColor',[0,0,0],'FaceAlpha',0.3,'EdgeColor','none')

    [h2,hp] = boundedline(SmPTime,SmPLVelAllGrpAveHQAve,SmPLVelAllGrpAveHQSE);
    set(h2,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2,'Marker','none');
    set(hp,'FaceColor',colorRGB(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')

    ylim([0,50])

    if iCond == 1
        xlabel('Post Interceptive Saccade Time, ms')
        ylabel('Pursuit Linear Vel, deg/s')
    end
    legend([h1,h2],{['LQ: ',num2str(rad2deg(EndErrGrpAveLQAve),'%.2f')],...
        ['HQ: ',num2str(rad2deg(EndErrGrpAveHQAve),'%.2f')]},'Box','off','Location','southeast','FontSize',15);

    hold off

    set(gca,'FontSize',15)
    title(LegText{iCond},'FontWeight','normal')
end

saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% compare the KL divergence between delay and non delay
% delay and non delay name assign:
DataAll1User = 1:8;
DataAll2User = [12,13,2,11,1,4,5,6];
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacDir2EKL_Delay_NonDelay';
    
    for iCond = CondI
    klDivg = [];
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        for iSubj = 1:length(DataAll1User)
            vfPDFSamples = DataAll1(iSubj).sbd.vfPDFSamples;
            vfEstimateNon = []; vfEstimateNon = DataAll1(iSubj).sbd.vfEstimate(iCond,:);
            vfEstimateDel = []; vfEstimateDel = DataAll2(DataAll2User(iSubj)).sbd.vfEstimate(iCond,:);
            klDivg(iSubj,:) = circ_kldivergence(vfEstimateNon,vfEstimateDel,vfPDFSamples);
            p2 = polarplot(vfPDFSamples,klDivg(iSubj,:),'LineWidth',1,'Color',colorRGB1(iCond,:));
            hold on
        end
    klDivgAve(iCond,:) = mean(klDivg);
    klDivgSE(iCond,:) = std(klDivg)/sqrt(length(DataAll1User));
    polarplot(-pi:pi/50:pi,zeros(size(-pi:pi/50:pi)),'LineWidth',1,'Color','k')
    polarplot(vfPDFSamples,klDivgAve(iCond,:),'LineWidth',2,'Color',colorRGB2(iCond,:));
    polarplot(vfPDFSamples,klDivgAve(iCond,:)+klDivgSE(iCond,:),'LineWidth',1.5,'Color',colorRGB2(iCond,:),'LineStyle','--');
    polarplot(vfPDFSamples,klDivgAve(iCond,:)-klDivgSE(iCond,:),'LineWidth',1.5,'Color',colorRGB2(iCond,:),'LineStyle','--');
    title(LegText{iCond},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([-0.15,0.2])
    end
    % sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end


%% plot the end err as a function of target location, delay non delay
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = 'SacEndErr2E_TargLoc_Delay_NonDelay';
winSize = pi/4;
stepSize = winSize/10;
% winRange = [-winSize+stepSize, 2*pi-stepSize];
winRange = [0, 2*pi];

for iCond = CondI
    nexttile;
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile;
    end
    %% plot the nondelay first
    LeftXAve = []; LeftYAve = [];
    hold on
    % plot each subject' End error
    for iSubj = DataAll1User
        datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
            [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
        YV1 = []; YV2 = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        XV = mod(wrapTo2Pi(DataAll1(iSubj).sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        YV1 = DataAll1(iSubj).sbd.SacEndErrAng2ESign1DeSta(datas1);
        % YV2 = sbd.SacRTGoc1DeSta(datas1);

        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV1',winRange);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(XAve,YAve,YStd);
        set(hl{iCond},'color',colorRGB1(iCond,:),'LineStyle',':','LineWidth',1,'Marker','none');
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0,'EdgeColor','none')
        LeftXAve = [LeftXAve;XAve];
        LeftYAve = [LeftYAve;YAve];
    end

    LeftXAveAve = wrapTo2Pi(circ_mean_nan(LeftXAve));
    LeftYAveAve = circ_mean_nan(LeftYAve);
    LeftYAveSE = circ_std_nan(LeftYAve)/sqrt(SubjSize);
    [hl1{iCond},hp1] = boundedline(LeftXAveAve,LeftYAveAve,LeftYAveSE);
    set(hl1{iCond},'color',colorRGB2(iCond,:),'LineStyle',':','LineWidth',2.5,'Marker','none');
    set(hp1,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')

    xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
    % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
    xticklabels({'90','180','270','0','90'});
    ylim([-pi/6,pi/6]);
    yticks([-pi/6,-pi/12,0,pi/12,pi/6]);
    % yticklabels({'-pi/9',0,'pi/9'});
    yticklabels(rad2deg([-pi/6,-pi/12,0,pi/12,pi/6]));
    if iCond == 1
        xlabel('Targ Dir at Sacc End, deg')
        ylabel('Sacc-End Dir Diff - Sta, deg')
    end
    hold off

    %% plot the delay them
    RightXAve = []; RightYAve = [];
    hold on
    % plot each subject' End error
    for iSubj = DataAll2User
        datas1 = find([DataAll2(iSubj).Dataf1.TarDir1] == iCond & ([DataAll2(iSubj).Dataf1.TrialStatus] == 1 |...
            [DataAll2(iSubj).Dataf1.TrialStatus] == 5));
        YV1 = []; YV2 = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        XV = mod(wrapTo2Pi(DataAll2(iSubj).sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        YV2 = DataAll2(iSubj).sbd.SacEndErrAng2ESignDeSta(datas1);
        % YV2 = sbd.SacRTGoc1DeSta(datas1);

        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV2',winRange);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(XAve,YAve,YStd);
        set(hl{iCond},'color',colorRGB1(iCond,:),'LineStyle','--','LineWidth',1,'Marker','none');
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0,'EdgeColor','none')
        RightXAve = [RightXAve;XAve];
        RightYAve = [RightYAve;YAve];
    end

    RightXAveAve = wrapTo2Pi(circ_mean_nan(RightXAve));
    RightYAveAve = circ_mean_nan(RightYAve);
    RightYAveSE = circ_std_nan(RightYAve)/sqrt(SubjSize);
    [hl2{iCond},hp2] = boundedline(RightXAveAve,RightYAveAve,RightYAveSE);
    set(hl2{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2.5,'Marker','none');
    set(hp2,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
    ylim([-pi/6,pi/6]);

    if iCond == 1
        legend([hl1{1},hl2{1}],{'Non Delay','Delay'},'AutoUpdate','off','Box','off')
    end
    hold off

    hold on
    xline(pi/2,'LineWidth',1.5,'LineStyle',':');
    xline(pi,'LineWidth',1.5,'LineStyle',':');
    xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
    yline(0,'LineWidth',1.5,'LineStyle',':')
    hold off

    title(LegText{iCond},'FontWeight','normal')
    set(gca,'FontSize',14)
end
saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% plot the end err as a function of target location, delay non delay
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = 'SacEndErr2E_TargLoc_Delay';
winSize = pi/4;
stepSize = winSize/10;
% winRange = [-winSize+stepSize, 2*pi-stepSize];
winRange = [0, 2*pi];

for iCond = CondI
    nexttile;
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile;
    end
    % plot the delay them
    RightXAve = []; RightYAve = [];
    hold on
    % plot each subject' End error
    for iSubj = 1:SubjSize
        datas1 = [];
        datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
            [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
        YV1 = []; YV2 = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        XV = mod(wrapTo2Pi(DataAll1(iSubj).sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        YV2 = DataAll1(iSubj).sbd.SacEndErrAng2ESignDeSta(datas1);
        % YV2 = sbd.SacRTGoc1DeSta(datas1);
        % scatter(XV,YV2)
        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV2',winRange);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(XAve,YAve,YStd);
        set(hl{iCond},'color',colorRGB1(iCond,:),'LineStyle','--','LineWidth',1,'Marker','none');
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0,'EdgeColor','none')
        RightXAve = [RightXAve;XAve];
        RightYAve = [RightYAve;YAve];
    end

    RightXAveAve = wrapTo2Pi(circ_mean_nan(RightXAve));
    RightYAveAve = circ_mean_nan(RightYAve);
    RightYAveSE = circ_std_nan(RightYAve)/sqrt(SubjSize);
    [hl2{iCond},hp2] = boundedline(RightXAveAve,RightYAveAve,RightYAveSE);
    set(hl2{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2.5,'Marker','none');
    set(hp2,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
    
    xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
    % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
    xticklabels({'90','180','270','0','90'});
    ylim([-pi/6,pi/6]);
    yticks([-pi/6,-pi/12,0,pi/12,pi/6]);
    % yticklabels({'-pi/9',0,'pi/9'});
    yticklabels(rad2deg([-pi/6,-pi/12,0,pi/12,pi/6]));
    if iCond == 1
        xlabel('Targ Dir at Sacc End, deg')
        ylabel('Sacc-End Dir Diff no - Sta, deg')
    end
    ylim([-pi/6,pi/6]);
    hold off

    hold on
    xline(pi/2,'LineWidth',1.5,'LineStyle',':');
    xline(pi,'LineWidth',1.5,'LineStyle',':');
    xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
    yline(0,'LineWidth',1.5,'LineStyle',':')
    hold off

    title(LegText{iCond},'FontWeight','normal')
    set(gca,'FontSize',14)
end
% saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% plot the end err as a function of target location, delay non delay
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = 'SacEndErr2E_TargLoc_Delay_CondDiff';
winSize = pi/4;
stepSize = winSize/10;
% winRange = [-winSize+stepSize, 2*pi-stepSize];
winRange = [0, 2*pi];

for iCond = CondI
    nexttile;
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile;
    end
    %% plot the delay them
    RightXAve = []; RightYAve = [];
    hold on
    % plot each subject' End error
    for iSubj = 1:SubjSize
        datas1 = [];
        datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
            [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
        YV1 = []; YV2 = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        XV = mod(wrapTo2Pi(DataAll1(iSubj).sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        if iCond == 1
            YV2 = DataAll1(iSubj).sbd.SacEndErrAng2ESign(datas1);
        else
            YV2 = DataAll1(iSubj).sbd.SacEndErrAng2ESignDeSta(datas1);
        end
        % YV2 = sbd.SacRTGoc1DeSta(datas1);
        % scatter(XV,YV2)
        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV2',winRange);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(XAve,YAve,YStd);
        set(hl{iCond},'color',colorRGB1(iCond,:),'LineStyle','--','LineWidth',1,'Marker','none');
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0,'EdgeColor','none')
        RightXAve = [RightXAve;XAve];
        RightYAve = [RightYAve;YAve];
    end

    RightXAveAve = wrapTo2Pi(circ_mean_nan(RightXAve));
    RightYAveAve = circ_mean_nan(RightYAve);
    RightYAveSE = circ_std_nan(RightYAve)/sqrt(SubjSize);
    [hl2{iCond},hp2] = boundedline(RightXAveAve,RightYAveAve,RightYAveSE);
    set(hl2{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2.5,'Marker','none');
    set(hp2,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
    
    xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
    % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
    xticklabels({'90','180','270','0','90'});
    ylim([-pi/6,pi/6]);
    yticks([-pi/6,-pi/12,0,pi/12,pi/6]);
    % yticklabels({'-pi/9',0,'pi/9'});
    yticklabels(rad2deg([-pi/6,-pi/12,0,pi/12,pi/6]));
    if iCond == 1
        xlabel('Targ Dir at Sacc End, deg')
        ylabel('Sacc-End Dir Diff no - Sta, deg')
    elseif iCond == 2
        ylabel('Sacc-End Dir Diff - Sta, deg')
    end

    ylim([-pi/6,pi/6]);
    hold off

    hold on
    xline(pi/2,'LineWidth',1.5,'LineStyle',':');
    xline(pi,'LineWidth',1.5,'LineStyle',':');
    xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
    yline(0,'LineWidth',1.5,'LineStyle',':')
    hold off

    title(LegText{iCond},'FontWeight','normal')
    set(gca,'FontSize',14)
end
% saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% compare the KL divergence within delay
% delay and non delay name assign:
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;

    SaveName = [];
    SaveName = '/SacDir2EKL_Delay';
    
    for iCond = CondI
    klDivg = [];
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        for iSubj = 1:SubjSize
            vfPDFSamples = DataAll1(iSubj).sbd.vfPDFSamples;
            vfEstimate2 = []; vfEstimate2 = DataAll1(iSubj).sbd.vfEstimate(iCond,:);
            vfEstimate1 = []; vfEstimate1 = DataAll1(iSubj).sbd.vfEstimate(1,:);
            klDivg(iSubj,:) = circ_kldivergence(vfEstimate2,vfEstimate1,vfPDFSamples);
            p2 = polarplot(vfPDFSamples,klDivg(iSubj,:),'LineWidth',1,'Color',colorRGB1(iCond,:));
            hold on
        end
    klDivgAve(iCond,:) = mean(klDivg);
    klDivgSE(iCond,:) = std(klDivg)/sqrt(SubjSize);
    polarplot(-pi:pi/50:pi,zeros(size(-pi:pi/50:pi)),'LineWidth',1,'Color','k')
    polarplot(vfPDFSamples,klDivgAve(iCond,:),'LineWidth',2,'Color',colorRGB2(iCond,:));
    polarplot(vfPDFSamples,klDivgAve(iCond,:)-klDivgSE(iCond,:) ,'LineWidth',2,'Color',colorRGB2(iCond,:),'LineStyle','--');
    polarplot(vfPDFSamples,klDivgAve(iCond,:)+klDivgSE(iCond,:) ,'LineWidth',2,'Color',colorRGB2(iCond,:),'LineStyle','--');
    title(LegText{iCond},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([-0.15,0.2])
    end
    % sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end
