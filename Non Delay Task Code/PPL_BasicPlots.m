% This script is used to plot all the basic figure
% I will try not to do any statistic analysis in this script (maybe some)
global iniT LegText colorRGB colorRGB1 colorRGB2 rScalar
LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
% LegText = [{'Stationary'},{'CCW 15'},{'CCW 30'},{'CCW 45'},{'CW 15'},{'CW 30'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';
CondI = [0,1,3,5,2,4,6]; % CCW % CW
% CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
CondIComp1 = [0,1,3,5; 0,2,4,6]; % When I want to compare with stationary
iCondIAll = [1,2,3,4;1,5,6,7];
CondIComp1Name = {'CCW','CW'};
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
%% plot the main sequence

SaveName = [];
SaveName = {'/MainSeq_CCW','/MainSeq_CW'};

TitleName = [];
TitleName = 'Saccade Main Sequenc ';

s1 = []; s2 = []; s3 = [];
xmax = max(sbd.SacAmpGoc1);

for iDir = 1:2 % two Direction
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1084,-97,560,976]);

    iCondIi = 0;
    for iCond = CondIComp1(iDir,:)
        iCondIi = iCondIi+1;
        iCondI = iCondIAll(iDir,iCondIi);
        datas1 = []; % datas on Dataf1, all good trials
        datas2 = []; % datas on Dataf1, usually droped trials
        AngIndices = [];

        % find all success trials
        datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        % find all droped trials
        datas2 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == -1);

        % plot datas2
        [s1{iCondIi},s2{iCondIi},s3{iCondIi}] = SacMainSeq(sbd.SacAmpGoc1(datas1),sbd.SacPvelGoc1(datas1),...
            sbd.SacDurGoc1(datas1),sbd.SacRTGoc1(datas1),xmax,colorRGB(iCondI,:),'o',18);

        SacMainSeq(sbd.SacAmpGoc1(datas2),sbd.SacPvelGoc1(datas2),...
            sbd.SacDurGoc1(datas2),sbd.SacRTGoc1(datas2),xmax,colorRGB1(iCondI,:),'o',24);

    end

    % subplot(1,3,1)
    legend([s1{1},s1{2},s1{3},s1{4}],{'Stationary','15 deg/s','30 deg/s','45 deg/s'},...
        "Box","off",'Location','northwest')
    sgtitle([TitleName, CondIComp1Name{iDir}],'FontWeight','normal')
    saveas(gcf,[ResultDir,SaveName{iDir},CondName,'Subj_',userID,'.fig'])
end



%% Raw Eye Traces
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1261 651]);
tiledlayout(2,4,"TileSpacing","compact");

SaveName = [];
SaveName = 'RawEyeTra';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    % find all success trials
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    % find all droped trials
    datas2 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == -1);

    % plot success trial first
    for iTrial = datas1
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        if isempty(sbd.SacTraGoc1{iTrial})
            continue
        elseif max(sbd.SacTraGoc1{iTrial}(4,:))>20 % probably blink
            continue
        end
        EyeLoc = sbd.SacTraGoc1{iTrial};
        p1 = [];
        s1 = [];
        % TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        % TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
        % Polar Plot
        p1 = polarplot(EyeLoc(3,:),EyeLoc(4,:),'LineWidth',0.6,'Color',colorRGB(iCondI,:));
        TarLocTemp(1) = Dataf1(iTrial).SacTarGoc1(end,3);
        TarLocTemp(2) = Dataf1(iTrial).SacTarGoc1(end,4);
        hold on
        s1 = polarscatter(TarLocTemp(1),TarLocTemp(2),5,'black','filled');
    end

    % plot not success saccade traces next
    for iTrial = datas2
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        if isempty(sbd.SacTraGoc1{iTrial})
            continue
        elseif max(sbd.SacTraGoc1{iTrial}(4,:))>20 % probably blink
            continue
        end
        EyeLoc = sbd.SacTraGoc1{iTrial};
        p1 = [];
        s1 = [];
        % TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        % TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
        % Polar Plot
        p1 = polarplot(EyeLoc(3,:),EyeLoc(4,:),'LineWidth',1,'Color','black','LineStyle','--');
        TarLocTemp(1) = Dataf1(iTrial).SacTarGoc1(end,3);
        TarLocTemp(2) = Dataf1(iTrial).SacTarGoc1(end,4);
        hold on
        s1 = polarscatter(TarLocTemp(1),TarLocTemp(2),15,'black','Marker','x','LineWidth',2);
    end

    % polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    % legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])


%% Saccade ending kernel at saccade end (real ending location
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);
iFig = 1;

SaveName = [];
SaveName = '/SacEndKDE';

TiteName = [];
TiteName = 'SacKDE kernel: 0.1 rad, step: 1 deg';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = [];
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    EyeEndTta = zeros(size(datas1));
    iTriali = 0;
    for iTrial = datas1
        iTriali = iTriali+1;
        % EyeLocPol = [];
        % EyeLocPol = sbd.EyeLocMovPol{iTrial};
        EyeEndTta(iTriali) = wrapTo2Pi(mean(sbd.SacTraGoc1{iTrial}(3,end-4:end))); % last 5 ms
    end
    vfPDFSamples = linspace(0, 2*pi, 360);
    fSigma = 0.1;
    [vfEstimate] = circ_ksdensity(EyeEndTta, vfPDFSamples, [0, 2*pi], fSigma);
    p1 = polarplot(vfPDFSamples,vfEstimate,'LineWidth',1,'Color',colorRGB(iCondI,:));
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 0.5])
end
sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])

%% Saccade ending kernel at saccade start
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);
iFig = 1;

SaveName = [];
SaveName = '/SacIniDirKDE';

TiteName = [];
TiteName = 'SacIniKDE kernel: 0.1 rad, step: 1 deg';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = [];
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    EyeEndTta = zeros(size(datas1));
    iTriali = 0;
    for iTrial = datas1
        iTriali = iTriali+1;
        % EyeLocPol = [];
        % EyeLocPol = sbd.EyeLocMovPol{iTrial};
        EyeEndTta(iTriali) = wrapTo2Pi(sbd.SacIniDir(iTrial)); % last 5 ms
    end
    vfPDFSamples = linspace(0, 2*pi, 360);
    fSigma = 0.1;
    [vfEstimate] = circ_ksdensity(EyeEndTta, vfPDFSamples, [0, 2*pi], fSigma);
    p1 = polarplot(vfPDFSamples,vfEstimate,'LineWidth',1,'Color',colorRGB(iCondI,:));
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 0.5])
end
sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])

%% Saccade ending kernel at saccade overall
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);
iFig = 1;

SaveName = [];
SaveName = '/SacAllDirKDE';

TiteName = [];
TiteName = 'SacIniKDE kernel: 0.1 rad, step: 1 deg';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = [];
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    EyeEndTta = zeros(size(datas1));
    iTriali = 0;
    for iTrial = datas1
        iTriali = iTriali+1;
        % EyeLocPol = [];
        % EyeLocPol = sbd.EyeLocMovPol{iTrial};
        EyeEndTta(iTriali) = wrapTo2Pi(sbd.SacAllDir(iTrial)); % last 5 ms
    end
    vfPDFSamples = linspace(0, 2*pi, 360);
    fSigma = 0.1;
    [vfEstimate] = circ_ksdensity(EyeEndTta, vfPDFSamples, [0, 2*pi], fSigma);
    p1 = polarplot(vfPDFSamples,vfEstimate,'LineWidth',1,'Color',colorRGB(iCondI,:));
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 0.5])
end
sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])

%% Plot target location

% need to adjust this code

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/TarDistOnst';

tiledlayout(2,4,"TileSpacing","compact");
for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = []; % for all trials
    datas2 = [];% for droped trials

    % find all trials
    datas = find([Dataf1.TarDir] == iCond);
    % find all droped trials
    datas2 = find([Dataf1.TarDir] == iCond & ~isnan([Dataf1.TimeGocOn]));

    TarLocGoCX = [];
    TarLocGocY = [];
    TarLocGocT = [];
    TarLocGocR = [];
    GoCueFrame = [];
    iTriali = 0;
    for iTrial = datas
        GoCueFrame = 0;
        iTriali = iTriali + 1;
        % Goc onset at the beginning of state 4 which is the OffFrames+1
        GoCueFrame = FP.OffFrames(iTrial)+1;
        TarLocGoCX(iTriali) = (double(Sti.PathXs{iTrial}(GoCueFrame))- Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1);
        TarLocGocY(iTriali) = (double(Sti.PathYs{iTrial}(GoCueFrame))- Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2);
        [TarLocGocT(iTriali),TarLocGocR(iTriali)] = cart2pol(TarLocGoCX(iTriali),TarLocGocY(iTriali));

    end
    polarhistogram(TarLocGocT,8,'FaceColor',colorRGB(iCondI,:))
    hold on

    TarLocTemp = [];
    iTriali = 0;
    for iTrial = datas2
        iTriali = iTriali + 1;
        [TarLocTemp(iTriali,1),TarLocTemp(iTriali,2)] = ...
            cart2pol(Dataf1(iTrial).SacTarGoc1(1,1),Dataf1(iTrial).SacTarGoc1(1,2));
    end
    polarhistogram(TarLocTemp(:,1),8,'FaceColor',colorRGB1(iCondI,:),'FaceAlpha',0.2,'EdgeAlpha',0.2)
    hold off

    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 20])
end
sgtitle(['Target Location at gocue, Distribution, Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_', userID,'.fig'])

%% Reaction time scatterhis delay

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/RTasDelay';

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

hp = [];
hs = [];

for iCond = CondI
    iCondI = iCondI+1;
    datas1 = []; % for all trials
    datas2 = [];% for droped trials

    % find all success trials
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    % find all droped trials
    datas2 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == -1);

    RTSel1 = [];
    DelaySel1 = [];
    RTSel2 = [];
    DelaySel2 = [];

    RTSel1 = sbd.SacRTGoc1(datas1);
    DelaySel1 = [Dataf1(datas1).DurDelay];
    RTSel2 = sbd.SacRTGoc1(datas2);
    DelaySel2 = [Dataf1(datas2).DurDelay];

    RTmin = 0; RTmax = 500;
    Delmin = 0; Delmax = 1200;

    hp{iCondI} = uipanel('Position', panelPositions(iCondI,:));

    hs{iCondI} = scatterhist(DelaySel1,RTSel1,'Parent',hp{iCondI},'Kernel','overlay',...
        'NBins',[10,12],'Color',colorRGB(iCondI,:),'Marker','.','MarkerSize',12);
    hold on
    scatter(hs{iCondI}(1),DelaySel2,RTSel2,20,colorRGB(iCondI,:),'x','LineWidth',2)
    hold off
    xlim(hs{iCondI}(1),[Delmin,Delmax]);
    ylim(hs{iCondI}(1),[RTmin,RTmax]);
    title(hs{iCondI}(1),LegText{iCond+1},'FontWeight','normal')
    % scatterhist(DelaySel,RTSel,'Parent',hp{iCondI},'Group',datasG,'NBins',[10,10])
end
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])


%% RT as polar plot with saccade end

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/RT_SacEnd_Polar';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = []; % for all trials
    datas2 = [];% for droped trials

    s1 = [];

    % find all success trials
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    % find all droped trials
    datas2 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == -1);

    RTSel1 = [];
    SacEndAng1 = [];

    RTSel1 = sbd.SacRTGoc1(datas1);
    SacEndAng1 = sbd.SacAllDir(datas1);

    s1 = polarscatter(SacEndAng1,RTSel1,10,'filled','o','MarkerFaceColor',colorRGB(iCondI,:),'MarkerEdgeColor','none');

    RTSel2 = [];
    SacEndAng2 = [];

    RTSel2 = sbd.SacRTGoc1(datas2);
    SacEndAng2 = sbd.SacAllDir(datas2);

    hold on
    s2 = polarscatter(SacEndAng2,RTSel2,20,'k','Marker','x','LineWidth',2);
    hold off

    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 450])
end
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])

%% RT as Cartesian plot with saccade end

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/RT_SacEnd_Carts';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = []; % for all trials
    datas2 = [];% for droped trials

    s1 = [];

    % find all success trials
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    % find all droped trials
    datas2 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == -1);

    RTSel1 = [];
    SacEndAng1 = [];
    
    RTSel1 = sbd.SacRTGoc1(datas1);
    SacEndAng1 = sbd.SacAllDir(datas1);

    s1 = scatter(SacEndAng1,RTSel1,10,'filled','o','MarkerFaceColor',colorRGB(iCondI,:),'MarkerEdgeColor','none');

    RTSel2 = [];
    SacEndAng2 = [];

    RTSel2 = sbd.SacRTGoc1(datas2);
    SacEndAng2 = sbd.SacAllDir(datas2);

    hold on
    s2 = scatter(SacEndAng2,RTSel2,20,'k','Marker','x','LineWidth',2);
    hold off

    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    ylim([0, 450])
end
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])

%% RT as Cartesian plot with saccade initial

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/RT_SacIni_Carts';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = []; % for all trials
    datas2 = [];% for droped trials

    s1 = [];

    % find all success trials
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    % find all droped trials
    datas2 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == -1);

    RTSel1 = [];
    SacEndAng1 = [];
    
    RTSel1 = sbd.SacRTGoc1(datas1);
    SacEndAng1 = sbd.SacIniDir(datas1);

    s1 = scatter(SacEndAng1,RTSel1,10,'filled','o','MarkerFaceColor',colorRGB(iCondI,:),'MarkerEdgeColor','none');

    RTSel2 = [];
    SacEndAng2 = [];

    RTSel2 = sbd.SacRTGoc1(datas2);
    SacEndAng2 = sbd.SacIniDir(datas2);

    hold on
    s2 = scatter(SacEndAng2,RTSel2,20,'k','Marker','x','LineWidth',2);
    hold off

    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    ylim([0, 450])
end
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])

%% RT as Cartesian plot with curvature

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/RT_SacCur';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = []; % for all trials
    datas2 = [];% for droped trials

    s1 = [];

    % find all success trials
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    % find all droped trials
    datas2 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == -1);

    RTSel1 = [];
    SacCur1 = [];

    RTSel1 = sbd.SacRTGoc1(datas1);
    SacCur1 = sbd.SacCurPara1(datas1);

    s1 = scatter(SacCur1,RTSel1,10,'filled','o','MarkerFaceColor',colorRGB(iCondI,:),'MarkerEdgeColor','none');

    RTSel2 = [];
    SacCur2 = [];

    RTSel2 = sbd.SacRTGoc1(datas2);
    SacCur2 = sbd.SacCurPara1(datas2);

    hold on
    s2 = scatter(SacCur2,RTSel2,20,'k','Marker','x','LineWidth',2);
    hold off

    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    ylim([0, 450])
    xlim([-0.7,0.7])
end
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])


%% plot the saccade curvature distribution
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);
iFig = 1;

SaveName = [];
SaveName = '/SacCurDist';

TiteName = [];
TiteName = 'SacCurDist';

% signedLog = @(x) sign(x) .* abs(log(abs(x)));
% CurTransf = signedLog(sbd.SacCurPara1);

% transfer to [0,1]
CurNorm1 = abs(sbd.SacCurPara1)/max(abs(sbd.SacCurPara1));
CurTransf = abs(log(CurNorm1));
MaxCurTf = max(CurTransf);

% MaxCur = max(abs(sbd.SacCurPara1));

% Define the angular range of the window (in radians)
winRange = pi/6;  % 30 degrees (pi/6 radians)
% Define the step size for sliding the window (in radians)
stepSize = pi/18;  % 10 degrees (pi/18 radians)

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = []; datas2 = [];
    datas1 = find([Dataf1.TarDir] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    % find all droped trials
    datas2 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == -1);
    iTriali = 0;
    CurNorm2 = [];
    EyeEndTta = [];
    for iTrial = datas1
        if isempty(sbd.SacTraGoc1{iTrial})
            continue
        end
        iTriali = iTriali+1;
        % SacCur(iTriali) = 1-abs(sbd.SacCurPara1(iTrial))/MaxCur(1);
        CurNorm2(iTriali) = CurTransf(iTrial)/MaxCurTf(1);
        EyeEndTta(iTriali) = wrapTo2Pi(mean(sbd.SacTraGoc1{iTrial}(3,end-4:end)));
    end
    p1 = [];
    p1 = polarscatter(EyeEndTta,CurNorm2,30,'Marker','o','MarkerFaceColor',colorRGB(iCondI,:),'MarkerEdgeColor','none');
    hold on

    iTriali = 0;
    CurNorm2 = zeros(size(datas2));
    EyeEndTta = zeros(size(datas2));
    for iTrial = datas2
        if isempty(sbd.SacTraGoc1{iTrial})
            continue
        end
        iTriali = iTriali+1;
        % SacCur(iTriali) = 1-abs(sbd.SacCurPara1(iTrial))/MaxCur(1);
        CurNorm2(iTriali) = CurTransf(iTrial)/MaxCurTf(1);
        EyeEndTta(iTriali) = wrapTo2Pi(mean(sbd.SacTraGoc1{iTrial}(3,end-4:end)));
    end
    p2 = [];
    p2 = polarscatter(EyeEndTta,CurNorm2,20,'k','Marker','x','LineWidth',2);

    rlim([0,0.65])
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    hold off
end
sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
iFigAcc = iFigAcc+iFig;




