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

%% 1 plot the eye traces 2E
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RawEyeTrc2E_TarSacEnd';
    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        for iTrial = datas1
            if isempty(sbd.SacTraGoc2E1{iTrial})
                continue
            elseif max(sbd.SacTraGoc2E1{iTrial}(4,:))>20 % probably blink
                continue
            end
            EyeLoc = sbd.SacTraGoc2E1{iTrial};
            p1 = [];
            s1 = [];
            % TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
            % TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
            % Polar Plot
            p1 = polarplot(EyeLoc(3,:),EyeLoc(4,:),'LineWidth',0.6,'Color',colorRGB(iCond,:));
            TarLocTemp(1) = sbd.TarEnd2E(3,iTrial);
            TarLocTemp(2) = sbd.TarEnd2E(4,iTrial);
            hold on
            s1 = polarscatter(TarLocTemp(1),TarLocTemp(2),5,'black','filled');
        end
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% 2 sliding window on cartesian
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacTMrkErr_Tar_2E_XY_DeTrend';

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0, 2*pi];
        hold on
        for iTime = 2:8
            XV = []; YV = []; XAve = []; YAve = []; YStd = [];
            XV = mod(wrapTo2Pi(sbd.SacEndErrAng2ESign2Normed_TarTMrk{iTime,iCond}(1,:))-pi/2,pi*2);
            YV = sbd.SacEndErrAng2ESign2Normed_TarTMrk{iTime,iCond}(2,:);

            % I need to plot on the xy coordinates
            F_CartScat(XV, YV, iCond, [-pi/18,2*pi+pi/18], [-pi/4,pi/3]);
            
            % plot the sliding window
            [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV',winRange);

            % use boundedline to plot which can also skip the nan point
            
            [hl,hp] = boundedline(XAve,YAve,YStd);
            set(hl,'color','k','LineStyle','-','LineWidth',1.5);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
        end

        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4,pi/3]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45,60});
        if iCond == 1
            xlabel('Target Direction at 0:20:100ms Sacc On, Sac Off')
            ylabel('De-Sta Trend Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle','--');
        xline(pi,'LineWidth',1.5,'LineStyle','--');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle','--');
        hold off

        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 3 do a bootstrap
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacTMrkErr_Tar_2E_XY_DeTrend_BootS';

    Fig7Ax = gobjects(4,2);
    SacTMrkErrAngBootS = [];
    for iCond = CondI
        Fig7Ax(iCond) = nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            Fig7Ax(iCond) = nexttile; % This creates the (2,1) tile
        end
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        
        % plot the bootstrap sliding window
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0,2*pi];
        
        hold on
        for iTime = 2:8
            XV = []; YV = []; SacEndErrAngBootS = [];
            XV = mod(wrapTo2Pi(sbd.SacEndErrAng2ESign2Normed_TarTMrk{iTime,iCond}(1,:))-pi/2,pi*2);
            YV = sbd.SacEndErrAng2ESign2Normed_TarTMrk{iTime,iCond}(2,:);
            % I need to plot on the xy coordinates
            F_CartScat(XV, YV, iCond, [-pi/18,2*pi+pi/18], [-pi/4,pi/3]);
            % and do the bootStrapping
            SampS = floor(length(XV)*1);
            SacEndErrAngBootS = F_BootSCartSlidWin2(XV',YV',SampS,1000,winSize,stepSize,winRange);

            % assign data
            SampXAveAve = []; SampYAveAve = []; SampYLCI95Ave = []; SampYUCI95Ave = [];
            SampXAveAve = SacEndErrAngBootS.SampXAveAve; SampYAveAve = SacEndErrAngBootS.SampYAveAve;
            SampYLCI95Ave = SacEndErrAngBootS.SampYLCI95Ave; SampYUCI95Ave = SacEndErrAngBootS.SampYUCI95Ave;

            % use boundedline to plot which can also skip the nan point
            [hl,hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
            set(hl,'color','k','LineStyle','-','LineWidth',1.5);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

            SacTMrkErrAngBootS{iTime-1,iCond} = SacEndErrAngBootS;
        end

        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4,pi/3]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45,60});
        if iCond == 1
            xlabel('Target Direction at 0:20:100ms Sacc On, Sac Off')
            ylabel('Normed Sacc-End Direction Difference')
            legend(hl,'Moving ave after 1000 bootstrap','FontSize',14,'Box','off','AutoUpdate','off')
            hl1 = hl;
        end
        xline([pi/2,pi,3*pi/2],'LineWidth',1.5,'LineStyle',':');
        hold off

        set(gca,'FontSize',14)
        title(LegText{iCond},'FontWeight','normal')
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% 4 based on the plot above, I'm going to add shuffling result
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    figure(iFigAcc)
    SaveName = [];
    SaveName = '/SacTMrkErr_Tar_2E_XY_DeTrend_BootS_Shuff';
    SacTMrkErrAngShuff = [];
    for iCond = CondI
        % do the shuffling:
        winSize = pi/4;
        stepSize = winSize/10;
        % winRange = [-winSize+stepSize, 2*pi-stepSize];
        winRange = [0, 2*pi];
        hold on
        for iTime = 2:8
            XV = []; YV = []; SacEndErrAngShuff = [];
            XV = mod(wrapTo2Pi(sbd.SacEndErrAng2ESign2Normed_TarTMrk{iTime,iCond}(1,:))-pi/2,pi*2);
            YV = sbd.SacEndErrAng2ESign2Normed_TarTMrk{iTime,iCond}(2,:);
            SacEndErrAngShuff = F_ShuffTest1(XV',YV',1000,winSize,stepSize,winRange);
            
            ShuffXAveAve = []; ShuffYAveAve = []; ShuffYLCI95Ave = []; ShuffYUCI95Ave = [];
            ShuffXAveAve = SacEndErrAngShuff.ShuffXAveAve; ShuffYAveAve = SacEndErrAngShuff.ShuffYAveAve;
            ShuffYLCI95Ave = SacEndErrAngShuff.ShuffYLCI95Ave; ShuffYUCI95Ave = SacEndErrAngShuff.ShuffYUCI95Ave;
            % use boundedline to plot which can also skip the nan point
            [hl,hp] = boundedline(ShuffXAveAve,ShuffYAveAve,[ShuffYLCI95Ave;ShuffYUCI95Ave]',Fig7Ax(iCond));
            set(hl,'color','k','LineStyle','--','LineWidth',1.5);
            set(hp,'FaceColor',[209 209 209]./255,'FaceAlpha',0.3,'EdgeColor','none')

            SacTMrkErrAngShuff{iTime-1,iCond} = SacEndErrAngShuff;
        end
        hold off
        if iCond == 1
            legend([hl1,hl],{'Moving ave after 1000 bootstrap','Moving ave after 1000 shuffling'},'FontSize',14,'AutoUpdate','off')
        end
    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 5 based on the figure 7, I'm going to label the part above the threshold
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    figure(iFigAcc)
    SaveName = [];
    SaveName = '/SacTMrkErr_Tar_2E_XY_DeTrend_BootS_Shuff_Marked';
    for iCond = CondI
        % load the bootstrap result
        for iTime = 2:8
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = SacTMrkErrAngBootS{iTime-1,iCond}.SampXAveAve;
            SampYAveAve = SacTMrkErrAngBootS{iTime-1,iCond}.SampYAveAve;

            % load the shuffling result
            ShuffXAveAve = []; ShuffYAveAve = []; ShuffYLCI95 = []; ShuffYUCI95 = []; ShuffYLCI90 = []; ShuffYUCI90 = [];
            ShuffXAveAve = SacTMrkErrAngShuff{iTime-1,iCond}.ShuffXAveAve;
            ShuffYAveAve = SacTMrkErrAngShuff{iTime-1,iCond}.ShuffYAveAve;
            ShuffYLCI95 = SacTMrkErrAngShuff{iTime-1,iCond}.ShuffYCI95(1,:);
            ShuffYUCI95 = SacTMrkErrAngShuff{iTime-1,iCond}.ShuffYCI95(2,:);

            % test with 95% and 90%
            % I'm going to write a logic vector
            Samp2Shuff95 = SampYAveAve >= ShuffYUCI95 | SampYAveAve <= ShuffYLCI95;

            SacTMrkErrAngShuff{iTime-1,iCond}.Samp2Shuff95 = Samp2Shuff95;

            % plot in a thicker red line chuncks
            MarkC = [205, 45, 48]/255;
            % Find starts and ends of blocks of 95% CI
            starts = find(diff([0, Samp2Shuff95]) == 1);
            ends = find(diff([Samp2Shuff95, 0]) == -1);
            % also include the data between starts and starts-1
            for iChunk = 1:length(starts)
                %plot 95% first
                starts(iChunk) = max(1,starts(iChunk));
                ends(iChunk) = min(length(SampXAveAve),ends(iChunk));
                hold (Fig7Ax(iCond),'on')
                plot(Fig7Ax(iCond),SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
                    '-','Color',MarkC,'LineWidth',3);
                hold off
            end
        end
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


