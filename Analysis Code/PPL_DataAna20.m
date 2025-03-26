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


%% 1 sliding window on cartesian
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Sac_2E_XY_Norm';

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        XV = []; YV = []; XAve = []; YAve = []; YStd = [];
        XV = mod(wrapTo2Pi(sbd.SacEndErrAng2ESign2Normed_Sac{iCond}(1,:))-pi/2,pi*2);
        YV = sbd.SacEndErrAng2ESign2Normed_Sac{iCond}(2,:);

        % I need to plot on the xy coordinates
        F_CartScat(XV, YV, iCond, [-pi/18,2*pi+pi/18], [-pi/9,pi/9]);
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45});
        if iCond == 1
            xlabel('Saccade Direction at Sacc End')
            ylabel('De-Sta-Trend Sacc-End Direction Difference')
        end
        hold on
        xline(pi/2,'LineWidth',1.5,'LineStyle','--');
        xline(pi,'LineWidth',1.5,'LineStyle','--');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle','--');

        % plot the sliding window
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0, 2*pi];
        [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV',winRange);

        % % plot the error bar first
        % fill([XAve,fliplr(XAve)],[YAve-YStd,fliplr(YAve+YStd)],colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
        % % plot the sliding trace
        % plot(XAve,YAve,'k','LineStyle','-','LineWidth',1.5);

        % use boundedline to plot which can also skip the nan point
        [hl,hp] = boundedline(XAve,YAve,YStd);
        set(hl,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 do a bootstrap
SecNum = SecNum+1;
% SacEndErrAngBootS = [];
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Sac_2E_XY_Norm_BootS2';

    Fig7Ax = gobjects(4,2);

    for iCond = CondI
        Fig7Ax(iCond) = nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            Fig7Ax(iCond) = nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        XV = []; YV = []; XAve = []; YAve = []; YStd = []; 
        XV = mod(wrapTo2Pi(sbd.SacEndErrAng2ESign2Normed_Sac{iCond}(1,:))-pi/2,pi*2);
        YV = sbd.SacEndErrAng2ESign2Normed_Sac{iCond}(2,:);

        % I need to plot on the xy coordinates
        F_CartScat(XV, YV, iCond, [-pi/18,2*pi+pi/18], [-pi/9,pi/9]);
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45});
        if iCond == 1
            xlabel('Saccade Direction at Sacc End')
            ylabel('De-Sta-Trend Sacc-End Direction Difference')
        end
        hold on
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');

        % plot the bootstrap sliding window
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0,2*pi];

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
        [hl,hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
        set(hl,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

        % hold on
        % plot(SampXAveAve,SampYLCI95,'k--');
        % plot(SampXAveAve,SampYUCI95,'k--');
        % hold on

        if iCond == 1
            legend(hl,'Moving ave after 1000 bootstrap','FontSize',14,'Box','off','AutoUpdate','off')
            hl1 = hl;
        end

        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% 3 based on the plot above, I'm going to add shuffling result
SecNum = SecNum+1;
% SacEndErrAngShuff = [];
if ismember(SecNum,SecPlots)
    figure(iFigAcc)
    SaveName = [];
    SaveName = '/SacEndErr_Sac_2E_XY_Norm_BootS_Shuff2';
    for iCond = CondI
        % load data first
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        XV = []; YV = []; XAve = []; YAve = []; YStd = [];
        XV = mod(wrapTo2Pi(sbd.SacEndErrAng2ESign2Normed_Sac{iCond}(1,:))-pi/2,pi*2);
        YV = sbd.SacEndErrAng2ESign2Normed_Sac{iCond}(2,:);

        % do the shuffling:
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0, 2*pi];

        SacEndErrAngShuff(iCond) = F_ShuffTest1(XV',YV',1000,winSize,stepSize,winRange);

        ShuffXAveAve = []; ShuffYAveAve = []; ShuffYLCI95Ave = []; ShuffYUCI95Ave = [];
        ShuffXAveAve = SacEndErrAngShuff(iCond).ShuffXAveAve; ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;
        ShuffYLCI95Ave = SacEndErrAngShuff(iCond).ShuffYLCI95Ave; ShuffYUCI95Ave = SacEndErrAngShuff(iCond).ShuffYUCI95Ave;

        hold on
        % plot(Fig7Ax(iCond), ShuffXAve(1,:),ShuffYAveAve,'k','LineStyle','--','LineWidth',1.5);
        % plot(Fig7Ax(iCond), ShuffXAve(1,:),ShuffYUCI,'k','LineStyle',':','LineWidth',1.5);
        % plot(Fig7Ax(iCond), ShuffXAve(1,:),ShuffYLCI,'k','LineStyle',':','LineWidth',1.5);
        % plot(Fig7Ax(iCond), ShuffXAve(1,:),ShuffYAveAve+ShuffYStdErr,'k','LineStyle','-.','LineWidth',1.5);

        % use boundedline to plot which can also skip the nan point
        [hl,hp] = boundedline(ShuffXAveAve,ShuffYAveAve,[ShuffYLCI95Ave;ShuffYUCI95Ave]',Fig7Ax(iCond));
        set(hl,'color','k','LineStyle','--','LineWidth',1.5);
        set(hp,'FaceColor',[209 209 209]./255,'FaceAlpha',0.6,'EdgeColor','none')
        hold off

        if iCond == 1
            legend([hl1,hl],{'Moving ave after 1000 bootstrap','Moving ave after 1000 shuffling'},'FontSize',14,'AutoUpdate','off')
        end
    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 4 based on the figure 7, I'm going to label the part above the threshold
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
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
        ShuffYLCI90 = SacEndErrAngShuff(iCond).ShuffYCI90(1,:);
        ShuffYUCI90 = SacEndErrAngShuff(iCond).ShuffYCI90(2,:);

        % test with 95% and 90%
        % I'm going to write a logic vector 
        Samp2Shuff95 = SampYAveAve >= ShuffYUCI95 | SampYAveAve <= ShuffYLCI95;
        Samp2Shuff90 = (SampYAveAve >= ShuffYUCI90 & SampYAveAve < ShuffYUCI95) ...
                    | (SampYAveAve <= ShuffYLCI90 & SampYAveAve > ShuffYLCI95); 

        SacEndErrAngShuff(iCond).Samp2Shuff95 = Samp2Shuff95;
        SacEndErrAngShuff(iCond).Samp2Shuff90 = Samp2Shuff90;
        
        % plot in a thicker red line chuncks
        MarkC = [205, 45, 48]/255;
        hold on
        % Find starts and ends of blocks of 95% CI
        starts = find(diff([0, Samp2Shuff95]) == 1);
        ends = find(diff([Samp2Shuff95, 0]) == -1);
        % also include the data between starts and starts-1
        for iChunk = 1:length(starts)
            %plot 95% first
            starts(iChunk) = max(1,starts(iChunk));
            ends(iChunk) = min(length(SampXAveAve),ends(iChunk));
            plot(Fig7Ax(iCond),SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
                '-','Color',MarkC,'LineWidth',3);
        end

        % % Find starts and ends of blocks of 90% CI
        % starts = find(diff([0, Samp2Shuff90]) == 1);
        % ends = find(diff([Samp2Shuff90, 0]) == -1);
        % for iChunk = 1:length(starts)
        %     %plot 90% 
        %     plot(Fig7Ax(iCond),SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
        %         ':','Color',MarkC,'LineWidth',3);
        % end

        % %plot 90% first
        % plot(Fig7Ax(iCond),SampXAve(1,Samp2Shuff90),SampYAveAve(Samp2Shuff90),'*','Color',MarkC,'LineWidth',2);
        % %plot 95% first
        % plot(Fig7Ax(iCond),SampXAve(1,Samp2Shuff95),SampYAveAve(Samp2Shuff95),'o','Color',MarkC,'LineWidth',2);
        hold off
    
    end
    sbd.SacEndErrAngBootS = SacEndErrAngBootS;
    sbd.SacEndErrAngShuff = SacEndErrAngShuff;
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 5 start a new figure, plot the 3 lines into one plot
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Sac_2E_XY_Norm_BootS_Shuff_Marked_Comp';
    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        hold on
        for iCond = CondIComp(iDir,:)
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
            SampYLCI95 = SacEndErrAngBootS(iCond).SampYCI95(1,:);
            SampYUCI95 = SacEndErrAngBootS(iCond).SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;
            if iDir == 2 && iCond == 1
                % use boundedline to plot which can also skip the nan point
                [hl{iCond},hp] = boundedline(SampXAveAve,-SampYAveAve,[-SampYUCI95Ave;-SampYLCI95Ave]');
                set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2);
                set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
            else
                % use boundedline to plot which can also skip the nan point
                [hl{iCond},hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
                set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2);
                set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
            end
        end
        for iCond = CondIComp(iDir,:)
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;

            % load the comparision
            Samp2Shuff95 = []; Samp2Shuff90 = [];
            Samp2Shuff95 = SacEndErrAngShuff(iCond).Samp2Shuff95;
            Samp2Shuff90 = SacEndErrAngShuff(iCond).Samp2Shuff90;
            if iDir == 2 && iCond == 1
                plot(SampXAveAve,-SampYAveAve,'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2)
            else
                plot(SampXAveAve,SampYAveAve,'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2)
            end

            % mark the above part
            MarkC = [205, 45, 48]/255;
            % Find starts and ends of blocks of 95% CI
            starts = find(diff([0, Samp2Shuff95]) == 1);
            ends = find(diff([Samp2Shuff95, 0]) == -1);
            % also include the data between starts and starts-1
            for iChunk = 1:length(starts)
                %plot 95% first
                starts(iChunk) = max(1,starts(iChunk));
                ends(iChunk) = min(length(SampXAveAve),ends(iChunk));
                if iDir == 2 && iCond == 1
                    plot(SampXAveAve(starts(iChunk):ends(iChunk)),-SampYAveAve(starts(iChunk):ends(iChunk)),...
                        '-','Color',colorRGB2(iCond,:),'LineWidth',4);
                else
                    plot(SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
                        '-','Color',colorRGB2(iCond,:),'LineWidth',4);
                end
            end

            % % Find starts and ends of blocks of 90% CI
            % starts = find(diff([0, Samp2Shuff90]) == 1);
            % ends = find(diff([Samp2Shuff90, 0]) == -1);
            % for iChunk = 1:length(starts)
            %     %plot 90%
            %     plot(SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
            %         ':','Color',colorRGB(iCond,:),'LineWidth',4);
            % end

        end
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        ylim([-pi/9,pi/9]);
        % yticks([-pi/9,0,pi/9]);
        % % yticklabels({'-pi/9',0,'pi/9'});
        % yticklabels({-20,0,20});
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45});
        if iDir == 1
            xlabel('Saccade Direction at Sacc End')
            ylabel('De-Sta-Trend Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        
        hold off
        
        legend([hl{CondIComp(iDir,1)},hl{CondIComp(iDir,2)},hl{CondIComp(iDir,3)},hl{CondIComp(iDir,4)}],...
            {LegText{CondIComp(iDir,1)},LegText{CondIComp(iDir,2)},LegText{CondIComp(iDir,3)},LegText{CondIComp(iDir,4)}},...
            'FontSize',14,'Box','off','AutoUpdate','off')
        title(CondICompName{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end
    
%% 6 Remove the global effect
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Sac_2E_XY_Norm_BootS_Shuff_Marked_Comp_2Shuff';
    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        hold on
        for iCond = CondIComp(iDir,:)
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
            SampYLCI95 = SacEndErrAngBootS(iCond).SampYCI95(1,:);
            SampYUCI95 = SacEndErrAngBootS(iCond).SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;

            % load the Shuff Y and make the comparsion
            ShuffYAveAve = [];
            ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;
            if iDir == 2 && iCond == 1
                % use boundedline to plot which can also skip the nan point
                [hl{iCond},hp] = boundedline(SampXAveAve,-SampYAveAve + ShuffYAveAve,...
                    [-SampYUCI95Ave ; -SampYLCI95Ave]');
                set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2);
                set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
            else
                % use boundedline to plot which can also skip the nan point
                [hl{iCond},hp] = boundedline(SampXAveAve,SampYAveAve - ShuffYAveAve,...
                    [SampYLCI95Ave ; SampYUCI95Ave]');
                set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2);
                set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
            end
        end
        for iCond = CondIComp(iDir,:)
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;

            % load the Shuff Y and make the comparsion
            ShuffYAveAve = [];
            ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;

            % load the comparision
            Samp2Shuff95 = []; Samp2Shuff90 = [];
            Samp2Shuff95 = SacEndErrAngShuff(iCond).Samp2Shuff95;
            Samp2Shuff90 = SacEndErrAngShuff(iCond).Samp2Shuff90;

            % replot to make the line above the patch
            if iDir == 2 && iCond == 1
                plot(SampXAveAve,-SampYAveAve + ShuffYAveAve,'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2)
            else
                plot(SampXAveAve,SampYAveAve - ShuffYAveAve,'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2)
            end
            
            % mark the above part
            MarkC = [205, 45, 48]/255;
            % Find starts and ends of blocks of 95% CI
            starts = find(diff([0, Samp2Shuff95]) == 1);
            ends = find(diff([Samp2Shuff95, 0]) == -1);
            % also include the data between starts and starts-1
            for iChunk = 1:length(starts)
                %plot 95% first
                starts(iChunk) = max(1,starts(iChunk));
                ends(iChunk) = min(length(SampXAveAve),ends(iChunk));
                if iDir == 2 && iCond == 1
                    plot(SampXAveAve(starts(iChunk):ends(iChunk)),-SampYAveAve(starts(iChunk):ends(iChunk))+ShuffYAveAve(starts(iChunk):ends(iChunk)),...
                        '-','Color',colorRGB2(iCond,:),'LineWidth',4);
                else
                    plot(SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk))-ShuffYAveAve(starts(iChunk):ends(iChunk)),...
                        '-','Color',colorRGB2(iCond,:),'LineWidth',4);
                end
            end

            % % Find starts and ends of blocks of 90% CI
            % starts = find(diff([0, Samp2Shuff90]) == 1);
            % ends = find(diff([Samp2Shuff90, 0]) == -1);
            % for iChunk = 1:length(starts)
            %     %plot 90%
            %     plot(SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
            %         ':','Color',colorRGB(iCond,:),'LineWidth',4);
            % end

        end
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45});
        if iDir == 1
            xlabel('Saccade Direction at Sacc End')
            ylabel('De-Sta-Trend Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        
        hold off
        
        legend([hl{CondIComp(iDir,1)},hl{CondIComp(iDir,2)},hl{CondIComp(iDir,3)},hl{CondIComp(iDir,4)}],...
            {LegText{CondIComp(iDir,1)},LegText{CondIComp(iDir,2)},LegText{CondIComp(iDir,3)},LegText{CondIComp(iDir,4)}},...
            'FontSize',14,'Box','off','AutoUpdate','off')
        title(CondICompName{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end




