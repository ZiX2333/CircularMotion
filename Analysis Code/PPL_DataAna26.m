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
Rlim1 = [-1,1];
Rlim2 = [-2,2];
Rlim3 = [0,2];
rScalar = ceil(deg2rad(30)*10)/10;

%% 1 check if the ending error versus targ dir is correct by the new method
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2E_XY';

    TargAve1 = cell(size(CondI));
    EndErrAve = cell(size(CondI));

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));

        XV = []; YV = []; RhoVAve = []; RhoVStd = []; XAve = []; YAve = []; YStd = [];
        XV = mod(rad2deg(wrapTo2Pi(sbd.TarEnd2E(3,datas1)))-90,360);
        YV = rad2deg(sbd.SacEndErrAng2ESignDeSta(datas1));
        % I need to plot on the xy coordinates
        F_CartScat(XV, YV, iCond, [-10,370], [-50,50]);

        % plot the sliding window
        XV = wrapTo2Pi(deg2rad(XV));
        YV = wrapToPi(deg2rad(YV));
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0,2*pi];
        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV',winRange);
        % use boundedline to plot which can also skip the nan point
        XAve = rad2deg(XAve);
        YAve = rad2deg(YAve);
        YStd = rad2deg(YStd);
        [hl,hp] = boundedline(XAve,YAve,YStd);
        set(hl,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

        TargAve1{iCond} = XAve;
        EndErrAve{iCond} = YAve;

        xticks([0,90,180,270,360]);
        xticklabels([90,180,270,0,90])
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

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 do the same for RT versus targ dir
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_Tar_2E_XY_NoNorm';

    TargAve2 = cell(size(CondI));
    RTAve = cell(size(CondI));

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));

        XV = []; YV = []; RhoVAve = []; RhoVStd = []; XAve = []; YAve = []; YStd = [];
        XV = mod(rad2deg(wrapTo2Pi(sbd.TarEnd2E(3,datas1)))-90,360);
        YV = sbd.SacRTGoc1(datas1);
        % I need to plot on the xy coordinates
        F_CartScat(XV, YV, iCond, [-10,370], [80,500]);

        % plot the sliding window
        XV = wrapTo2Pi(deg2rad(XV));
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0,2*pi];
        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData1(winSize,stepSize,XV',YV',winRange);
        % use boundedline to plot which can also skip the nan point
        XAve = rad2deg(XAve);
        
        TargAve2{iCond} = XAve;
        RTAve{iCond} = YAve;
        
        [hl,hp] = boundedline(XAve,YAve,YStd);
        set(hl,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

        
        xticks([0,90,180,270,360]);
        xticklabels([90,180,270,0,90])
        % yticks([-50,-25,0,25,50])

        if iCond == 1
            xlabel('Targ Direction at Sacc End, deg')
            ylabel('RT, ms')
        end
        hold on
        xline(180,'LineWidth',1.5,'LineStyle','--');
        xline(90,'LineWidth',1.5,'LineStyle','--');
        xline(270,'LineWidth',1.5,'LineStyle','--')

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)
    end

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 3 Remove the targ traj trend for Err
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2E_XY_DeTrend';

    TargAve1 = cell(size(CondI));
    EndErrAve = cell(size(CondI));

    sbd.SacEndErrAng2ESignDeStaDeTrend = nan(size(Dataf));

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        
        YVNoNorm = [];
        XV = []; YV = []; RhoVAve = []; RhoVStd = []; XAve = []; YAve = []; YStd = [];
        XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        YVNoNorm = sbd.SacEndErrAng2ESignDeSta(datas1);
        % remove the trend
        winSize = pi/9; stepSize = winSize;
        [~, YV, ~] = F_CartScaMovNorm(winSize,stepSize,XV',XV',YVNoNorm',YVNoNorm',[0,2*pi-winSize]);

        sbd.SacEndErrAng2ESignDeStaDeTrend(datas1) = YV;
        
        % I need to plot on the xy coordinates
        F_CartScat(XV, YV, iCond, deg2rad([-10,370]), deg2rad([-50,50]));

        xticks(deg2rad([0,90,180,270,360]));
        xticklabels([90,180,270,0,90]);
        yticks(deg2rad(-50:25:50));
        yticklabels(-50:25:50);

        if iCond == 1
            xlabel('Targ Direction at Sacc End, deg')
            ylabel('Sacc Targ Direction Difference Variance, deg')
        end
        hold on
        xline(180,'LineWidth',1.5,'LineStyle','--');
        xline(90,'LineWidth',1.5,'LineStyle','--');
        xline(270,'LineWidth',1.5,'LineStyle','--')

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)
    end

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 4 Remove the targ traj trend for Err
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_Tar_2E_XY_DeTrend';

    TargAve1 = cell(size(CondI));
    EndErrAve = cell(size(CondI));

    sbd.SacRTGoc1DeTrend = nan(size(Dataf));

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        
        YVNoNorm = [];
        XV = []; YV = []; RhoVAve = []; RhoVStd = []; XAve = []; YAve = []; YStd = [];
        XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        YVNoNorm = sbd.SacRTGoc1(datas1);
        % remove the trend
        winSize = pi/9; stepSize = winSize;
        [~, YV, ~] = F_CartScaMovNorm2(winSize,stepSize,XV',XV',YVNoNorm',YVNoNorm',[0,2*pi-winSize]);

        sbd.SacRTGoc1DeTrend(datas1) = YV;
        
        % I need to plot on the xy coordinates
        F_CartScat(XV, YV, iCond, deg2rad([-10,370]), [-150,150]);

        xticks(deg2rad([0,90,180,270,360]));
        xticklabels([90,180,270,0,90]);
        yticks(-150:50:150);
        yticklabels(-150:50:150);

        if iCond == 1
            xlabel('Targ Direction at Sacc End, deg')
            ylabel('RT variance, ms')
        end
        hold on
        xline(180,'LineWidth',1.5,'LineStyle','--');
        xline(90,'LineWidth',1.5,'LineStyle','--');
        xline(270,'LineWidth',1.5,'LineStyle','--')

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',15)
    end

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% 5 Detrend RT relation with Detrend Err
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RTZs_SacEndErr2E_DeTrend';

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        YV = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = []; XVZs = [];
        % XV = sbd.SacEndErrAng2CSign2(datas1);
        % YV = sbd.SacRTGoc1(datas1);
        XV = sbd.SacRTGoc1DeTrend(datas1);
        YV = sbd.SacEndErrAng2ESignDeStaDeTrend(datas1); 
        % YV = sbd.SacEndErrAng2CSign2(datas1);
        % I need to plot on the xy coordinates
        YLim = [-pi/4,pi/4]; XLim = [-150,150];
        F_CartScat(XV, YV, iCond,XLim,YLim);
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        yticklabels({-45,-30,-15,0,15,30,45});

        if iCond == 1
            xlabel('RT variance, ms')
            ylabel('Sacc Targ Direction Difference Variance, deg')
        end

        hold on
        F_FitLinearR(XV,YV,XLim,YLim)
        hold off

        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 6 Smooth pursuit velocity as a function of time seperated by ending error
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/PostSaccSmpLVel_SacEndErr2E';

    lStyle = {'--','-.',':','-'};

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EndErr = []; SmPLVelAll = [];

        EndErr = sbd.SacEndErrAng2ESignDeSta(datas1);
        SmPLVelAll = sbd.SmPLVelAllGoc1(datas1,:);
        SmPTime = 1:size(SmPLVelAll,2);

        % seperate the EndErr into four group
        EndErrEdge = quantile(EndErr,0:0.25:1);
        
        GrpIdx = cell(1,4);
        EndErrGrpAve = nan(1,4);
        SmPLVelAllGrp = cell(1,4);
        SmPLVelAllGrpAve = nan(4,500);
        SmPLVelAllGrpStd = nan(4,500);
        
        hold on
        hl = []; hp = [];
        for iGrp = 1:length(EndErrEdge)-1
            GrpIdx{iGrp} = find(EndErr>=EndErrEdge(iGrp) & EndErr<=EndErrEdge(iGrp+1));
            EndErrGrpAve(iGrp) = circ_mean_nan(EndErr(GrpIdx{iGrp})');
            SmPLVelAllGrp{iGrp} = SmPLVelAll(GrpIdx{iGrp},:);
            SmPLVelAllGrpAve(iGrp,:) = mean(SmPLVelAllGrp{iGrp},'omitmissing');
            SmPLVelAllGrpStd(iGrp,:) = std(SmPLVelAllGrp{iGrp},'omitmissing');

            % plot the result
            % [hl{iGrp},hp{iGrp}] = boundedline(SmPTime,SmPLVelAllGrpAve(iGrp,:),SmPLVelAllGrpStd(iGrp,:));
            % set(hl{iGrp},'color','k','LineStyle',lStyle{iGrp},'LineWidth',1.5);
            % set(hp{iGrp},'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
            if iGrp == 1
                plot(SmPTime,smooth(SmPLVelAllGrpAve(iGrp,:)),'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',2)
            elseif iGrp == 4
                plot(SmPTime,smooth(SmPLVelAllGrpAve(iGrp,:)),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2)
            end
        end
        ylim([0,50])

        if iCond == 1
            xlabel('Post Interceptive Saccade Time, ms')
            ylabel('Pursuit Linear Vel, deg/s')
            legend({'Lower Quartile','Higher Quartile'},'Box','off','Location','northwest','FontSize',15);
        end

        hold off
        
        set(gca,'FontSize',15)
        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end




