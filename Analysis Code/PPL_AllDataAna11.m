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
% Adjusted on Apr 24 2025
%   Polar plots for ending error as a function of eye location, for RT

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
% SubjSize = length(DataAll1);
SubjSize = 13;
iFigAcc = 0;
SecNum = 0;

% -100, -80, -60, -40, -20, 0, Sacc Off
iTime = 1;

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
    % saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end


%% compare the KL divergence across diff speed within same direction
% delay and non delay name assign:
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);
    iFig = 1;
    
    SaveName = [];
    SaveName = '/SacDir2EKLComp';
    
    vfPDFSamples = DataAll1(1).sbd.vfPDFSamples;
    
    for iDir = 1:size(CondIComp,1)
        nexttile
        for iCond = CondIComp(iDir,:)
            polarplot(-pi:pi/50:pi,zeros(size(-pi:pi/50:pi)),'LineWidth',1,'Color','k')
            hold on
            polarplot(vfPDFSamples,klDivgAve(iCond,:),'LineWidth',2,'Color',colorRGB2(iCond,:));
            polarplot(vfPDFSamples,klDivgAve(iCond,:)-klDivgSE(iCond,:) ,'LineWidth',2,'Color',colorRGB2(iCond,:),'LineStyle','--');
            polarplot(vfPDFSamples,klDivgAve(iCond,:)+klDivgSE(iCond,:) ,'LineWidth',2,'Color',colorRGB2(iCond,:),'LineStyle','--');
        end
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-0.1,0.15])
    
    end
    hold off
    % sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
    % saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% 3. plot the linear regression of all subject's RT in each plots with the new method
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
    XVAll = []; YVAll = [];  XLim = [-250,250]; YLim = [-pi/2,pi/2];
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
    RTAllCondi{iCond} = XVAll;
    EndErrAllCondi{iCond} = YVAll;
    title(LegText{iCond},'FontWeight','normal')
    ylim(YLim);
    yticks([-pi/2,-pi/3,-pi/6,0,pi/6,pi/3,pi/2]);
    yticklabels({-90,-60,-30,0,30,60,90});
    xlim(XLim)

    % Classic regression fitting
    XDots = linspace(min(XVAll), max(XVAll), 100)';
    RTErrMdl = fitlm(XVAll,YVAll);
    [YPred1, ~] = predict(RTErrMdl, XDots);
    hline1 = plot(XDots, YPred1,'b--','linewidth',2);
    r21 = RTErrMdl.Rsquared.Ordinary;
    pval2 = RTErrMdl.Coefficients.pValue(2);
    legendStr1 = sprintf('Classic: R^2 = %.2f, p = %.2g', r21, pval2);

    % Robust regression fitting
    RTErrRbstMdl = fitlm(XVAll,YVAll,'RobustOpts','on');
    [YPred2, ~] = predict(RTErrRbstMdl, XDots);
    hline2 = plot(XDots, YPred2,'r--','linewidth',2);
    r22 = RTErrRbstMdl.Rsquared.Ordinary;
    pval2 = RTErrRbstMdl.Coefficients.pValue(2);
    legendStr2 = sprintf('Robust: R^2 = %.2f, p = %.2g', r22, pval2);
    
    % GMM cluster 95% fitting
    gm = fitgmdist([XVAll;YVAll]', 1);
    D = mahal(gm,[XVAll;YVAll]');  % Squared Mahalanobis distance
    % 95% ellipse threshold for 2D
    thresh = chi2inv(0.95, 2);
    inliers = D < thresh;
    RTErrGMMMdl = fitlm(XVAll(inliers), YVAll(inliers));
    [YPred3, ~] = predict(RTErrGMMMdl, XDots);
    hline3 = plot(XDots, YPred3,'g--','linewidth',2);
    r23 = RTErrGMMMdl.Rsquared.Ordinary;
    pval2 = RTErrGMMMdl.Coefficients.pValue(2);
    legendStr3 = sprintf('GMM: R^2 = %.2f, p = %.2g', r23, pval2);
    % plot the 95% ellipse
    error_ellipseJPM([XVAll;YVAll]', 0.95, 'k');

    legend([hline1,hline2,hline3], {legendStr1,legendStr2,legendStr3}, 'Location', 'southwest','box','off','AutoUpdate','off');
    yline(0,':',LineWidth=1.5)
    if iCond == 1
        xlabel('RT-Sta, ms'); ylabel('Ending Error-Sta, deg')
    end
    hold off
    set(gca,'FontSize',14)
end
% saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% 3. plot the linear regression of all subject's RT in each plots with the new method
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
    XVAll = []; YVAll = []; XLim = [-250,250]; YLim = [-pi/2,pi/2]; SubjID = [];
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
        SubjID = [iSubj*ones(size(CurXV)),SubjID];
    end
    RTAllCondi{iCond} = XVAll;
    EndErrAllCondi{iCond} = YVAll;

    % fitlme fit linear mixed effects model
    tbl = table(XVAll', YVAll', SubjID');
    XDots = linspace(min(XVAll), max(XVAll), 100)';
    lme = fitlme(tbl, 'Var2 ~ Var1 + (Var1|Var3)');
    for iSubj = 1:SubjSize
        tblPred = table(XDots, repmat(iSubj, size(XDots)));
        tblPred.Properties.VariableNames = {'Var1', 'Var3'};
        [YPred1, ~] = predict(lme, tblPred);
        hline1 = plot(XDots, YPred1,'k--','linewidth',1);
    end
    r21 = 1 - (lme.SSE / lme.SST);
    pval2 = lme.Coefficients.pValue(2);
    legendStr1 = sprintf('LME: R^2 = %.2f, p = %.2g', r21, pval2);

    % % GMM and fit linear mixed effects model
    % gm = fitgmdist([XVAll;YVAll]', 1);
    % D = mahal(gm,[XVAll;YVAll]');  % Squared Mahalanobis distance
    % % 95% ellipse threshold for 2D
    % thresh = chi2inv(0.95, 2);
    % inliers = D < thresh;
    % tblGMM = table(XVAll(inliers)', YVAll(inliers)', SubjID(inliers)');
    % tblGMMPred = table(XDots, repmat(2, size(XDots)));
    % tblGMMPred.Properties.VariableNames = {'Var1', 'Var3'};
    % lmeGMM = fitlme(tblGMM, 'Var2 ~ Var1 + (Var1|Var3)');
    % [YPred2, ~] = predict(lmeGMM, tblGMMPred);
    % hline2 = plot(XDots, YPred2,'k--','linewidth',2);
    % r21 = 1 - (lmeGMM.SSE / lmeGMM.SST);
    % pval2 = lmeGMM.Coefficients.pValue(2);
    % legendStr2 = sprintf('GmmLME: R^2 = %.2f, p = %.2g', r21, pval2);
    % % plot the 95% ellipse
    % error_ellipseJPM([XVAll;YVAll]', 0.95, 'k');

    title(LegText{iCond},'FontWeight','normal')
    ylim(YLim);
    yticks([-pi/2,-pi/3,-pi/6,0,pi/6,pi/3,pi/2]);
    yticklabels({-90,-60,-30,0,30,60,90});
    xlim(XLim)
    legend(hline1, legendStr1, 'Location', 'southwest','box','off','AutoUpdate','off');
    yline(0,':',LineWidth=1.5)
    if iCond == 1
        xlabel('RT-Sta, ms'); ylabel('Ending Error-Sta, deg')
    end
    hold off
    set(gca,'FontSize',14)
end
% saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end
