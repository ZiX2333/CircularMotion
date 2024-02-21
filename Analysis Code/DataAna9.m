% Data Processing
% This script is used for data processing
% Analysis based on prepro 4
% adjusted on Oct 12, exclude several figures and add some new figures
% Data Save in Result/ Oct12
% Adjusted on Oct 28, add sinwave fit
% Adjusted on Oct 31, adjust the way of doing averaging
% Adjusted on Nov 5, just realize that I confounded the left and right
% Adjusted on Jan 29, make it useful for single subject

%% Load Data
userID = 'zx07';
userDate = '040923';

%%
% load([userID,'_',userDate,'_','PreProcessed3.mat'])

%% MKDIR and Condition choose

DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/',userID,'/'];
AnaData = 'Feb02';
ResultDir = [DataDir,'ResultFig/',AnaData,'/'];

LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';
CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondName = '_1';

ifDoBasic = 1;

%% basic settings
if ifDoBasic
    mkdir(ResultDir);

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

    % Legend setting
    LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];

    FixW = [-100,900];
    TarW = [-400,600];
    GocW = [-500,500];
    SacW = [-500,500];

    GocC = find(GocW(1):GocW(2) == 0);

    %% PreProcessed of data
    Dataf1 = Dataf;

    % % remove Dataf that TrialStatus ~=1
    % Dataf1([Dataf.TrialStatus]~=1) = [];
    %
    % % remove trials that peak velocity < 50 deg/sec
    % Dataf1([Dataf1.SacPvelGoc1]<50) = [];

    % remove RT < 100ms >400, duration >=100ms, start radius >=4, end radius <=4,
    % amplitude <4
    % peak velocity < 50, have microsaccade 100ms before gocue (after already excluded)
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
        elseif Dataf1(iTrial).SacTimeGoc2(end,1)<80 || Dataf1(iTrial).SacTimeGoc2(end,1)>400
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacTimeGoc2(end-1,1)>=150
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacLocGoc2{1}(3,1) >=4
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacLocGoc2{1}(3,end) <=4
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif abs(Dataf1(iTrial).SacLocGoc2{1}(3,end)-Dataf1(iTrial).SacLocGoc2{1}(3,1)) <=3
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

    iDropDataf1 = unique([iDrop1,iDrop2]);
    % iDropDataf2 = unique([iDrop2,iDrop3]);

    Dataf1(iDropDataf1) = [];

    for iDrop = 1:length(iDrop2)
        Dataf(iDrop2(iDrop)).TrialStatus = -1; % doesn't apply criteria
    end

    %% behavior analysis
    iniT = 10; % select first 10ms for the first saccade
    [sbd,Dataf1,iDrop4] = BehaviorAna(Dataf1,iniT);

    % drop relevent data
    Dataf1(iDrop4) = [];

    sbdfieldNames = fieldnames(sbd);
    % Loop through each field and delete the element
    for iField = 1:length(sbdfieldNames)
        field = sbdfieldNames{iField};
        sbd.(field)(iDrop4) = [];
    end
end

iFigAcc = 0;

Xlim1 = -3*pi/2;
Xlim2 = pi/2;

windSize = pi/9; % 20 deg
increm = pi/18; % 10 deg
XGroup1 = -3*pi/2:increm:(-pi/2-windSize);
XGroup2 = (-3*pi/2+windSize):increm:-pi/2;
XGroup3 = -pi/2:increm:(pi/2-windSize);
XGroup4 = (-pi/2+windSize):increm:pi/2;

%% Raw Eye Traces
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1261 651]);
tiledlayout(2,4,"TileSpacing","compact");
for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = find([Dataf1.TarDir] == iCond);
    for iTrial = datas
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLoc = sbd.SacTraGoc1{iTrial};
        p1 = [];
        s1 = [];
        % TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        % TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
        % Polar Plot
        p1 = polarplot(EyeLoc(4,:),EyeLoc(3,:),'LineWidth',0.6,'Color',colorRGB(iCondI,:));
        [TarLocTemp(1),TarLocTemp(2)] = cart2pol(Dataf1(iTrial).SacTarGoc1(end,1),Dataf1(iTrial).SacTarGoc1(end,2));
        s1 = polarscatter(TarLocTemp(1),TarLocTemp(2),5,'black','filled');
        hold on
    end
    % polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    % legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
% sgtitle('Saccade Traces in with Target Location at Saccade off','FontSize',15)
saveas(gcf,[ResultDir,'/EyeTra_TarSacOff_Subj_',userID,'.fig'])

%% Saccade Ending with curvature, change the Scatter point
% Saccade Ending at 100ms before saccade onset
Xlim1 = -3*pi/2;
Xlim2 = pi/2;
XGN = 10;

Ylim1 = -pi/3;
Ylim2 = pi/3;

% Only consider Saccade Ending when saccade onset and offset
SaveName{1} = '/SacCur_SacLocSacOn_Saccter';
SaveName{2} = '/SacCur_SacLocSacOff_Saccter';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

iFig = 2;

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[1,326,1261,651]);
tiledlayout(2,4,"TileSpacing","compact");
for iCond = CondI
    iCondI = iCondI+1;
    nexttile
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    hold on

    datas = find([Dataf1.TarDir] == iCond);
    SacLocAng = [];
    SacLocAng = [];
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        SacLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacLocGoc2{1}(4,end));
        % SacLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacLocGoc2{1}(4,end));
        if SacLocAng(iTrialI) > pi/2 && SacLocAng(iTrialI) < pi
            SacLocAng(iTrialI) = SacLocAng(iTrialI) - 2*pi;
        end
        % SacLocAng(iTrialI) = SacLocAng(iTrialI) - SacLocAng(iTrialI);
    end
    ProcX = []; ProcY = [];
    ProcX = SacLocAng;
    ProcY = sbd.SacCurPara1(datas);
    % ProcY = SacLocAng;
    % plot the real dot point
    scatter(ProcX,ProcY,20,colorRGB(iCondI,:),'filled');

    % plot a horizontal stright line
    plot(Xlim1:Xlim2,zeros(size(Xlim1:Xlim2)),'--k','LineWidth',1.5)
    % plot some vertical stright lines
    % at zero, at pi/2, at -pi/2, at -pi, at pi
    plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)

    hold off

    xtickValues = Xlim1 :pi/4 :Xlim2;
    xticks(xtickValues);
    xtickLabels = arrayfun(@num2str, rad2deg(xtickValues), 'UniformOutput', false);
    xticklabels(xtickLabels);

    ytickValues = -pi/2 :pi/10 :pi/2;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);

    ylim([Ylim1,Ylim2])
    xlim([Xlim1,Xlim2])
    if iCond == 0
        ylabel('Saccade Curvature, deg')
        xlabel('Saccade Ending')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square

end
sgtitle(['Relation Between Curvature and Saccade Ending at ',TiteName{iFig}, ' Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName{iFig},CondName,'Subj_',userID,'.fig'])
iFigAcc = iFigAcc+iFig;

%% Saccade Ending with curvature, change the Scatter point, and average curve on every scatter plot
% Saccade Ending at 100ms before saccade onset
Xlim1 = -3*pi/2;
Xlim2 = pi/2;
XGN = 19;

Ylim1 = -pi/3;
Ylim2 = pi/3;

% Only consider Saccade Ending when saccade onset and offset
SaveName{1} = '/SacCur_SacLocSacOn_Saccter_Ave';
SaveName{2} = '/SacCur_SacLocSacOff_Saccter_Ave';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

iFig = 2;
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[1,326,1261,651]);
tiledlayout(2,4,"TileSpacing","compact");
% plot std first
YGroup1 = [];
YG_ave1 = []; YG_ave2 = []; % value >= 0
YG_med1 = []; YG_med2 = [];
YG_std1 = []; YG_std2 = [];
YG_Q11 = []; YG_Q21 = [];
YG_Q12 = []; YG_Q22 = [];
XG_med1 = []; XG_med2 = [];
for iCond = CondI
    iCondI = iCondI+1;
    nexttile
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    hold on

    datas = find([Dataf1.TarDir] == iCond);
    SacLocAng = [];
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        % SacLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig+2,3));
        SacLocAng(iTrialI) = Dataf1(iTrial).SacLocGoc2{1}(4,end);
        if SacLocAng(iTrialI) > pi/2 && SacLocAng(iTrialI) < pi
            SacLocAng(iTrialI) = SacLocAng(iTrialI) - 2*pi;
        end
    end
    ProcX = []; ProcY = [];
    ProcX = SacLocAng;
    ProcY = sbd.SacCurPara1(datas);
    % plot the real dot point
    scatter(ProcX,ProcY,20,colorRGB1(iCondI,:),'filled');

    % adjust ProcY to make sure exluce the data don't want
    % 90 +- 25, <7deg excluded/ or maybe exclude all data within
    % the window
    % when fit, skip these datas
    % DropT = ProcX>=deg2rad(65)&ProcX<=deg2rad(115)&ProcY>=deg2rad(7)&ProcY<=deg2rad(-7)|...
    %     ProcX>=deg2rad(-115)&ProcX<=deg2rad(-65)&ProcY>=deg2rad(0)|...
    %     ProcX>=deg2rad(245)&ProcX<=deg2rad(295)&ProcY<=deg2rad(0);
    DropT = ProcX>=deg2rad(60)&ProcX<=deg2rad(90)&ProcY<=deg2rad(10)|...
        ProcX>=deg2rad(-270)&ProcX<=deg2rad(-240)&ProcY>=deg2rad(-10)|...
        ProcX>=deg2rad(-90)&ProcX<=deg2rad(-60)&ProcY>=deg2rad(0)|...
        ProcX>=deg2rad(-120)&ProcX<=deg2rad(-90)&ProcY<=deg2rad(0);
    % DropT = ProcX>=deg2rad(80)&ProcX<=deg2rad(90)|...
    %     ProcX>=deg2rad(-270)&ProcX<=deg2rad(-250)|...
    %     ProcX>=deg2rad(-90)&ProcX<=deg2rad(-70)|...
    %     ProcX>=deg2rad(-110)&ProcX<=deg2rad(-90);
    ProcX1 = ProcX;
    ProcY1 = ProcY;
    ProcX1(DropT) = [];
    ProcY1(DropT) = [];

    % change to moving average
    % add mean value + errorBar, line figure
    for iXG1 = 1:length(XGroup1)
        YGroup1{iCondI,iXG1} = ProcY1(ProcX1>=XGroup1(iXG1) & ProcX1<=XGroup2(iXG1));
        YG_ave1(iCondI,iXG1) = mean(YGroup1{iCondI,iXG1});
        YG_med1(iCondI,iXG1) = median(YGroup1{iCondI,iXG1});
        YG_std1(iCondI,iXG1) = std(YGroup1{iCondI,iXG1});
        YG_Q11(iCondI,iXG1) = prctile(YGroup1{iCondI,iXG1},25);
        YG_Q12(iCondI,iXG1) = prctile(YGroup1{iCondI,iXG1},75);
        XG_med1(iCondI,iXG1) = mean([XGroup1(iXG1),XGroup2(iXG1)]);
    end
    for iXG2 = 1:length(XGroup3)
        YGroup2{iCondI,iXG2} = ProcY1(ProcX1>=XGroup3(iXG2) & ProcX1<=XGroup4(iXG2));
        YG_ave2(iCondI,iXG2) = mean(YGroup2{iCondI,iXG2});
        YG_med2(iCondI,iXG2) = median(YGroup2{iCondI,iXG2});
        YG_std2(iCondI,iXG2) = std(YGroup2{iCondI,iXG2});
        YG_Q21(iCondI,iXG2) = prctile(YGroup2{iCondI,iXG2},25);
        YG_Q22(iCondI,iXG2) = prctile(YGroup2{iCondI,iXG2},75);
        XG_med2(iCondI,iXG2) = mean([XGroup3(iXG2),XGroup4(iXG2)]);
    end

    boundedline(XG_med1(iCondI,:), YG_ave1(iCondI,:), YG_std1(iCondI,:),':', 'nan', 'gap','cmap', colorRGB(iCondI,:),'alpha');
    boundedline(XG_med2(iCondI,:), YG_ave2(iCondI,:), YG_std2(iCondI,:),':', 'nan', 'gap','cmap', colorRGB(iCondI,:),'alpha');
    plot(XG_med1(iCondI,:),YG_ave1(iCondI,:),'Color',colorRGB2(iCondI,:),'LineWidth',2)
    plot(XG_med2(iCondI,:),YG_ave2(iCondI,:),'Color',colorRGB2(iCondI,:),'LineWidth',2)

    % plot a horizontal stright line
    plot(Xlim1:Xlim2,zeros(size(Xlim1:Xlim2)),'--k','LineWidth',1.5)
    % plot some vertical stright lines
    % at zero, at pi/2, at -pi/2, at -pi, at pi
    plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)

    hold off

    xtickValues = Xlim1 :pi/4 :Xlim2;
    xticks(xtickValues);
    xtickLabels = arrayfun(@num2str, rad2deg(xtickValues), 'UniformOutput', false);
    xticklabels(xtickLabels);

    ytickValues = -pi/2 :pi/10 :pi/2;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);

    ylim([Ylim1,Ylim2])
    xlim([Xlim1,Xlim2])
    if iCond == 0
        ylabel('Saccade Curvature, deg')
        xlabel('Saccade Ending')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square

end
sgtitle(['Relation Between Curvature and Saccade Ending at ',TiteName{iFig}, ' Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName{iFig},CondName,'Subj_', userID,'.fig'])
% iFigAcc = iFigAcc+iFig;

%% Align the initial location
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1261 651]);
tiledlayout(2,4,"TileSpacing","compact");
sbd.EyeLocMovXY = cell(1,size(Dataf1,2));
sbd.EyeLocMovPol = cell(1,size(Dataf1,2));
sbd.EyeLocRttPol = cell(1,size(Dataf1,2));

SaveName = [];
SaveName = '/EyeTra_Rotated_';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = find([Dataf1.TarDir] == iCond);
    for iTrial = datas
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLocRtt = [];
        EyeLocMovPol = [];
        EyeLocMovX = [];
        EyeLocMovY = [];
        EyeLoc = sbd.SacTraGoc1{iTrial};
        EyeLocMovX = EyeLoc(1,:) - EyeLoc(1,1); % Move X location to center
        EyeLocMovY = EyeLoc(2,:) - EyeLoc(2,1); % Move Y location to center
        [EyeLocMovPol(1,:),EyeLocMovPol(2,:)] = cart2pol(EyeLocMovX,EyeLocMovY); % to [-Pi, Pi]
        EyeLocRtt = wrapToPi(EyeLocMovPol(1,:) - sbd.SacIniDir(iTrial));
        p1 = [];
        s1 = [];
        % TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        % TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
        % Polar Plot
        p1 = polarplot(EyeLocRtt,EyeLocMovPol(2,:),'LineWidth',0.6,'Color',colorRGB(iCondI,:));
        hold on

        sbd.EyeLocMovXY{iTrial} = [EyeLocMovX;EyeLocMovY];
        sbd.EyeLocMovPol{iTrial} = EyeLocMovPol;
        sbd.EyeLocRttPol{iTrial} = [EyeLocRtt;EyeLocMovPol(2,:)];
    end
    % polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    % legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end

% sgtitle(['Saccadic Eye Traces Rotated ', ' Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,'Subj_',userID,'.fig'])

%% Eye Trace Rotated and averaging

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

% set a radius linspace
AveWin = 0.5;
RadLinspace = 0:AveWin:10;
numBins = length(RadLinspace) - 1;

SaveName = [];
SaveName = '/EyeTra_Rotated_Ave_';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = [];
    RadIndices = [];
    EyeLocTht = [];
    EyeLocRad = [];
    datas = find([Dataf1.TarDir] == iCond);
    
    EyeLocTht = nan(length(datas), max(cellfun('length',sbd.SacTraGoc1(datas))));
    EyeLocRad = nan(length(datas), max(cellfun('length',sbd.SacTraGoc1(datas))));
    RadIndices = nan(length(datas), max(cellfun('length',sbd.SacTraGoc1(datas))));

    iTriali = 0;

    for iTrial = datas
        iTriali = iTriali+1;
        EyeLoc = [];

        EyeLoc = sbd.EyeLocRttPol{iTrial};
        EyeLocTht(iTriali,1:length(EyeLoc(1,:))) = EyeLoc(1,:);
        EyeLocRad(iTriali,1:length(EyeLoc(2,:))) = EyeLoc(2,:);

        RadIndices(iTriali,1:length(EyeLoc(2,:))) = discretize(EyeLoc(2,:), RadLinspace);
    end
    
    % you have to wrap to pi then do the mean
    ThtMeans = arrayfun(@(b) mean(EyeLocTht(RadIndices == b)), 1:numBins);
    ThtStds = arrayfun(@(b) std(EyeLocTht(RadIndices == b)), 1:numBins);
    RadMeans = arrayfun(@(b) mean(EyeLocRad(RadIndices == b)), 1:numBins);
    p1 = [];
    p2 = [];
    p3 = [];
    s1 = [];

    p1 = polarplot(ThtMeans,RadMeans,'LineWidth',1,'Color',colorRGB2(iCondI,:));
    hold on
    p2 = polarplot(ThtMeans+ThtStds,RadMeans,'LineWidth',1,'Color',colorRGB2(iCondI,:),'LineStyle','--');
    P3 = polarplot(ThtMeans-ThtStds,RadMeans,'LineWidth',1,'Color',colorRGB2(iCondI,:),'LineStyle','--');

    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
% sgtitle(['Target Location at gocue, Distribution, Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,'Subj_', userID,'.fig'])


%% Plot the polar histogram for target distribution

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/TarDistOnst';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = [];
    RadIndices = [];
    EyeLocTht = [];
    EyeLocRad = [];
    datas = find([Dataf1.TarDir] == iCond);

    TarLocTemp = [];
    iTriali = 0;
    for iTrial = datas
        iTriali = iTriali + 1;
        [TarLocTemp(iTriali,1),TarLocTemp(iTriali,2)] = ...
            cart2pol(Dataf1(iTrial).SacTarGoc1(1,1),Dataf1(iTrial).SacTarGoc1(1,2));
    end
    polarhistogram(TarLocTemp(:,1),12,'FaceColor',colorRGB(iCondI,:))
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 20])
end
sgtitle(['Target Location at gocue, Distribution, Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_', userID,'.fig'])

%% Find the average trace, time warping, interpolation and down sampling
% I also need to find a way to reduce outliers
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/EyeTra_Warp_Ave';

SegNum = 12; % seperate into 12 segments
AngLinspace = linspace(-pi,pi,SegNum+1);
resampleRate = 1; % resample every 1ms
AveDur = 1:resampleRate:round(mean(sbd.SacDurGoc1)); % overall mean duration
AveTime = linspace(0, 1, length(AveDur));

sbd.EyeLocReSXY = cell(1,size(Dataf1,2));
sbd.EyeLocReSPol = cell(1,size(Dataf1,2));
sbd.AngIndices = discretize(sbd.SacAllDir, AngLinspace);
sbd.AveTrace = cell(length(CondI),SegNum);

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = [];
    AngIndices = [];
    EyeLocTht = [];
    EyeLocRad = [];

    datas = find([Dataf1.TarDir] == iCond);
    % AngIndices = discretize(sbd.SacAllDir(datas), AngLinspace);
    AngIndices = sbd.AngIndices(datas);

    for iSeg = 1:SegNum
        for iTrial = datas(AngIndices == iSeg)
            EyeLocCart = [];
            EyeLocPolr = [];
            EyeLocCart = sbd.EyeLocMovXY{iTrial};
            EyeLocPolr = sbd.EyeLocMovPol{iTrial};
            CurDur = [];
            CurDur = 1:length(EyeLocCart(1,:));
            step = [];
            newX = [];
            newY = [];
            newT = [];
            newR = [];
            NormTime = [];
            NormTime = (CurDur - CurDur(1)) / (CurDur(end) - CurDur(1));
            % cubic interpolation for shorter trajectories  
            if length(CurDur) < length(AveDur)
                newX = interp1(NormTime,EyeLocCart(1,:),AveTime, 'cubic');
                newY = interp1(NormTime,EyeLocCart(2,:),AveTime, 'cubic');
            % Downsample longer trajectories
            elseif length(CurDur) > length(AveDur)
                step = ceil(length(CurDur) / length(AveDur));
                newX = EyeLocCart(1,1:step:end);
                newY = EyeLocCart(2,1:step:end);
                % In case of downsampling making the vector too short, extend it
                if length(newX) < length(AveDur)
                    CurDur1 = [];
                    CurDur1 = 1:length(newX);
                    NormTime1 = [];
                    NormTime1 = (CurDur1 - CurDur1(1)) / (CurDur1(end) - CurDur1(1));
                    newX = interp1(NormTime1,newX,AveTime, 'cubic');
                    newY = interp1(NormTime1,newY,AveTime, 'cubic');
                end
            % if the traj have same length
            elseif length(CurDur) == length(AveDur)
                newX = EyeLocCart(1,:);
                newY = EyeLocCart(2,:);
            end
            
            sbd.EyeLocReSXY{iTrial} = [newX ; newY];
            [newT, newR] = cart2pol(newX, newY);
            sbd.EyeLocReSPol{iTrial} = [newT; newR];
        end
        
        iTriali = 0;
        newT = [];
        newR = [];
        newX = [];
        newY = [];
        newTAve = [];
        newRAve = [];
        newXAve = [];
        newYAve = [];
        for iTrial = datas(AngIndices == iSeg)
            iTriali = iTriali+1;
            newT(iTriali,:) = sbd.EyeLocReSPol{iTrial}(1,:);
            newR(iTriali,:) = sbd.EyeLocReSPol{iTrial}(2,:);
            newX(iTriali,:) = sbd.EyeLocReSXY{iTrial}(1,:);
            newY(iTriali,:) = sbd.EyeLocReSXY{iTrial}(2,:);
        end
        newTStd = std(newT);
        newRStd = std(newR);
        if length(datas(AngIndices == iSeg))>1
            newXAve = mean(newX);
            newYAve = mean(newY);
        else
            newXAve = newX;
            newYAve = newY;
        end
        [newTAve,newRAve] = cart2pol(newXAve,newYAve);
        sbd.AveTrace{iCondI,iSeg} = [newXAve;newYAve;newTAve;newRAve];
        p1 = polarplot(newTAve,newRAve,'LineWidth',1,'Color',colorRGB2(iCondI,:));
        % plot(newXAve,newYAve,'LineWidth',1,'Color',colorRGB(iCondI,:))
        hold on
    end
    hold off
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 10])
end
sgtitle(['Average Traces, Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_', userID,'.fig'])

%% Try to normalize 1
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/EyeTra_Warp_Ave_Norm';

% SegNum = 12; % seperate into 12 segments
% AngLinspace = linspace(-pi,pi,SegNum+1);
% resampleRate = 1; % resample every 1ms
% AveDur = 1:resampleRate:round(mean(sbd.SacDurGoc1)); % overall mean duration
% AveTime = linspace(0, 1, length(AveDur));

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = [];
    AngIndices = [];
    EyeLocTht = [];
    EyeLocRad = [];

    datas = find([Dataf1.TarDir] == iCond);
    % AngIndices = discretize(sbd.SacAllDir(datas), AngLinspace);
    AngIndices = sbd.AngIndices(datas);

    for iSeg = 1:SegNum
        EyeLocCart = [];
        EyeLocPolr = [];
        EyeLocThtNew = [];
        OverAllAng = [];
        dx = [];
        dy = [];
        TangAng = [];
        OverAllAng = [];
        if isempty(sbd.AveTrace{iCondI,iSeg})
            continue
        end
        EyeLocCart = sbd.AveTrace{iCondI,iSeg}(1:2,:);
        EyeLocPolr = sbd.AveTrace{iCondI,iSeg}(3:4,:);
        % Calculate differences (discrete derivatives)
        dx = diff(EyeLocCart(1,:));
        dy = diff(EyeLocCart(2,:));
        TangAng = atan2(dy, dx);
        OverAllAng = EyeLocPolr(1,end);
        
        if iCondI == 1
            TangAngBase(iSeg,:) = TangAng;
        end

        EyeLocThtNew = [0,TangAng./TangAngBase(iSeg,:).*OverAllAng];
        p1 = polarplot(EyeLocThtNew,EyeLocPolr(2,:),'LineWidth',1,'Color',colorRGB(iCondI,:));
        hold on
    end
    hold off
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 10])
end
sgtitle(['Average Traces Normlization Try 1, Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_', userID,'.fig'])
