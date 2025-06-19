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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now this code is for monkey data analysis across all sessions

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
CondName = '_1';

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
SessiSize = length(DataxAll);
iFigAcc = 0;
SecNum = 0;

%% 1 find the significant part and plot all the subjects data together with mean traces
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2E_XY_Normed_AllS';

    XAveAll = cell(SessiSize,length(CondI));
    YAveAll = cell(SessiSize,length(CondI));
    YStdAll = cell(SessiSize,length(CondI));

    winSize = pi/4;
    stepSize = winSize/10;
    % winRange = [-winSize+stepSize, 2*pi-stepSize];
    winRange = [0,2*pi];

    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        hold on
        for iSession = 1:SessiSize
            % for each session, reassign the Datax and sbd
            sbd = [];
            sbd = DataxAll(iSession).sbd;

            XV = []; YV = [];
            XAve = []; YAve = []; YStd = [];
            datas1 = find(sbd.trialGrp == iCond & sbd.trialErr == 1);
            XV = mod(rad2deg(wrapTo2Pi(sbd.TargLocSacEndAtcpTR2E(datas1,1)))-90,360);
            YV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1));

            % plot the sliding window
            XV = wrapTo2Pi(deg2rad(XV));
            YV = sbd.SacEndErrAng2ESignDeSta(datas1);
            
            [XAve, YAve, YStd] = FM_CartScaSlidWin_PolData2(winSize,stepSize,XV,YV,winRange);
            % use boundedline to plot which can also skip the nan point
            XAve = rad2deg(XAve);
            YAve = rad2deg(YAve);
            YStd = rad2deg(YStd);

            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(XAve,YAve,YStd);
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','--','LineWidth',2);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.1,'EdgeColor','none')

            % save all the XAve and YAve and YStd
            XAveAll{iCond}(iSession,:) = wrapTo2Pi(deg2rad(XAve));
            YAveAll{iCond}(iSession,:) = wrapToPi(deg2rad(YAve));
            YStdAll{iCond}(iSession,:) = wrapToPi(deg2rad(YStd));
        end

        % Plot the average result for this condition
        XAveAllAve = rad2deg(wrapTo2Pi(circ_mean_nan(XAveAll{iCond})));
        YAveAllAve = rad2deg(wrapToPi(circ_mean_nan(YAveAll{iCond})));
        YAveAllStd = rad2deg(circ_std_nan(YAveAll{iCond}));
        YAveAllSE = YAveAllStd/sqrt(SessiSize);

        [hl{iCond},hp] = boundedline(XAveAllAve,YAveAllAve,YAveAllSE);
        set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3);
        set(hp,'FaceColor',colorRGB(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        xticks([0,90,180,270,360]);
        xticklabels([90,180,270,0,90]);
        yticks([-60,-30,0,30,60]);
        yticklabels([-50,-25,0,25,50]);

        xlim([-5,365]);
        ylim([-50,50]);

        if iCond == 1
            xlabel('Target Direction at Sacc End')
            ylabel('Sacc-End Direction Difference')
        end

        xline(180,'LineWidth',1.5,'LineStyle','--');
        xline(90,'LineWidth',1.5,'LineStyle','--');
        xline(270,'LineWidth',1.5,'LineStyle','--')
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
    saveas(gcf,[ResultDir,SaveName,'.fig'])
end


%% 2 plot the linear regression of all the subjects' RT result DeSta
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_RT_DeSta_AllSessi';
    MarkType = {'o','+','*','.','x','|','square','diamond','^','pentagram','hexagram'};
    XLim = [-250,250];
    YLim = [-50,50];
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        XVAll = []; YVAll = []; SessID = [];
        hold on
        for iSession = 1:SessiSize
            % preassign each session and each condition data
            sbd = []; sbd = [];
            sbd = DataxAll(iSession).sbd;

            datas1 = find(sbd.trialGrp == iCond & sbd.trialErr == 1);

            CurXV = [];  EndErr = []; CurYV = [];
            CurXV = sbd.SacRTGoc1DeSta(datas1)';
            CurYV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1))';
            
            scatter(CurXV,CurYV,'Marker',MarkType{iSession},'MarkerEdgeColor',colorRGB(iCond,:),'LineWidth',1);

            XVAll = [XVAll,CurXV];
            YVAll = [YVAll,CurYV];
            SessID = [iSession*ones(size(CurXV)),SessID];
        end
        
        % fitlme fit linear mixed effects model
        tbl = table(XVAll', YVAll', SessID');
        XDots = linspace(min(XVAll), max(XVAll), 100)';
        lme = fitlme(tbl, 'Var2 ~ Var1 + (Var1|Var3)');
        for iSession = 1:SessiSize
            tblPred = table(XDots, repmat(iSession, size(XDots)));
            tblPred.Properties.VariableNames = {'Var1', 'Var3'};
            [YPred1, ~] = predict(lme, tblPred);
            hline1 = plot(XDots, YPred1,'k--','linewidth',1.5);
        end
        r21 = 1 - (lme.SSE / lme.SST);
        pval2 = lme.Coefficients.pValue(2);
        legendStr1 = sprintf('LME: R^2 = %.2f, p = %.2f', r21, pval2);

        title(LegText{iCond},'FontWeight','normal')
        ylim(YLim);
        yticks([-50,-25,0,25,50]);
        xlim(XLim)
        legend(hline1, legendStr1, 'Location', 'southwest','box','off','AutoUpdate','off');
        if iCond == 1
            xlabel('RT - Sta, ms'); ylabel('Ending Error, deg');
        end
        hold off
        set(gca,'FontSize',15)
    end
    saveas(gcf,[ResultDir,SaveName,'.fig'])
end

%% 3 plot the linear regression of all the subjects' RT result original
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_RT_AllSessi';
    MarkType = {'o','+','*','.','x','|','square','diamond','^','pentagram','hexagram'};
    XLim = [100,400];
    YLim = [-50,50];
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        XVAll = []; YVAll = []; SessID = [];
        hold on
        for iSession = 1:SessiSize
            % preassign each session and each condition data
            sbd = []; sbd = [];
            sbd = DataxAll(iSession).sbd;

            datas1 = find(sbd.trialGrp == iCond & sbd.trialErr == 1);

            CurXV = [];  EndErr = []; CurYV = [];
            CurXV = sbd.SacRTGoc1(datas1)';
            CurYV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1))';
            
            scatter(CurXV,CurYV,'Marker',MarkType{iSession},'MarkerEdgeColor',colorRGB(iCond,:),'LineWidth',1);

            XVAll = [XVAll,CurXV];
            YVAll = [YVAll,CurYV];
            SessID = [iSession*ones(size(CurXV)),SessID];
        end
        
        % fitlme fit linear mixed effects model
        tbl = table(XVAll', YVAll', SessID');
        XDots = linspace(min(XVAll), max(XVAll), 100)';
        lme = fitlme(tbl, 'Var2 ~ Var1 + (Var1|Var3)');
        for iSession = 1:SessiSize
            tblPred = table(XDots, repmat(iSession, size(XDots)));
            tblPred.Properties.VariableNames = {'Var1', 'Var3'};
            [YPred1, ~] = predict(lme, tblPred);
            hline1 = plot(XDots, YPred1,'k--','linewidth',1.5);
        end
        r21 = 1 - (lme.SSE / lme.SST);
        pval2 = lme.Coefficients.pValue(2);
        legendStr1 = sprintf('LME: R^2 = %.2f, p = %.2f', r21, pval2);

        title(LegText{iCond},'FontWeight','normal')
        ylim(YLim);
        yticks([-50,-25,0,25,50]);
        xlim(XLim)
        legend(hline1, legendStr1, 'Location', 'southwest','box','off','AutoUpdate','off');
        if iCond == 1
            xlabel('RT, ms'); ylabel('Ending Error, deg');
        end
        hold off
        set(gca,'FontSize',15)
    end
    saveas(gcf,[ResultDir,SaveName,'.fig'])
end

%% 4 plot the linear regression of all the subjects' SmP result ZS [50,150]
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Pursuit_AllSessi';
    MarkType = {'o','+','*','.','x','|','square','diamond','^','pentagram','hexagram'};
    XLim = [10,70];
    YLim = [-50,50];
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        XVAll = []; YVAll = []; SessID = [];
        hold on
        for iSession = 1:SessiSize
            % preassign each session and each condition data
            sbd = []; sbd = [];
            sbd = DataxAll(iSession).sbd;

            datas1 = find(sbd.trialGrp == iCond & sbd.trialErr == 1);

            CurXV = [];  EndErr = []; CurYV = [];
            CurXV = sbd.SmPLVelGoc1(datas1,1)';
            CurYV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1))';
            
            scatter(CurXV,CurYV,'Marker',MarkType{iSession},'MarkerEdgeColor',colorRGB(iCond,:),'LineWidth',1);

            XVAll = [XVAll,CurXV];
            YVAll = [YVAll,CurYV];
            SessID = [iSession*ones(size(CurXV)),SessID];
        end
        
        % fitlme fit linear mixed effects model
        tbl = table(XVAll', YVAll', SessID');
        XDots = linspace(min(XVAll), max(XVAll), 100)';
        lme = fitlme(tbl, 'Var2 ~ Var1 + (Var1|Var3)');
        for iSession = 1:SessiSize
            tblPred = table(XDots, repmat(iSession, size(XDots)));
            tblPred.Properties.VariableNames = {'Var1', 'Var3'};
            [YPred1, ~] = predict(lme, tblPred);
            hline1 = plot(XDots, YPred1,'k--','linewidth',1.5);
        end
        r21 = 1 - (lme.SSE / lme.SST);
        pval2 = lme.Coefficients.pValue(2);
        legendStr1 = sprintf('LME: R^2 = %.2f, p = %.2f', r21, pval2);

        title(LegText{iCond},'FontWeight','normal')
        ylim(YLim);
        yticks([-50,-25,0,25,50]);
        xlim(XLim)
        legend(hline1, legendStr1, 'Location', 'southwest','box','off','AutoUpdate','off');
        if iCond == 1
            xlabel('Post Sac Pursuit Vel 50-150ms, deg/s'); ylabel('Ending Error, deg');
        end
        hold off
        set(gca,'FontSize',15)
    end
    saveas(gcf,[ResultDir,SaveName,'.fig'])
end

%% 5 KL Divergence
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacDir2EKL_AllSessi';
    StepSZ = deg2rad(2); % the size of step
    vfPDFSamples = 0:StepSZ:2*pi;
    fSigma = 0.3;
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end

        polarplot(0:0.01:2*pi,zeros(size(0:0.01:2*pi)),'LineStyle',':','Color','k','LineWidth',1.5)
        hold on

        for iSession = 1:SessiSize
            datas1 = find(sbd.trialGrp == iCond & sbd.trialErr == 1);
            % EyeEndTta = zeros(size(datas1));
            EyeEndTta = wrapTo2Pi(sbd.SacEndTR2E(datas1,1));
            vfEstimate{iCond}(iSession,:) = circ_ksdensity(EyeEndTta, vfPDFSamples, [0, 2*pi], fSigma);
            vfEstimate2 = vfEstimate{iCond}(iSession,:);
            vfEstimate1 = vfEstimate{1}(iSession,:);
            klDivg{iCond}(iSession,:) = circ_kldivergence(vfEstimate2,vfEstimate1,vfPDFSamples);
            polarplot(vfPDFSamples,klDivg{iCond}(iSession,:),'LineWidth',1.5,'Color',colorRGB1(iCond,:));
        end

        klDivgAll(iCond,:) = mean(klDivg{iCond});
        klDivgAllSE(iCond,:) = std(klDivg{iCond})/sqrt(SessiSize);
        polarplot(vfPDFSamples,klDivgAll(iCond,:)-klDivgAllSE(iCond,:),'LineWidth',1,'Color',[colorRGB(iCond,:),0.3]);
        polarplot(vfPDFSamples,klDivgAll(iCond,:)+klDivgAllSE(iCond,:),'LineWidth',1,'Color',[colorRGB(iCond,:),0.3]);
        polarplot(vfPDFSamples,klDivgAll(iCond,:),'LineWidth',2,'Color',colorRGB2(iCond,:));

        rlim([-0.2,0.5])
        hold off
        
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
    saveas(gcf,[ResultDir,SaveName,'.fig'])
end


