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
% Adjusted on Jun 09, Ending error distribution
% Adjusted on Jul 02, Ending error and pursuit velocity
% Adjusted on Jul 08, Generating plots that needed for manuscript
% IMPORTANT UPDATE::: Add the trial type and trial status in sbd
%% Txt information
global colorRGB colorRGB1 colorRGB2 rScalar
LegText = [{'Stationary'},{'CCW 15°/s'},{'CCW 30°/s'},{'CCW 45°/s'},{'CW 15°/s'},{'CW 30°/s'},{'CW 45°/s'}];
LegTextCombine = [{'Stationary'},{'15°/s'},{'30°/s'},{'45°/s'}];
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
    % sample color
    spCol = [122, 33, 201]/ 255;

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
    
    % save the TarDir1 and Trial Status
    sbd.TarDir = [Dataf1.TarDir1];
    sbd.TrialStatus = [Dataf1.TrialStatus];
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

%% 1. plot the combination of CW and CCW, Bootstrap of sliding window, zero means
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = '/SacEndErr_Targ_2E_Comb_XY_DeSta_0mean_BootS'; % combine CW and CCW

    winSize = pi/4;
    stepSize = winSize/15;
    winRange = [0,2*pi];

    Fig4Ax = gobjects(4,1);
    if exist('SacEndErrAngBootS','var') 
        clearvars SacEndErrAngBootS; end

    ReTime = 1000;

    for iCond = CondIComp(1,:)
        Fig4Ax(iCond) = nexttile;
        hold on
        
        datas1 = find(([Dataf1.TarDir1] == iCond | [Dataf1.TarDir1] == CondIComp(2,iCond)) ...
            & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        XV = sbd.TarEnd2EAngWrapflip(datas1);
        YV = sbd.SacEndErrAng2ESignDeStaCen2(datas1);

        % I need to plot on the xy coordinates
        scatter(XV,YV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');

        % plot the bootstrap sliding window
        SampS = length(XV);
        SacEndErrAngBootS(iCond) = F_BootSCartSlidWin2(XV',YV',SampS,ReTime,winSize,stepSize,winRange);
        
        % assign data
        SampXAveAve = []; SampYAveAve = []; SampYLCI95Ave = []; SampYUCI95Ave = [];
        SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve; SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
        SampYLCI95Ave = SacEndErrAngBootS(iCond).SampYLCI95Ave; SampYUCI95Ave = SacEndErrAngBootS(iCond).SampYUCI95Ave;
        [SampXAveAve, I] = sort(SampXAveAve);
        SampYAveAve = SampYAveAve(I);
        SampYLCI95Ave = SampYLCI95Ave(I);
        SampYUCI95Ave = SampYUCI95Ave(I);

        % use boundedline to plot which can also skip the nan point
        [hl1,hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
        set(hl1,'color','k','LineStyle','-','LineWidth',1.5);
        set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
        
        xline(pi/2,'LineWidth',1.5,'LineStyle','--');
        xline(pi,'LineWidth',1.5,'LineStyle','--');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle','--');

        xticks(deg2rad([0,90,180,270,360]))
        xticklabels([90,180,270,0,90])
        xlim(deg2rad([-5,365]))
        ylim(deg2rad([-50,80]))
        yticks(deg2rad(-50:25:50))
        yticklabels(-50:25:50)

        if iCond == 1
            xlabel('Targ Direction at Sacc End')
            ylabel('De-Sta-Trend Sacc-Targ End Direction Difference')
        end
        
        hold off
        set(gca,'FontSize',15)
        title(LegText{iCond},'FontWeight','normal')
    end
    sbd.SacEndErrAngBootS_DeSta_Comb_Cen = SacEndErrAngBootS;
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 add shuffle and significant bar
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    figure(iFigAcc)
    SaveName = [];
    SaveName = '/SacEndErr_Targ_2E_Comb_XY_DeSta_0mean_BootS_Shuff2_SigBar';

    % do the shuffling:
    winSize = pi/4;
    stepSize = winSize/15;
    winRange = [0, 2*pi];
    if exist('SacEndErrAngShuff','var') 
        clearvars SacEndErrAngShuff; end

    pVals = [];
    pVals = cell(1,4);
    for iCond = CondIComp(1,1:end)
        datas1 = find(([Dataf1.TarDir1] == iCond | [Dataf1.TarDir1] == CondIComp(2,iCond)) ...
            & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        XV = sbd.TarEnd2EAngWrapflip(datas1);
        YV = sbd.SacEndErrAng2ESignDeStaCen2(datas1);
        SacEndErrAngShuff(iCond) = F_ShuffTest1(XV',YV',ReTime,winSize,stepSize,winRange);
        ShuffXAveAve = []; ShuffYAveAve = []; ShuffYLCI95Ave = []; ShuffYUCI95Ave = [];
        ShuffXAveAve = SacEndErrAngShuff(iCond).ShuffXAveAve; ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;
        ShuffYLCI95Ave = SacEndErrAngShuff(iCond).ShuffYLCI95Ave; ShuffYUCI95Ave = SacEndErrAngShuff(iCond).ShuffYUCI95Ave;
        [ShuffXAveAve, I] = sort(ShuffXAveAve);
        ShuffYAveAve = ShuffYAveAve(I);
        ShuffYLCI95Ave = ShuffYLCI95Ave(I);
        ShuffYUCI95Ave = ShuffYUCI95Ave(I);

        hold(Fig4Ax(iCond), 'on')
        [hl,hp] = boundedline(ShuffXAveAve,ShuffYAveAve,[ShuffYLCI95Ave;ShuffYUCI95Ave]',Fig4Ax(iCond));
        set(hl,'color','k','LineStyle','--','LineWidth',1.5);
        set(hp,'FaceColor',[209 209 209]./255,'FaceAlpha',0.6,'EdgeColor','none')

        % p value %% also need to sort P!
        pVals{iCond} = F_BootSStat_V1ToNull_pV2(XV, YV, ReTime, winSize,stepSize,winRange);
        pVals{iCond} = pVals{iCond}(I);
        F_CartPlotSigBar(ShuffXAveAve, pVals{iCond}, 0.05, deg2rad(60),Fig4Ax(iCond));
        hold (Fig4Ax(iCond),'off')

        if iCond == 1
            legend(Fig4Ax(iCond),[hl1,hl],{'Moving ave after 1000 bootstrap','Moving ave after 1000 shuffling'},...
                'FontSize',15,'AutoUpdate','off','edgecolor','none')
        end
    end
    sbd.SacEndErrAngShuff_DeSta_Comb_Cen = SacEndErrAngShuff;
    sbd.StatR_pVals_ErrDeSta_Comb_Cen = pVals;
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end



