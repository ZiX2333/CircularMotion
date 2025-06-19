% Data Processing
% This script is used for data processing
% Analysis based on prepro 1
% Created on Jan 24 2025, Xuan
% Jan 24 2025 Updated, Xuan
%   Test on the saccadic eye traces polar plot
% Feb 19 2025 Updated, Xuan
% May 13 2025 Updated, Xuan
%   Add raw eye traces, err-targ loc, KL, pursuit Vel, RT


%% TXT information and basic setup
global LegText colorRGB colorRGB1 colorRGB2
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

%% Basic settings
if ifDoBasic == 1
    %% set up basic parameter
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

    %% PreProcessed of Data
    Datax1 = Datax;

    % Drop criteria: there will be two drops, one check the time and ending
    % location parameters, one check the behavior ana output

    iDrop1 = []; % for the first drop
    iDrop2 = []; % for the second drop
    % remove RT < 80ms, duration >=150ms, start radius >=5, end radius <=5,
    % amplitude <=2 % remove RT > 500
    for iTrial = 1:size(Datax,1)
        if Datax.trialGrp(iTrial) == 0 % not going to analysis step
            continue
        end
        if isempty(Datax.SacLocGoc2{iTrial})
            iDrop1 = [iDrop1,iTrial];
            continue
        end
        EyeLoc = [];
        EyeLoc = Datax.SacLocGoc2{iTrial}{1}(1:4,:);
        if max(EyeLoc(4,:)) > 20 % probably blink
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif EyeLoc(4,1) >=5 % start too far
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif EyeLoc(4,end) <=5 % end too short
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif EyeLoc(4,end) - EyeLoc(4,1) <=2 % amp too short
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif Datax.SacTimeGoc2{iTrial}(end,1) < 80 % RT too short
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif Datax.SacTimeGoc2{iTrial}(end,1) > 500 % RT too Long
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif Datax.SacTimeGoc2{iTrial}(end-1,1) >150 %saccade too long
            iDrop1 = [iDrop1,iTrial];
            continue
        end
    end

    % behavior analysis
    sbd = [];
    [sbd,iDrop2] = BehaviorAnaM(Datax);

    % drop data
    iDropAll = unique([iDrop1,iDrop2]);
    Datax1.trialErr(iDropAll) = -1; % -1 means doesn't apply criteria

    % updates the sbd
    [sbd] = BehaviorGrpAnaM(Datax1,sbd);

    iFigAcc = 0;
    SecNum = 0;

    % save trial grp and trialErr in sbd
    sbd.trialGrp = Datax1.trialGrp;
    sbd.trialErr = Datax1.trialErr;
end

%% 1 plot the row eye traces using eye center
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RawEyeTrc2E_sbd';
    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);
        for iTriali = 1:length(datas1)
            iTrial = datas1(iTriali);
            EyeLoc = [];
            EyeLoc = sbd.SacTraGoc2E1{iTrial}(:,1:4);
            TargLocTREnd = sbd.TargLocSacEndAtcpTR2E(iTrial,1:2);
            % Remove target location that is too large
            polarplot(EyeLoc(:,3),EyeLoc(:,4),'LineWidth',0.6,'Color',colorRGB(iCond,:));
            hold on
            polarplot(TargLocTREnd(1),TargLocTREnd(2),'k.', 'MarkerSize', 7,'LineWidth',1.5)
            % add lines
            polarplot([EyeLoc(end,3),TargLocTREnd(1)],[EyeLoc(end,4),TargLocTREnd(2)],...
                'LineWidth',1,'Color','k','LineStyle','-');
        end
        rlim([0,12])
        title(LegText{iCond},'FontWeight','normal');
        set(gca,'FontSize',15)
        hold off
    end
    saveas(gcf,[ResultDir,SaveName,'_',RcdFilesName{iSession},'.fig'])
end

%% 2 Check the KL divergency
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacDir2EKL';

    StepSZ = deg2rad(2); % the size of step
    fSigma = 0.3;
    vfEstimate = [];

    for iCond = CondI
        datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);
        EyeEndTta = zeros(size(datas1));
        EyeEndTta = wrapTo2Pi(sbd.SacEndTR2E(datas1,1));
        vfPDFSamples = 0:StepSZ:2*pi;
        vfEstimate(iCond,:) = circ_ksdensity(EyeEndTta, vfPDFSamples, [0, 2*pi], fSigma);
    end

    klDivg = [];
    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        vfEstimate2 = []; vfEstimate2 = vfEstimate(iCond,:);
        vfEstimate1 = []; vfEstimate1 = vfEstimate(1,:);
        klDivg(iCond,:) = circ_kldivergence(vfEstimate2,vfEstimate1,vfPDFSamples);
        p2 = polarplot(vfPDFSamples,klDivg(iCond,:),'LineWidth',2,'Color',colorRGB(iCond,:));
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)
        rlim([-0.2,0.5])
        hold on
    end
    saveas(gcf,[ResultDir,SaveName,'_',RcdFilesName{iSession},'.fig'])
end

%% 3 plot the ending error as a function of target location in cartesian
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2E_XY_Normed';
    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);

        XV = []; YV = [];
        XAve = []; YAve = []; YStd = [];
        XV = mod(rad2deg(wrapTo2Pi(sbd.TargLocSacEndAtcpTR2E(datas1,1)))-90,360);
        % XV = rad2deg(wrapTo2Pi(sbd.TargLocSacEndAtcpTR2E(datas1,1)));
        YV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1));
        % YV = rad2deg(sbd.SacEndErrAng2ESign(datas1));
        % I need to plot on the xy coordinates
        FM_CartScat(XV, YV, iCond, [-10,370], [-50,50]);

        % plot the sliding window
        XV = wrapTo2Pi(deg2rad(XV));
        YV = sbd.SacEndErrAng2ESignDeSta(datas1);
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0,2*pi];
        [XAve, YAve, YStd] = FM_CartScaSlidWin_PolData2(winSize,stepSize,XV,YV,winRange);
        % use boundedline to plot which can also skip the nan point
        XAve = rad2deg(XAve);
        YAve = rad2deg(YAve);
        YStd = rad2deg(YStd);
        [hl,hp] = boundedline(XAve,YAve,YStd);
        set(hl,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

        xticks([0,90,180,270,360]);
        % xticklabels([90,180,270,0,90])
        yticks([-50,-25,0,25,50])

        if iCond == 1
            xlabel('Targ Direction at Sacc End, deg')
            ylabel('Sacc Targ Direction Difference, deg')
        end
        hold on
        xline(180,'LineWidth',1.5,'LineStyle','--');
        xline(90,'LineWidth',1.5,'LineStyle','--');
        xline(270,'LineWidth',1.5,'LineStyle','--')

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)

    end
    saveas(gcf,[ResultDir,SaveName,'_',RcdFilesName{iSession},'.fig'])
end

%% 4 plot the RT as a function of target location in cartesian
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_Tar_2E_XY_Normed';
    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);

        XV = []; YV = [];
        XAve = []; YAve = []; YStd = [];
        XV = mod(rad2deg(wrapTo2Pi(sbd.TargLocSacEndAtcpTR2E(datas1,1)))-90,360);
        % XV = rad2deg(wrapTo2Pi(sbd.TargLocSacEndAtcpTR2E(datas1,1)));
        YV = sbd.SacRTGoc1(datas1);
        % YV = rad2deg(sbd.SacEndErrAng2ESign(datas1));
        % I need to plot on the xy coordinates
        FM_CartScat(XV, YV, iCond, [-10,370], [100,400]);

        % 
        xticks([0,90,180,270,360]);
        xticklabels([90,180,270,0,90])
        % yticks([-50,-25,0,25,50])

        if iCond == 1
            xlabel('Targ Direction at Sacc End, deg')
            ylabel('RT,ms')
        end
        hold on
        xline(180,'LineWidth',1.5,'LineStyle','--');
        xline(90,'LineWidth',1.5,'LineStyle','--');
        xline(270,'LineWidth',1.5,'LineStyle','--')

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)

    end
    saveas(gcf,[ResultDir,SaveName,'_',RcdFilesName{iSession},'.fig'])
end

%% 4 RT as a function of saccade ending error
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RTDeSta_SacEndErr2E';
    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);

        XV = []; YV = [];
        % XV = abs(rad2deg(sbd.SmPAVelGoc1(datas1,1)));
        XV = sbd.SacRTGoc1DeSta(datas1,1);
        YV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1));
        % I still need to remove some impossible value
        % I need to plot on the xy coordinates
        XLim = [-250,250];
        YLim = [-60,60];
        FM_CartScat(XV, YV, iCond, XLim, YLim);
        yticks([-50,-25,0,25,50])

        if iCond == 1
            xlabel('RT - Sta, ms')
            ylabel('Sacc Targ Direction Difference, deg')
        end

        [StatResult] = FM_FitLinearR(XV,YV);
        % plot the linear regression results
        hold on
        XVLim = [min(XV),max(XV)]; YVLim = [min(YV),max(YV)];
        plot([XVLim(1),XVLim(2)],[XVLim(1),XVLim(2)]*StatResult.SlopeK+StatResult.InterceptB,'--k','LineWidth',2);
        value_text = sprintf('r = %.4f\np = %.4f', StatResult.r_value,StatResult.p_value);
        text(XLim(2)-150, YLim(2)-(YLim(2)-YLim(1))/10, value_text, 'FontSize', 14);
        % text(Xlim(1)+(Xlim(2)-Xlim(1))/20, Ylim(2)-0.4, p_value_text, 'FontSize', 12);
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)

    end
    saveas(gcf,[ResultDir,SaveName,'_',RcdFilesName{iSession},'.fig'])
end

%% 5 RT as a function of saccade ending error
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_SacEndErr2E';
    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);

        XV = []; YV = [];
        % XV = abs(rad2deg(sbd.SmPAVelGoc1(datas1,1)));
        XV = sbd.SacRTGoc1(datas1,1);
        YV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1));
        % I still need to remove some impossible value
        % I need to plot on the xy coordinates
        XLim = [0, 400];
        YLim = [-60,60];
        FM_CartScat(XV, YV, iCond, XLim, YLim);
        yticks([-50,-25,0,25,50])

        if iCond == 1
            xlabel('RT, ms')
            ylabel('Sacc Targ Direction Difference, deg')
        end

        [StatResult] = FM_FitLinearR(XV,YV);
        % plot the linear regression results
        hold on
        XVLim = [min(XV),max(XV)]; YVLim = [min(YV),max(YV)];
        plot([XVLim(1),XVLim(2)],[XVLim(1),XVLim(2)]*StatResult.SlopeK+StatResult.InterceptB,'--k','LineWidth',2);
        value_text = sprintf('r = %.4f\np = %.4f', StatResult.r_value,StatResult.p_value);
        text(XLim(2)-150, YLim(2)-(YLim(2)-YLim(1))/10, value_text, 'FontSize', 14);
        % text(Xlim(1)+(Xlim(2)-Xlim(1))/20, Ylim(2)-0.4, p_value_text, 'FontSize', 12);
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)

    end
    saveas(gcf,[ResultDir,SaveName,'_',RcdFilesName{iSession},'.fig'])
end

%% 6 plot the smooth Pursuit vel as a func of post sacc time
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/PostSaccSmpLVel_SacEndErr2E';

    lStyle = {'--','-.',':','-'};

    GrpIdx = cell(1,length(CondI));
    EndErrGrpAve = cell(1,length(CondI));
    SmPLVelAllGrp = cell(1,length(CondI));
    SmPLVelAllGrpAve = cell(1,length(CondI));
    SmPLVelAllGrpStd = cell(1,length(CondI));

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);
        EndErr = []; SmPLVelAll = [];

        EndErr = sbd.SacEndErrAng2ESignDeSta(datas1);
        SmPLVelAll = cell2mat(sbd.SmPLVelAllGoc1(datas1));
        SmPTime = 1:size(SmPLVelAll,2);

        % seperate the EndErr into four group
        EndErrEdge = quantile(EndErr,0:0.25:1);

        GrpIdx{iCond} = cell(1,4);
        EndErrGrpAve{iCond} = nan(1,4);
        SmPLVelAllGrp{iCond} = cell(1,4);
        SmPLVelAllGrpAve{iCond} = nan(4,500);
        SmPLVelAllGrpStd{iCond} = nan(4,500);

        hold on
        hl = []; hp = [];
        for iGrp = 1:length(EndErrEdge)-1
            GrpIdx{iCond}{iGrp} = find(EndErr>=EndErrEdge(iGrp) & EndErr<=EndErrEdge(iGrp+1));
            EndErrGrpAve{iCond}(iGrp) = circ_mean_nan(EndErr(GrpIdx{iCond}{iGrp}));
            SmPLVelAllGrp{iCond}{iGrp} = SmPLVelAll(GrpIdx{iCond}{iGrp},:);
            SmPLVelAllGrpAve{iCond}(iGrp,:) = mean(SmPLVelAllGrp{iCond}{iGrp},'omitmissing');
            SmPLVelAllGrpStd{iCond}(iGrp,:) = std(SmPLVelAllGrp{iCond}{iGrp},'omitmissing');

            % plot the result
            % [hl{iGrp},hp{iGrp}] = boundedline(SmPTime,SmPLVelAllGrpAve{iCond}(iGrp,:),SmPLVelAllGrpStd{iCond}(iGrp,:));
            % set(hl{iGrp},'color','k','LineStyle',lStyle{iGrp},'LineWidth',1.5);
            % set(hp{iGrp},'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
            if iGrp == 1
                plot(SmPTime,smooth(SmPLVelAllGrpAve{iCond}(iGrp,:)),'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',2)
            elseif iGrp == 4
                plot(SmPTime,smooth(SmPLVelAllGrpAve{iCond}(iGrp,:)),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2)
            end
        end
        ylim([10,70])

        if iCond == 1
            xlabel('Post Interceptive Saccade Time, ms')
            ylabel('Pursuit Linear Vel, deg/s')
        end
        legend({['LQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(1)),'%.2f')],...
            ['HQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(4)),'%.2f')]},'Box','off','Location','southeast','FontSize',15);

        hold off

        set(gca,'FontSize',15)
        title(LegText{iCond},'FontWeight','normal')
    end
    % sbd.ErrGrpIdx = GrpIdx;
    % sbd.EndErrGrpAve = EndErrGrpAve;
    % sbd.SmPLVelAllGrp = SmPLVelAllGrp;
    % sbd.SmPLVelAllGrpAve = SmPLVelAllGrpAve;

    saveas(gcf,[ResultDir,SaveName,'_',RcdFilesName{iSession},'.fig'])
end

%% 7 Quick check that if smp vel Linear is related with ending error
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr2E_Normed_SmPVel_Linear_50_150';
    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);

        XV = []; YV = [];
        % XV = abs(rad2deg(sbd.SmPAVelGoc1(datas1,1)));
        XV = sbd.SmPLVelGoc1(datas1,1);
        YV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1));
        % I need to plot on the xy coordinates
        XLim = [10,70];
        YLim = [-60,60];
        FM_CartScat(XV, YV, iCond, XLim, YLim);
        yticks([-50,-25,0,25,50])

        if iCond == 1
            xlabel('Linear Pursuit Vel [50,150]ms, deg/sec')
            ylabel('Sacc Targ Direction Difference, deg')
        end

        [StatResult] = FM_FitLinearR(XV,YV);
        % plot the linear regression results
        hold on
        XVLim = [min(XV),max(XV)]; YVLim = [min(YV),max(YV)];
        plot([XVLim(1),XVLim(2)],[XVLim(1),XVLim(2)]*StatResult.SlopeK+StatResult.InterceptB,'--k','LineWidth',2);
        value_text = sprintf('r = %.4f\np = %.4f', StatResult.r_value,StatResult.p_value);
        text(XLim(2)-20, YLim(2)-(YLim(2)-YLim(1))/10, value_text, 'FontSize', 14);
        % text(Xlim(1)+(Xlim(2)-Xlim(1))/20, Ylim(2)-0.4, p_value_text, 'FontSize', 12);
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)

    end
    saveas(gcf,[ResultDir,SaveName,'_',RcdFilesName{iSession},'.fig'])
end

