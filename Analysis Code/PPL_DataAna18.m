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
% Adjusted on May 17, Keep focusing on ending error analysis
% Adjusted on July 10, More Analysis on ending error, the relation with
%                     tilting, and RT

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
Rlim1 = [-1,1];
Rlim2 = [-2,2];
Rlim3 = [0,2];
rScalar = ceil(deg2rad(30)*10)/10;

%% 1 RT and Saccade Ending error
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
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        YV = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        EndErr = sbd.SacEndErrAng2ESign2Normed_TarNoOrder{iCond};
        % XV = sbd.SacEndErrAng2CSign2(datas1);
        % YV = sbd.SacRTGoc1(datas1);
        YV = sbd.SacRTGoc1(datas1);
        XV = EndErr - mean(EndErr); % use the compered ending error data  % remove the global effect of the endingerror
        % YV = sbd.SacEndErrAng2CSign2(datas1);
        % I need to plot on the xy coordinates
        YLim = [-pi/4,pi/4]; XLim = [100,400];
        F_CartScat(YV, XV, iCond,XLim,YLim);
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        yticklabels({-45,-30,-15,0,15,30,45});

        if iCond == 1
            xlabel('Reaction time, ms')
            ylabel('SaccEnd-Tar Direction Difference,deg')
        end

        hold on
        F_FitLinearR(YV,XV,XLim,YLim)
        hold off


        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 RT and Target location at Saccade end
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_TarSacEnd2E';

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        YV = []; XV = []; XAve = []; YAve = []; YStd = [];
        % XV = mod(rad2deg(wrapTo2Pi(sbd.TarEnd2E(3,datas1)))-90,360);
        YV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,pi*2);
        XV = sbd.SacRTGoc1(datas1);

        % I need to plot on the xy coordinates
        F_CartScat(YV, XV, iCond, deg2rad([0,360]), [100,400]);
        winSize = pi/4;
        winRange = [0, 2*pi];
        stepSize = winSize/10;
        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData1(winSize,stepSize,YV',XV,winRange);
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        if iCond == 1
            xlabel('Target location at saccade end, deg')
            ylabel('Reaction time, ms')
        end

        % use boundedline to plot which can also skip the nan point
        % [hl,hp] = boundedline(XAve,YAve,YStd);
        [hl,hp] = boundedline(XAve,YAve,0);
        set(hl,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

        set(gca,'FontSize',14)


        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% 3 RT and Saccade End and Target Location plot in 3D
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_TarSacEnd_SacEndErr2E';

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        YV = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        EndErr = sbd.SacEndErrAng2ESign2Normed_TarNoOrder{iCond};
        YV = sbd.SacRTGoc1(datas1);
        XV = mod(rad2deg(wrapTo2Pi(sbd.TarEnd2E(3,datas1)))-90,360);
        ZV = EndErr - mean(EndErr);

        % use scatter3 to check how it is in 3D plots
        scatter3(YV,XV,ZV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none',...
            'MarkerFaceAlpha',0.6);
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
        xlim([100,400])

        ylim([0,360])
        yticks(rad2deg([0,pi/2,pi,3*pi/2,2*pi]));
        % yticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        yticklabels({90,180,270,0,90});

        zlim([-pi/4,pi/4]);
        zticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        zticklabels({-45,-30,-15,0,15,30,45});

        if iCond == 1
            xlabel('Reaction time, ms')
            ylabel('Target location at saccade end, deg')
            zlabel('Sacc Ending Error, deg')
        end

        set(gca,'FontSize',14)

        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 4 Group the target location

SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_TarSacEnd_SacEndErr2E_Grouped';

    % Define positions for 8 panels in a 2x4 grid
    panelPositions = [
        0, 0.5, 0.25, 0.5;
        0.25, 0.5, 0.25, 0.5;
        0.5, 0.5, 0.25, 0.5;
        0.75, 0.5, 0.25, 0.5;
        0.25, 0, 0.25, 0.5;
        0.5, 0, 0.25, 0.5;
        0.75, 0, 0.25, 0.5;
        ];
    GWin = [0,270,90,180; 90,360,180,270];
    GTitle = {'90-180 deg', '0-90 deg','180-270 deg','270-0 deg'};

    for iCond = CondI
        hp = [];
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        YV = []; XV = []; EndErr = []; GInfo = []; % grouping based on this para
        GInfo = mod(rad2deg(wrapTo2Pi(sbd.TarEnd2E(3,datas1)))-90,360);
        EndErr = sbd.SacEndErrAng2ESign2Normed_TarNoOrder{iCond};
        YV = sbd.SacRTGoc1(datas1);
        XV = EndErr;

        hp = uipanel('Position', panelPositions(iCond,:),'BackgroundColor','w',...
            'Title',LegText{iCond},'FontSize',14,'TitlePosition','centertop',...
            'BorderType','none');
        % hp = uipanel('Position', panelPositions(iCond,:));
        t = tiledlayout(hp,2,2,'TileSpacing','compact');

        for iGWin = 1:length(GWin)
            nexttile(t)
            GInd = GInfo >= GWin(1,iGWin) & GInfo < GWin(2,iGWin);
            % plot the XV and YV with this selected index
            YLim = [-pi/4,pi/4]; XLim = [100,400];
            F_CartScat(YV(GInd), XV(GInd), iCond, XLim, YLim,0); % dont give the title
            hold on
            % ylim([-pi/4,pi/4]);
            yticks([-pi/4,0,pi/4]);
            yticklabels({-45,0,45});

            F_FitLinearR(YV(GInd),XV(GInd),XLim,YLim)

            if iCond == 1 && iGWin == 1
                xlabel('RT, ms')
                ylabel('SaccEnd-Tar Dir Diff,deg')
            end

            title(GTitle{iGWin},'FontWeight','normal')
            set(gca,'FontSize',10)
            hold off
        end

    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 5 corr2 between [TarLoc, EndErr] and [TarLoc, RT]
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RT_TarSacEnd_SacEndErr2E_Corr2';

    winSize = pi/4;
    stepSize = winSize/10;
    % winRange = [-winSize+stepSize, 2*pi-stepSize];
    winRange = [0, 2*pi];

    for iCond = CondI
        s1 = []; s2 = [];
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        YV1 = []; YV2 = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
        EndErr = sbd.SacEndErrAng2ESign2Normed_TarNoOrder{iCond};
        XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
        YV1 = EndErr - mean(EndErr);
        YV2 = sbd.SacRTGoc1(datas1);

        % plot the left yaxis first
        yyaxis left
        s1 = scatter(XV,YV1,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none',...
            'MarkerFaceAlpha',0.6);

        xlim([0,2*pi])
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        % yticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});

        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        yticklabels({-45,-30,-15,0,15,30,45});

        % plot the sliding window
        XAve = []; YAve = []; YStd = [];
        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV1',winRange);

        hl1 = []; hp1 = [];
        hold on
        [hl1,hp1] = boundedline(XAve,YAve,YStd);
        set(hl1,'color','k','LineStyle','-.','LineWidth',1.5);
        set(hp1,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
        hold off

        % Add label
        if iCond == 1
            xlabel('Target location at saccade end, deg')
            ylabel('Sacc Ending Error, deg')
        end

        % plot the right yaxis
        yyaxis right
        s2 = scatter(XV,YV2,'MarkerEdgeColor',colorRGB2(iCond,:),'LineWidth',2,'Marker','x');

        ylim([100,400])

        if iCond == 1
            ylabel('Reaction time, ms')
        end

        % plot the sliding window
        XAve = []; YMed = []; YQuaL = []; YQuaU = [];
        [XAve, YMed, YQuaL, YQuaU] = F_CartScaSlidWin_PolData3(winSize,stepSize,XV',YV2',winRange);

        hl2 = []; hp2 = [];
        hold on
        [hl2,hp2] = boundedline(XAve,YMed,[YQuaU-YMed;YMed-YQuaL]');
        set(hl2,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp2,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

        % add the x lines for checking
        xline(pi/2,'LineWidth',1.5,'LineStyle','--');
        xline(pi,'LineWidth',1.5,'LineStyle','--');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle','--');
        hold off

        % add the corr2 result
        [corr_matrix,p_matrix] = corrcoef([YV1;XV], [YV2;XV]);
        r_value = corr_matrix(1,2); % r-value between x and y
        p_value = p_matrix(1,2);
        XLim = [0,2*pi]; YLim = [100,400];
        value_text = sprintf('r = %.2f\np = %.2f', r_value,p_value);
        text(XLim(1)+(XLim(2)-XLim(1))/20, YLim(2)-(YLim(2)-YLim(1))/10, value_text, 'FontSize', 12);

        if iCond == 1
            legend([s1,hl1,s2,hl2],{'End Err','End Err Slid Mean','RT','RT Slid Median'},...
                'Box','on','AutoUpdate','off','Color','w','EdgeColor','w');
        end

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)

    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 6 do a bootstrap on RT
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = '/RT_TarSacEnd_SacEndErr_BootS';

winSize = pi/4;
stepSize = winSize/10;
% winRange = [-winSize+stepSize, 2*pi-stepSize];
winRange = [0,2*pi];

for iCond = CondI
    nexttile
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile
    end
    datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    YV1 = []; YV2 = []; XV = []; XAve = []; YAve = []; YStd = []; EndErr = [];
    EndErr = sbd.SacEndErrAng2ESign2Normed_TarNoOrder{iCond};
    XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,2*pi);
    YV1 = EndErr;
    YV2 = sbd.SacRTGoc1(datas1);

    %% plot the left yaxis first
    yyaxis left
    % plot the scatter plot first
    s1 = scatter(XV,YV1,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none',...
        'MarkerFaceAlpha',0.6);
    xlim([0,2*pi])
    xticks([0,pi/2,pi,3*pi/2,2*pi]);
    % yticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
    xticklabels({90,180,270,0,90});
    ylim([-pi/4,pi/4]);
    yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
    yticklabels({-45,-30,-15,0,15,30,45});

    % plot the sliding window
    SampS = floor(length(XV)*1);
    SampXAve = []; SampYAve = []; SampYStd = [];
    [SampXAve,SampYAve,SampYStd] = F_BootSCartSlidWin2(XV',YV1',SampS,1000,winSize,stepSize,winRange);

    % clean space for the variables
    SampXAveAve = []; SampYAveAve = [];SampYLCI95 = []; SampYUCI95 = [];
    SampYLCI90 = []; SampYUCI90 = []; SampYUCI95Ave = []; SampYLCI95Ave = []; SampYStdErr = [];

    for iSampY = 1:size(SampYAve,2)
        SampXAveAve(iSampY) = nan;
        SampYAveAve(iSampY) = nan;
        % nan_mean
        % SampYAveAve(iSampY) = circ_mean(SampYAve(~isnan(SampYAve(:,iSampY)),iSampY));
        % SampYAveAve(iSampY) = nanmean(SampYAve(~isnan(SampYAve(:,iSampY)),iSampY));
        SampXAveAve(iSampY) = nanmean(SampXAve(:,iSampY));
        SampYAveAve(iSampY) = circ_mean_nan(SampYAve(:,iSampY));
        SampYLCI95(iSampY) = prctile(SampYAve(:,iSampY), 2.5);
        SampYUCI95(iSampY) = prctile(SampYAve(:,iSampY), 97.5);
        SampYUCI95Ave(iSampY) = SampYUCI95(iSampY) - SampYAveAve(iSampY);
        SampYLCI95Ave(iSampY) = SampYAveAve(iSampY) - SampYLCI95(iSampY);
        SampYStdErr(iSampY) = circ_std_nan(SampYAve(:,iSampY));
    end

    % use boundedline to plot which can also skip the nan point
    hold on
    [hl1,hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
    set(hl1,'color','k','LineStyle','--','LineWidth',1.5);
    set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
    hold off

    % Add label
    if iCond == 1
        xlabel('Target location at saccade end, deg')
        ylabel('Sacc Ending Error, deg')
    end

    %% plot the bootstrap sliding window on the right axis
    yyaxis right
    % plot the scatter first
    s2 = scatter(XV,YV2,'MarkerEdgeColor',colorRGB2(iCond,:),'LineWidth',2,'Marker','x');
    ylim([100,400])

    % plot the sliding window
    SampS = floor(length(XV)*1);
    SampXAve = []; SampYAve = []; SampYStd = [];
    [SampXAve,SampYAve,SampYStd] = F_BootSCartSlidWin1(XV',YV2',SampS,1000,winSize,stepSize,winRange);

    % clean space for the variables
    SampXAveAve = []; SampYAveAve = [];SampYLCI95 = []; SampYUCI95 = [];
    SampYUCI95Ave = []; SampYLCI95Ave = []; SampYStdErr = [];

    for iSampY = 1:size(SampYAve,2)
        SampXAveAve(iSampY) = nan;
        SampYAveAve(iSampY) = nan;
        % nan_mean
        % SampYAveAve(iSampY) = circ_mean(SampYAve(~isnan(SampYAve(:,iSampY)),iSampY));
        % SampYAveAve(iSampY) = nanmean(SampYAve(~isnan(SampYAve(:,iSampY)),iSampY));
        SampXAveAve(iSampY) = nanmean(SampXAve(:,iSampY));
        SampYAveAve(iSampY) = nanmean(SampYAve(:,iSampY));
        SampYLCI95(iSampY) = prctile(SampYAve(:,iSampY), 2.5);
        SampYUCI95(iSampY) = prctile(SampYAve(:,iSampY), 97.5);
        SampYUCI95Ave(iSampY) = SampYUCI95(iSampY) - SampYAveAve(iSampY);
        SampYLCI95Ave(iSampY) = SampYAveAve(iSampY) - SampYLCI95(iSampY);
        SampYStdErr(iSampY) = nanstd(SampYAve(:,iSampY));
    end

    RTBootS(iCond).SampXAve = SampXAve;
    RTBootS(iCond).SampYAve = SampYAve;
    RTBootS(iCond).SampYStd = SampYStd;
    RTBootS(iCond).SampXAveAve = SampXAveAve;
    RTBootS(iCond).SampYAveAve = SampYAveAve;
    RTBootS(iCond).SampYCI95 = [SampYLCI95;SampYUCI95];
    RTBootS(iCond).SampYStdErr = SampYStdErr;

    % use boundedline to plot which can also skip the nan point
    hold on
    [hl2,hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
    set(hl2,'color','k','LineStyle','-','LineWidth',1.5);
    set(hp,'FaceColor',colorRGB(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')
    
    % plot the reference line
    xline(pi/2,'LineWidth',1.5,'LineStyle',':');
    xline(pi,'LineWidth',1.5,'LineStyle',':');
    xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
    hold off

    if iCond == 1
        ylabel('Reaction time, ms')
        legend([s1,hl1,s2,hl2],{'End Err','End Err BootS','RT','RT BootS'},...
            'FontSize',14,'Box','off','AutoUpdate','off')
    end

    set(gca,'FontSize',14)
    title(LegText{iCond},'FontWeight','normal')
end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end
