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
% Adjusted on Nov 19, Start Curvature Analysis This version for Ashka
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

%% 1 plot the eye traces 2E with the link between
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
TarEndLoc = [];
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/RawEyeTrc2E_TarSacEnd_Linked';
    iCondi = 0;
    for iCond = [1,4,7]
        iCondi = iCondi+1;
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
            subplot(1,3,iCondi)
            p1 = polarplot(EyeLoc(3,:),EyeLoc(4,:),'LineWidth',1,'Color',colorRGB(iCond,:));
            TarEndLoc(1) = sbd.TarEnd2E(3,iTrial);
            TarEndLoc(2) = sbd.TarEnd2E(4,iTrial);
            hold on
            s1 = polarscatter(TarEndLoc(1),TarEndLoc(2),10,'black','filled');
        end
        rlim([0,12])
        title(LegText{iCond},'FontWeight','normal');
        pax = []; pax = gca;
        set(pax,'FontSize',15)
    end
% end

%% 2 Use the Initial Direction to plot the curvature as a function of target location
% Use overall direction - initial direction (initial direction at 10ms)
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1792,452,1486,304]);
SaveName = [];
SaveName = '/SacEndErr_Tar_2E_XY_NoNorm';
iCondi = 0;
for iCond = [1,4,7]
    iCondi = iCondi+1;
    datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    EyeDirDiff = []; TarEndLoc = []; EyeLocEndAll = [];
    iTriali = 0;
    for iTrial = datas1
        iTriali = iTriali+1;
        EyeLocIni = [];
        EyeLocEnd = [];
        if isempty(sbd.SacTraGoc2E1{iTrial})
            continue
        elseif max(sbd.SacTraGoc2E1{iTrial}(4,:))>20 % probably blink
            continue
        end
        EyeLoc = sbd.SacTraGoc2E1{iTrial};
        EyeLocIni = wrapToPi(EyeLoc(3,10)); % direction at 10 ms
        EyeLocEnd = wrapToPi(EyeLoc(3,end)); % direction at the end
        EyeDirDiff(iTriali) = rad2deg(wrapToPi(EyeLocEnd - EyeLocIni));
        TarEndLoc(iTriali) = rad2deg(wrapTo2Pi(sbd.TarEnd2E(3,iTrial))); % target direction at saccade end
        EyeLocEndAll(iTriali) = rad2deg(wrapTo2Pi(EyeLocEnd)); % Saccade direction at saccade end
    end
    subplot(1,3,iCondi)
    p1 = [];
    p1 = scatter(TarEndLoc,EyeDirDiff,40,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
    xlim([0,360]);
    xticks([0,90,180,270,360]);
    ylim([-60,60]);
    title(LegText{iCond},'FontWeight','normal');
    if iCond == 1
        ylabel('Dir Diff End-Ini, deg')
    end
    if iCond == 4
        xlabel('Targ Dir at Sacc End, deg')
    end
    pax = []; pax = gca;
    set(pax,'FontSize',15)
end
% 
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 3 Use the Initial Direction to plot the curvature as a function of saccade location
% Use overall direction - initial direction (initial direction at 10ms)
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1792,452,1486,304]);
SaveName = [];
SaveName = '/SacEndErr_Tar_2E_XY_NoNorm';
iCondi = 0;
for iCond = [1,4,7]
    iCondi = iCondi+1;
    datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    EyeDirDiff = []; TarEndLoc = []; EyeLocEndAll = [];
    iTriali = 0;
    for iTrial = datas1
        iTriali = iTriali+1;
        EyeLocIni = [];
        EyeLocEnd = [];
        if isempty(sbd.SacTraGoc2E1{iTrial})
            continue
        elseif max(sbd.SacTraGoc2E1{iTrial}(4,:))>20 % probably blink
            continue
        end
        EyeLoc = sbd.SacTraGoc2E1{iTrial};
        EyeLocIni = wrapToPi(EyeLoc(3,10)); % direction at 10 ms
        EyeLocEnd = wrapToPi(EyeLoc(3,end)); % direction at the end
        EyeDirDiff(iTriali) = rad2deg(wrapToPi(EyeLocEnd - EyeLocIni));
        TarEndLoc(iTriali) = rad2deg(wrapTo2Pi(sbd.TarEnd2E(3,iTrial))); % target direction at saccade end
        EyeLocEndAll(iTriali) = rad2deg(wrapTo2Pi(EyeLocEnd)); % Saccade direction at saccade end
    end
    subplot(1,3,iCondi)
    p1 = [];
    p1 = scatter(EyeLocEndAll,EyeDirDiff,40,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
    xlim([0,360]);
    xticks([0,90,180,270,360]);
    ylim([-60,60]);
    title(LegText{iCond},'FontWeight','normal');
    if iCond == 1
        ylabel('Dir Diff End-Ini, deg')
    end
    if iCond == 4
        xlabel('Sacc Dir at Sacc End, deg')
    end
    pax = []; pax = gca;
    set(pax,'FontSize',15)
end
% 
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 4 Use the Initial Direction to plot the curvature as a function of target location, Moving Average
% Use overall direction - initial direction (initial direction at 10ms)
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1792,452,1486,304]);
SaveName = [];
SaveName = '/SacEndErr_Tar_2E_XY_NoNorm';
iCondi = 0;
for iCond = [1,4,7]
    iCondi = iCondi+1;
    datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    EyeDirDiff = []; TarEndLoc = []; EyeLocEndAll = []; XV = []; YV = [];
    iTriali = 0;
    for iTrial = datas1
        iTriali = iTriali+1;
        EyeLocIni = [];
        EyeLocEnd = [];
        if isempty(sbd.SacTraGoc2E1{iTrial})
            continue
        elseif max(sbd.SacTraGoc2E1{iTrial}(4,:))>20 % probably blink
            continue
        end
        EyeLoc = sbd.SacTraGoc2E1{iTrial};
        EyeLocIni = wrapToPi(EyeLoc(3,10)); % direction at 10 ms
        EyeLocEnd = wrapToPi(EyeLoc(3,end)); % direction at the end
        EyeDirDiff(iTriali) = wrapToPi(EyeLocEnd - EyeLocIni);
        TarEndLoc(iTriali) = wrapTo2Pi(sbd.TarEnd2E(3,iTrial)); % target direction at saccade end
        EyeLocEndAll(iTriali) = wrapTo2Pi(EyeLocEnd); % Saccade direction at saccade end
    end
    XV = TarEndLoc;
    YV = EyeDirDiff;
    subplot(1,3,iCondi)
    p1 = []; p2 = [];
    p1 = scatter(XV,YV,40,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
    % moving average
    winSize = pi/4; stepSize = pi/18; winRange = [0,2*pi];
    [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV',winRange);
    hold on
    [hl,hp] = boundedline(XAve,YAve,YStd);
    set(hl,'color','k','LineStyle','-','LineWidth',1.5);
    set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none');
    hold off

    xlim([0,2*pi]);
    xticks([0,pi/2,pi,pi*3/2,2*pi]);
    xticklabels([0,90,180,270,360]);
    ylim([-pi/3,pi/3]);
    yticks([-pi/3,-pi/6,0,pi/6,pi/3]);
    yticklabels([-60,-30,0,30,60]);
    title(LegText{iCond},'FontWeight','normal');
    if iCond == 1
        ylabel('Dir Diff End-Ini, deg')
    end
    if iCond == 4
        xlabel('Targ Dir at Sacc End, deg')
    end
    pax = []; pax = gca;
    set(pax,'FontSize',15)
end
% 
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 5 Use the Initial Direction to plot the curvature as a function of Sacc location, Moving Average
% Use overall direction - initial direction (initial direction at 10ms)
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1792,452,1486,304]);
SaveName = [];
SaveName = '/SacEndErr_Tar_2E_XY_NoNorm';
iCondi = 0;
for iCond = [1,4,7]
    iCondi = iCondi+1;
    datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    EyeDirDiff = []; TarEndLoc = []; EyeLocEndAll = []; XV = []; YV = [];
    iTriali = 0;
    for iTrial = datas1
        iTriali = iTriali+1;
        EyeLocIni = [];
        EyeLocEnd = [];
        if isempty(sbd.SacTraGoc2E1{iTrial})
            continue
        elseif max(sbd.SacTraGoc2E1{iTrial}(4,:))>20 % probably blink
            continue
        end
        EyeLoc = sbd.SacTraGoc2E1{iTrial};
        EyeLocIni = wrapToPi(EyeLoc(3,10)); % direction at 10 ms
        EyeLocEnd = wrapToPi(EyeLoc(3,end)); % direction at the end
        EyeDirDiff(iTriali) = wrapToPi(EyeLocEnd - EyeLocIni);
        TarEndLoc(iTriali) = wrapTo2Pi(sbd.TarEnd2E(3,iTrial)); % target direction at saccade end
        EyeLocEndAll(iTriali) = wrapTo2Pi(EyeLocEnd); % Saccade direction at saccade end
    end
    XV = EyeLocEndAll;
    YV = EyeDirDiff;
    subplot(1,3,iCondi)
    p1 = []; p2 = [];
    p1 = scatter(XV,YV,40,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
    % moving average
    winSize = pi/4; stepSize = pi/18; winRange = [0,2*pi];
    [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV',winRange);
    hold on
    [hl,hp] = boundedline(XAve,YAve,YStd);
    set(hl,'color','k','LineStyle','-','LineWidth',1.5);
    set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none');
    hold off

    xlim([0,2*pi]);
    xticks([0,pi/2,pi,pi*3/2,2*pi]);
    xticklabels([0,90,180,270,360]);
    ylim([-pi/3,pi/3]);
    yticks([-pi/3,-pi/6,0,pi/6,pi/3]);
    yticklabels([-60,-30,0,30,60]);
    title(LegText{iCond},'FontWeight','normal');
    if iCond == 1
        ylabel('Dir Diff End-Ini, deg')
    end
    if iCond == 4
        xlabel('Sacc Dir at Sacc End, deg')
    end
    pax = []; pax = gca;
    set(pax,'FontSize',15)
end
% 
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% Write a dataset for Ashka
iTriali = 0;
EyeLoc = []; TarEndLoc = []; Subj1Data = [];
for iCond = [1,4,7]
    iCondi = iCondi+1;
    datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    for iTrial = datas1
        iTriali = iTriali+1;
        EyeLocIni = [];
        EyeLocEnd = [];
        if isempty(sbd.SacTraGoc2E1{iTrial})
            continue
        elseif max(sbd.SacTraGoc2E1{iTrial}(4,:))>20 % probably blink
            continue
        end
        TrialType(iTriali) = iCond;
        EyeLoc{iTriali} = sbd.SacTraGoc2E1{iTrial};
        TarEndLoc{iTriali} = sbd.TarEnd2E(:,iTrial); % target direction at saccade end
    end
end
Subj1Data = table(TrialType',EyeLoc',TarEndLoc');
