% Data Processing
% This script is used for data processing
% Analysis based on prepro 4
% adjusted on Oct 12, exclude several figures and add some new figures
% Data Save in Result/ Oct12
% Adjusted on Oct 28, add sinwave fit
% Adjusted on Oct 31, adjust the way of doing averaging

%% Load Data
% load('Raj01_120923_PreProcessed4.mat')
DatafAll = [];
matfilelist = dir('*_PreProcessed4.mat');
for iSubJ = 1:size(matfilelist,1)
    matfilename = matfilelist(iSubJ).name;
    fprintf('Loading file: %s\n', matfilename);
    load(matfilename);
    for iTrial = 1:size(Dataf,2)
        Dataf(iTrial).SubjN = iSubJ;
    end
    DatafAll = [DatafAll, Dataf];
    clearvars -except DatafAll matfilelist iSubj
end
clearvars -except DatafAll
save('AllSubj_301023_PreProcessed4.mat','-v7.3')

%% Condition choose
SubjN = max([DatafAll.SubjN]);
LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';
CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondName = 'All';

ifDoBasic = 1;

userID = 'AllSubject';
DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/',userID,'/'];
AnaData = 'Nov04';
ResultDir = [DataDir,'ResultFig/',AnaData,'/'];
if exist(ResultDir,'dir')~=7
    mkdir(ResultDir);
end

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
    Dataf1 = DatafAll;

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
        elseif Dataf1(iTrial).SacTimeGoc2(end,1)<100 || Dataf1(iTrial).SacTimeGoc2(end,1)>400
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacTimeGoc2(end-1,1)>=120
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
        elseif abs(Dataf1(iTrial).SacPvelGoc1) <50
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

    % iDrop3 = [80,96,102,104,112,119,127,183,197,211,306,337,349,359,...
    %     368,373,388,389,448,478,513,520,548,579,580,582,624,...
    %     625,637,654,655,665,672,8,17,43,55,122,130,166,186,193,219,224,...
    %     264,272,327,329,332,342,345,346,350,354,372,375,378,383,...
    %     413,419,437,456,465,482,506,509,...
    %     552,554,555,570,577,597,600,601,646,660,669,129,209,...
    %     260,300,326,333,376,385,411,417,472,510,546,571];
    %
    % iDrop3 = [];

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

Xlim1 = -pi/2;
Xlim2 = 3*pi/2;

windSize = pi/9; % 20 deg
increm = pi/18; % 10 deg
XGroup1 = -pi/2:increm:(pi/2-windSize);
XGroup2 = (-pi/2+windSize):increm:pi/2;
XGroup3 = pi/2:increm:(3*pi/2-windSize);
XGroup4 = (pi/2+windSize):increm:3*pi/2;

%% Target location with curvature, change the Scatter point
% target location at 100ms before saccade onset
Xlim1 = -pi/2;
Xlim2 = 3*pi/2;
XGN = 10;

Ylim1 = -pi/3;
Ylim2 = pi/3;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_TarLocSacOn_Saccter';
SaveName{2} = '/SacCur_TarLocSacOff_Saccter';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

for iFig = 1:2
    for iSubJ = 1:4
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

            datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] == iSubJ);
            TarLocAng = [];
            iTrialI = 0;
            for iTrial = datas
                iTrialI = iTrialI+1;
                TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig+2,3));
                if TarLocAng(iTrialI) > -pi && TarLocAng(iTrialI) < -pi/2
                    TarLocAng(iTrialI) = TarLocAng(iTrialI) + 2*pi;
                end
            end
            ProcX = []; ProcY = [];
            ProcX = TarLocAng;
            ProcY = sbd.SacCurPara1(datas);
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
                xlabel('Target Location')
            end
            title(LegText{iCond+1},'FontWeight','normal')
            set(gca,'FontSize',14)
            axis square
            
        end
        sgtitle(['Relation Between Curvature and Target Location at ',TiteName{iFig}, ' Subj ',num2str(iSubJ)],'FontSize',15)
        saveas(gcf,[ResultDir,SaveName{iFig},CondName,'Subj',num2str(iSubJ),'.fig'])
    end
end
iFigAcc = iFigAcc+iFig*iSubJ;

%% Target location with curvature, change the Scatter point, and median curve on every scatter plot
% target location at 100ms before saccade onset
Xlim1 = -pi/2;
Xlim2 = 3*pi/2;
XGN = 19;

Ylim1 = -pi/3;
Ylim2 = pi/3;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_TarLocSacOn_Saccter_Ave';
SaveName{2} = '/SacCur_TarLocSacOff_Saccter_Ave';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

for iFig = 1
    for iSubJ = 1:4
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

            datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] == iSubJ);
            TarLocAng = [];
            iTrialI = 0;
            for iTrial = datas
                iTrialI = iTrialI+1;
                TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig+2,3));
                if TarLocAng(iTrialI) > -pi && TarLocAng(iTrialI) < -pi/2
                    TarLocAng(iTrialI) = TarLocAng(iTrialI) + 2*pi;
                end
            end
            ProcX = []; ProcY = [];
            ProcX = TarLocAng;
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
                ProcX>=deg2rad(90)&ProcX<=deg2rad(120)&ProcY>=deg2rad(-10)|...
                ProcX>=deg2rad(-120)&ProcX<=deg2rad(-60)&ProcY>=deg2rad(0)|...
                ProcX>=deg2rad(240)&ProcX<=deg2rad(300)&ProcY<=deg2rad(0);
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
                xlabel('Target Location')
            end
            title(LegText{iCond+1},'FontWeight','normal')
            set(gca,'FontSize',14)
            axis square
            
        end
        sgtitle(['Relation Between Curvature and Target Location at ',TiteName{iFig}, ' Subj ',num2str(iSubJ)],'FontSize',15)
        saveas(gcf,[ResultDir,SaveName{iFig},CondName,'Subj',num2str(iSubJ),'.fig'])
    end
end
iFigAcc = iFigAcc+iFig*iSubJ;

%% Target location with curvature Mean value, plot together
% target location at 100ms before saccade onset
Xlim1 = -pi/2;
Xlim2 = 3*pi/2;
XGN = 19;

Ylim1 = -pi/3;
Ylim2 = pi/3;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_TarLocSacOn_Saccter_AveAll';
SaveName{2} = '/SacCur_TarLocSacOff_Saccter_AveAll';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

SubjSign = ['+','*','.','x'];

for iFig = 1:2
    iCondI = 0;
    figure(iFig + iFigAcc)
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
        % plot std first
        XGroup = linspace(Xlim1, Xlim2, XGN);
        YGroup1 = [];
        YG_ave1 = []; % value >= 0
        YG_med1 = [];
        YG_std1 = [];
        YG_Q11 = [];
        YG_Q12 = [];
        XG_med1 = [];
        for iSubJ = 1:SubjN          
            datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] == iSubJ);
            TarLocAng = [];
            iTrialI = 0;
            for iTrial = datas
                iTrialI = iTrialI+1;
                TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig+2,3));
                if TarLocAng(iTrialI) > -pi && TarLocAng(iTrialI) < -pi/2
                    TarLocAng(iTrialI) = TarLocAng(iTrialI) + 2*pi;
                end
            end
            ProcX = []; ProcY = []; DropT = [];
            ProcX = TarLocAng;
            ProcY = sbd.SacCurPara1(datas);
            DropT = ProcX>=deg2rad(60)&ProcX<=deg2rad(90)&ProcY<=deg2rad(10)|...
                ProcX>=deg2rad(90)&ProcX<=deg2rad(120)&ProcY>=deg2rad(-10)|...
                ProcX>=deg2rad(-120)&ProcX<=deg2rad(-60)&ProcY>=deg2rad(0)|...
                ProcX>=deg2rad(240)&ProcX<=deg2rad(300)&ProcY<=deg2rad(0);
            ProcX1 = ProcX;
            ProcY1 = ProcY;
            ProcX1(DropT) = [];
            ProcY1(DropT) = [];
            scatter(ProcX,ProcY,20,colorRGB(iCondI,:),'.','LineWidth',1)
            % % plot the real dot point
            % if iSubJ == 1
            %     scatter(ProcX,ProcY,20,colorRGB(iCondI,:),'+','LineWidth',1);   
            % elseif iSubJ == 2
            %     scatter(ProcX,ProcY,20,colorRGB(iCondI,:),'.','LineWidth',1);  
            % elseif iSubJ == 3
            %     scatter(ProcX,ProcY,20,colorRGB(iCondI,:),'*','LineWidth',1);  
            % elseif iSubJ == 4
            %     scatter(ProcX,ProcY,20,colorRGB(iCondI,:),'x','LineWidth',1);  
            % end

            % change to moving average
            % add mean value + errorBar, line figure
            for iXG1 = 1:length(XGroup1)
                YGroup1{iSubJ,iXG1} = ProcY1(ProcX1>=XGroup1(iXG1) & ProcX1<=XGroup2(iXG1));
                YG_ave1(iSubJ,iXG1) = mean(YGroup1{iSubJ,iXG1});
                YG_med1(iSubJ,iXG1) = median(YGroup1{iSubJ,iXG1});
                YG_std1(iSubJ,iXG1) = std(YGroup1{iSubJ,iXG1});
                YG_Q11(iSubJ,iXG1) = prctile(YGroup1{iSubJ,iXG1},25);
                YG_Q12(iSubJ,iXG1) = prctile(YGroup1{iSubJ,iXG1},75);
                XG_med1(iSubJ,iXG1) = mean([XGroup1(iXG1),XGroup2(iXG1)]);
            end
            for iXG2 = 1:length(XGroup3)
                YGroup2{iSubJ,iXG2} = ProcY1(ProcX1>=XGroup3(iXG2) & ProcX1<=XGroup4(iXG2));
                YG_ave2(iSubJ,iXG2) = mean(YGroup2{iSubJ,iXG2});
                YG_med2(iSubJ,iXG2) = median(YGroup2{iSubJ,iXG2});
                YG_std2(iSubJ,iXG2) = std(YGroup2{iSubJ,iXG2});
                YG_Q21(iSubJ,iXG2) = prctile(YGroup2{iSubJ,iXG2},25);
                YG_Q22(iSubJ,iXG2) = prctile(YGroup2{iSubJ,iXG2},75);
                XG_med2(iSubJ,iXG2) = mean([XGroup3(iXG2),XGroup4(iXG2)]);
            end

            boundedline(XG_med1(iSubJ,:), YG_ave1(iSubJ,:), YG_std1(iSubJ,:),':', 'nan', 'gap','cmap', colorRGB1(iCondI,:),'alpha');
            boundedline(XG_med2(iSubJ,:), YG_ave2(iSubJ,:), YG_std2(iSubJ,:),':', 'nan', 'gap','cmap', colorRGB1(iCondI,:),'alpha');
        end
        p1 = [];
        p2 = [];
        % plot mean value
        for iSubJ = 1:SubjN           
            p1{iSubJ} = plot(XG_med1(iSubJ,:),YG_med1(iSubJ,:),'Color',colorRGB2(iCondI,:),'LineWidth',2);
            p2{iSubJ} = plot(XG_med2(iSubJ,:),YG_med2(iSubJ,:),'Color',colorRGB2(iCondI,:),'LineWidth',2);
            if iSubJ == 1
                p1{iSubJ}.LineStyle = '--';
                % p1{iSubJ}.LineWidth = 3;
                p2{iSubJ}.LineStyle = '--';
                % p2{iSubJ}.LineWidth = 3;
            elseif iSubJ ==2
                p1{iSubJ}.LineStyle = '-';
                p1{iSubJ}.LineWidth = 2.5;
                p2{iSubJ}.LineStyle = '-';
                p2{iSubJ}.LineWidth = 2.5;
            elseif iSubJ ==3
                p1{iSubJ}.LineStyle = ':';
                % p1{iSubJ}.LineWidth = 2.5;
                p2{iSubJ}.LineStyle = ':';
                % p2{iSubJ}.LineWidth = 2.5;
            elseif iSubJ ==4
                p1{iSubJ}.LineStyle = '-.';
                % p1{iSubJ}.LineWidth = 2.5;
                p2{iSubJ}.LineStyle = '-.';
                % p2{iSubJ}.LineWidth = 2.5;
            end
        end

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
            xlabel('Target Location')
        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
        sgtitle(['Relation Between Curvature and Target Location at ',TiteName{iFig}],'FontSize',15)
        saveas(gcf,[ResultDir,SaveName{iFig},CondName,'1.fig'])
    end
end
iFigAcc = iFigAcc+iFig;

%% Start From Now, combine all the data together
% fit first
SubjC = [1,2,3]; % subject choosed
SubjNC = 4; % subject not choosed
iCondI = 0;

% plot std first
YGroup1 = []; YGroup2 = [];
YG_ave1 = []; YG_ave2 = []; % value >= 0
YG_med1 = []; YG_med2 = [];
YG_std1 = []; YG_std2 = [];
YG_Q11 = []; YG_Q21 = [];
YG_Q12 = []; YG_Q22 = [];
XG_med1 = []; XG_med2 = [];

YGroup01 = []; YGroup02 = [];

mdl1 = [];
mdl2 = [];
iFig = 2;
for iCond = CondI
    iCondI = iCondI+1;
    
    SubjID = [];
    datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] ~= SubjNC);
    TarLocAng = [];
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig+2,3));
        if TarLocAng(iTrialI) > -pi && TarLocAng(iTrialI) < -pi/2
            TarLocAng(iTrialI) = TarLocAng(iTrialI) + 2*pi;
        end
        SubjID(iTrialI) = Dataf1(iTrial).SubjN;
    end

    ProcX = []; ProcY = [];
    ProcX = TarLocAng;
    ProcY = sbd.SacCurPara1(datas);

    [ProcX, originalIndices] = sort(ProcX);
    ProcY = ProcY(originalIndices);
    SubjID = SubjID(originalIndices);


    kk = 15; %deg, number adjusted

    DropT1 = ProcX>=deg2rad(90-kk)&ProcX<=deg2rad(90+kk)|...
        ProcX>=deg2rad(-90-kk)&ProcX<=deg2rad(-90+kk)|...
        ProcX>=deg2rad(270-kk)&ProcX<=deg2rad(270+kk);

    DropT2 = ProcX>=deg2rad(60)&ProcX<=deg2rad(90)&ProcY<=deg2rad(10)|...
        ProcX>=deg2rad(90)&ProcX<=deg2rad(120)&ProcY>=deg2rad(-10)|...
        ProcX>=deg2rad(-120)&ProcX<=deg2rad(-60)&ProcY>=deg2rad(0)|...
        ProcX>=deg2rad(240)&ProcX<=deg2rad(300)&ProcY<=deg2rad(0);

    ProcX1 = ProcX;
    ProcY1 = ProcY;
    ProcX1(DropT1|DropT2) = [];
    ProcY1(DropT1|DropT2) = [];
    SubjID(DropT1|DropT2) = [];

    DropT3 = [];
    for iXG1 = 1:length(XGroup1)
        if iXG1 == length(XGroup1)
            YGroup1{iCondI,iXG1} = ProcY1(ProcX1>=XGroup1(iXG1) & ProcX1<=XGroup2(iXG1));
            YGroup01{iCondI,iXG1} = ProcY1(ProcX1>=XGroup1(iXG1) & ProcX1<=XGroup2(iXG1));
        else
            YGroup1{iCondI,iXG1} = ProcY1(ProcX1>=XGroup1(iXG1) & ProcX1<XGroup2(iXG1));
            YGroup01{iCondI,iXG1} = ProcY1(ProcX1>=XGroup1(iXG1) & ProcX1<(XGroup1(iXG1)+XGroup2(iXG1))/2);
        end
        YG_ave1(iCondI,iXG1) = mean(YGroup1{iCondI,iXG1});
        YG_med1(iCondI,iXG1) = median(YGroup1{iCondI,iXG1});
        YG_std1(iCondI,iXG1) = std(YGroup1{iCondI,iXG1});
        XG_med1(iCondI,iXG1) = mean([XGroup1(iXG1),XGroup2(iXG1)]);
        DropT3 = [DropT3,(YGroup01{iCondI,iXG1}-YG_ave1(iCondI,iXG1)) >= 2*YG_std1(iCondI,iXG1) |...
            (YGroup01{iCondI,iXG1}-YG_ave1(iCondI,iXG1)) <= -2*YG_std1(iCondI,iXG1)];
    end
    for iXG2 = 1:length(XGroup3)
        if iXG2 == length(XGroup3)
            YGroup2{iCondI,iXG2} = ProcY1(ProcX1>=XGroup3(iXG2) & ProcX1<=XGroup4(iXG2));
            YGroup02{iCondI,iXG2} = ProcY1(ProcX1>=XGroup3(iXG2) & ProcX1<=XGroup4(iXG2));
        else
            YGroup2{iCondI,iXG2} = ProcY1(ProcX1>=XGroup3(iXG2) & ProcX1<XGroup4(iXG2));
            YGroup02{iCondI,iXG2} = ProcY1(ProcX1>=XGroup3(iXG2) & ProcX1<(XGroup3(iXG2)+XGroup4(iXG2))/2);
        end
        YG_ave2(iCondI,iXG2) = mean(YGroup2{iCondI,iXG2});
        YG_med2(iCondI,iXG2) = median(YGroup2{iCondI,iXG2});
        YG_std2(iCondI,iXG2) = std(YGroup2{iCondI,iXG2});
        XG_med2(iCondI,iXG2) = mean([XGroup3(iXG2),XGroup4(iXG2)]);
        DropT3 = [DropT3,(YGroup02{iCondI,iXG2}-YG_ave2(iCondI,iXG2)) >= 2*YG_std2(iCondI,iXG2) |...
            (YGroup02{iCondI,iXG2}-YG_ave2(iCondI,iXG2)) <= -2*YG_std2(iCondI,iXG2)];
    end

    DropT4 = ProcX1>=deg2rad(0)&ProcX1<=deg2rad(90)&ProcY1<=deg2rad(-35)|...
        ProcX1>=deg2rad(0)&ProcX1<=deg2rad(90)&ProcY1>=deg2rad(35);

    ProcX1(logical(DropT3)|DropT4) = [];
    ProcY1(logical(DropT3)|DropT4) = [];
    SubjID(logical(DropT3)|DropT4) = [];
    
    % use tangent fit first
    modelTan = @(a,x)(a(1)*tan(a(2)*x)+a(3));
    a = [1,1,0];
    % RobustOpts = statset('fitnlm');
    RobustOpts = statset('RobustWgtFun', 'bisquare');
    mdl1{iCondI} = fitnlm(ProcX1(ProcX1<pi/2),ProcY1(ProcX1<pi/2),modelTan,a,'Options', RobustOpts);
    mdl2{iCondI} = fitnlm(ProcX1(ProcX1>pi/2),ProcY1(ProcX1>pi/2),modelTan,a,'Options', RobustOpts);

    ProcXS{iCondI} = ProcX1;
    ProcYS{iCondI} = ProcY1;
    SubjIDS{iCondI} = SubjID;
end


%% Target location with curvature, change the Scatter point, and median curve on every scatter plot
% target location at 100ms before saccade onset
Xlim1 = -pi/2;
Xlim2 = 3*pi/2;
XGN = 19;

Ylim1 = -pi/3;
Ylim2 = pi/3;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_TarLocSacOn_Saccter_TanFit';
SaveName{2} = '/SacCur_TarLocSacOff_Saccter_TanFit';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

iFig = 2;
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[1,54,1918,923]);
tiledlayout(2,4,"TileSpacing","compact");

YGroup01 = []; YGroup02 = [];
for iCond = CondI
    iCondI = iCondI+1;
    nexttile
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    hold on

    scatter(ProcXS{iCondI},ProcYS{iCondI},30,colorRGB(iCondI,:),'.','LineWidth',2)
    % use nlinfit
    kk = pi/25;
    beta1 = mdl1{iCondI}.Coefficients.Estimate;
    xx1 = min(ProcXS{iCondI}(ProcXS{iCondI}<pi/2))-kk:kk:max(ProcXS{iCondI}(ProcXS{iCondI}<pi/2))+kk;
    yy1 = beta1(1).*tan(beta1(2).*xx1)+beta1(3);
    plot(xx1,yy1,'Color',colorRGB2(iCondI,:),'LineWidth',2)

    beta2 = mdl2{iCondI}.Coefficients.Estimate;
    xx2 = min(ProcXS{iCondI}(ProcXS{iCondI}>pi/2))-kk:kk:max(ProcXS{iCondI}(ProcXS{iCondI}>pi/2))+kk;
    yy2 = beta2(1).*tan(beta2(2).*xx2)+beta2(3);
    plot(xx2,yy2,'Color',colorRGB2(iCondI,:),'LineWidth',2)

    % plot a horizontal stright line
    plot(Xlim1:Xlim2,zeros(size(Xlim1:Xlim2)),'--k','LineWidth',1.5)
    % plot some vertical stright lines
    % at zero, at pi/2, at -pi/2, at -pi, at pi
    plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)

    RMSE1 = mdl1{iCondI}.RMSE;
    RSqAdj1 = mdl1{iCondI}.Rsquared.Adjusted;
    pVal1 = 'p < 0.01';

    leftText = {['a = ',num2str(beta1(1),'%.2f'),', b = ',num2str(beta1(2),'%.2f'),', c = ',num2str(beta1(3),'%.2f')];
        ['R^2 = ',num2str(RSqAdj1,'%.2f')];
        ['RMSE = ', num2str(RMSE1,'%.2f')];
        ['n = ', num2str(length(ProcXS{iCondI}(ProcXS{iCondI}<pi/2))),', ' pVal1]};

    RMSE2 = mdl2{iCondI}.RMSE;
    RSqAdj2 = mdl2{iCondI}.Rsquared.Adjusted;
    pVal2 = 'p < 0.01';

    rightText = {['a = ',num2str(beta2(1),'%.2f'),', b = ',num2str(beta2(2),'%.2f'),', c = ',num2str(beta2(3),'%.2f')];
        ['R^2 = ',num2str(RSqAdj2,'%.2f')];
        ['RMSE = ', num2str(RMSE2,'%.2f')];
        ['n = ', num2str(length(ProcXS{iCondI}(ProcXS{iCondI}>pi/2))),', ' pVal2]};

    text(Xlim1+deg2rad(10), Ylim2-deg2rad(20), leftText, 'FontSize', 12);
    text(pi/2+deg2rad(10), Ylim2-deg2rad(20), rightText, 'FontSize', 12);

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
        xlabel('Target Location')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square

end
sgtitle(['Relation Between Curvature and Target Location at ',TiteName{iFig}, ' Subj All',],'FontSize',15)
saveas(gcf,[ResultDir,SaveName{iFig},CondName,'Subj_All','.fig'])
iFigAcc = iFigAcc+iFig;


%% Target location with Curvature size, all together in one plot
% target location at 100ms before saccade onset
Xlim1 = -pi/2;
Xlim2 = 3*pi/2;
XGN = 19;

Ylim1 = -pi/5.5;
Ylim2 = pi/5.5;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_TarLocSacOn_AveComp';
SaveName{2} = '/SacCur_TarLocSacOff_AveComp';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

for iFig = 1:2
    figure(iFig + iFigAcc)
    set(gcf,'Position',[1,326,1261,651]);
    tiledlayout(1,2,"TileSpacing","compact");
    iCondIAll = 0;
    iCondIAll1 = 0;
    for iCondG = 1:2
        CondItemp = [0,1,3,5;0,2,4,6];
        CondNametemp = {'CCW','CW'};
        iCondI = 0;
        nexttile
        hold on
        % plot std first
        % plot std first
        YGroup1 = []; YGroup2 = [];
        YG_ave1 = []; YG_ave2 = []; % value >= 0
        YG_med1 = []; YG_med2 = [];
        YG_std1 = []; YG_std2 = [];
        YG_Q11 = []; YG_Q21 = [];
        YG_Q12 = []; YG_Q22 = [];
        XG_med1 = []; XG_med2 = [];

        YGroup01 = []; YGroup02 = [];

        for iCond = CondItemp(iCondG,:)
            iCondI = iCondI+1;
            iCondIAll = iCondIAll+1;

            
            ProcX1 = []; ProcX2 = [];
            ProcY1 = []; ProcY2 = [];
            if iCondG == 1 % CCW
                ProcX1 = ProcXS{iCondI};
                ProcY1 = ProcYS{iCondI};
            elseif iCondG == 2 % CW
                if iCondI ~=1
                    ProcX1 = ProcXS{iCondI+3};
                    ProcY1 = ProcYS{iCondI+3};
                elseif iCondI == 1
                    ProcX1 = ProcXS{1};
                    ProcY1 = ProcYS{1};
                end
            end
            % scatter(ProcX1,ProcY1,30,colorRGB(iCondI,:),'.','LineWidth',2)

            for iXG1 = 1:length(XGroup1)
                if iXG1 == length(XGroup1)
                    YGroup1{iCondIAll,iXG1} = ProcY1(ProcX1>=XGroup1(iXG1) & ProcX1<=XGroup2(iXG1));
                else
                    YGroup1{iCondIAll,iXG1} = ProcY1(ProcX1>=XGroup1(iXG1) & ProcX1<XGroup2(iXG1));
                end
                YG_ave1(iCondIAll,iXG1) = mean(YGroup1{iCondIAll,iXG1});
                YG_med1(iCondIAll,iXG1) = median(YGroup1{iCondIAll,iXG1});
                YG_std1(iCondIAll,iXG1) = std(YGroup1{iCondIAll,iXG1});
                XG_med1(iCondIAll,iXG1) = mean([XGroup1(iXG1),XGroup2(iXG1)]);
            end
            for iXG2 = 1:length(XGroup3)
                if iXG2 == length(XGroup3)
                    YGroup2{iCondIAll,iXG2} = ProcY1(ProcX1>=XGroup3(iXG2) & ProcX1<=XGroup4(iXG2));
                else
                    YGroup2{iCondIAll,iXG2} = ProcY1(ProcX1>=XGroup3(iXG2) & ProcX1<XGroup4(iXG2));
                end
                YG_ave2(iCondIAll,iXG2) = mean(YGroup2{iCondIAll,iXG2});
                YG_med2(iCondIAll,iXG2) = median(YGroup2{iCondIAll,iXG2});
                YG_std2(iCondIAll,iXG2) = std(YGroup2{iCondIAll,iXG2});
                XG_med2(iCondIAll,iXG2) = mean([XGroup3(iXG2),XGroup4(iXG2)]);
            end

            boundedline(XG_med1(iCondIAll,:), YG_ave1(iCondIAll,:), YG_std1(iCondIAll,:),':', 'nan', 'gap','cmap', colorRGB(iCondI,:),'alpha');
            boundedline(XG_med2(iCondIAll,:), YG_ave2(iCondIAll,:), YG_std2(iCondIAll,:),':', 'nan', 'gap','cmap', colorRGB(iCondI,:),'alpha');

        end
        iCondI = 0;
        for iCond = CondItemp(iCondG,:)
            iCondI = iCondI+1;
            iCondIAll1 = iCondIAll1+1;
            plot(XG_med1(iCondIAll1,:), YG_ave1(iCondIAll1,:),'Color',colorRGB2(iCondI,:),'LineWidth',2)
            plot(XG_med2(iCondIAll1,:), YG_ave2(iCondIAll1,:),'Color',colorRGB2(iCondI,:),'LineWidth',2)
        end
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
            xlabel('Target Location')
        end
        title(CondNametemp{iCondG},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square

        patches = findobj(gcf,'Type', 'patch'); % for all figures

        % Set the FaceAlpha for all patches found
        alphaValue = 0.1; % A value between 0 and 1
        for i = 1:length(patches)
            patches(i).FaceAlpha = alphaValue;
        end

        sgtitle(['Relation Between Curvature and Target Location at ',TiteName{iFig}],'FontSize',15)
        saveas(gcf,[ResultDir,SaveName{iFig},CondName,'2.fig'])
    end
end
iFigAcc = iFigAcc+iFig;

%% repeated 2 way Anova
% SubjID = [1,2,3]
% Factor1 = [1,2,3,4] % target location
% 1 = upper to y; 2 = upper to x; 3 = downw to x; 4 = downw to y
% Factor2 = [1,2,3,4] % 4 speed
% 1 = 0; 2 = 15; 3 = 30; 4 = 45

Fact1 = [1,2,3,4;1,5,6,7]; % velcity

Fact21 = [pi/2,  3*pi/4,pi,    5*pi/4;...
          pi/4,  0,    -3*pi/4,-pi/2]; % target location
Fact22 = [3*pi/4,pi,    5*pi/4,3*pi/2;...
          pi/2,  pi/4,  0,   -3*pi/4]; % target location

SubjID = [1,2,3];

DirName = {'CCW','CCW','CCW','CCW';
    'CW','CW','CW','CW'};
VisualF = {'Left','Right','Left','Right';
    'Left','Right','Left','Right'};

for iMDir = 1:2 % CCW and CW
    for iVisualF = 1:2
        OutCome = [];
        Fact1Val = [];
        Fact2Val = [];
        SubjIDVal = [];
        for iVel = 1:4 % condition number
            for iLoc = 1:4
                dataS = [];
                dataS = ProcXS{Fact1(iMDir,iVel)}>=Fact21(iVisualF,iLoc) & ProcXS{Fact1(iMDir,iVel)}<=Fact22(iMDir,iLoc);
                OutCome = [OutCome, ProcYS{Fact1(iMDir,iVel)}(dataS)];
                Fact1Val = [Fact1Val, iVel * ones(1,sum(dataS))];
                Fact2Val = [Fact2Val, iVel * ones(1,sum(dataS))];
                SubjIDVal = [SubjIDVal, SubjIDS{Fact1(iMDir,iVel)}(dataS)];
            end
        end
    end
end

%% Target location with Curvature signed size, all together in one plot
% target location at 100ms before saccade onset
Xlim1 = -pi;
Xlim2 = pi;
XGN = 13;

Ylim1 = -pi/4;
Ylim2 = pi/4;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur2Contl_TarLocSacOn_EachSubj';
SaveName{2} = '/SacCur2Contl_TarLocSacOff_EachSubj';

TiteName{1} = 'Saccade Onset, SineFit';
TiteName{2} = 'Saccade Offset, SineFit';

for iFig = 1:2
    figure(iFig + iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    tiledlayout(2,4,"TileSpacing","compact");
    for iCondG = 1:2
        CondItemp = [0,1,3,5;0,2,4,6];
    for iSubJ = 1:SubjN
        iCondI = 0;
        nexttile
        hold on
        XGroup = linspace(Xlim1, Xlim2, XGN);
        YGroup1 = [];
        YG_ave1 = [];
        YG_med1 = [];
        YG_std1 = [];
        XG_med1 = [];
        FitX = [];
        FitY = [];
        for iCond = CondItemp(iCondG,:)
            iCondI = iCondI+1;
            datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] == iSubJ);
            TarLocAng = [];
            iTrialI = 0;
            for iTrial = datas
                iTrialI = iTrialI+1;
                TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig+2,3));
            end
            ProcX = []; ProcY = [];
            ProcX = TarLocAng;
            ProcY = sbd.SacCurPara1(datas);

            % add mean value + errorBar, line figure
            for iXG1 = 1:length(XGroup)-1
                if iCondI == 1
                    YGroup1{iCondI,iXG1} = ProcY(ProcX>=XGroup(iXG1) & ProcX<=XGroup(iXG1+1));
                    YG_ave1(iCondI,iXG1) = mean(YGroup1{iCondI,iXG1});
                    YG_med1(iCondI,iXG1) = median(YGroup1{iCondI,iXG1});
                    YG_std1(iCondI,iXG1) = std(YGroup1{iCondI,iXG1});
                    XG_med1(iCondI,iXG1) = mean([XGroup(iXG1),XGroup(iXG1+1)]);
                else
                    YGroup1{iCondI,iXG1} = ProcY(ProcX>=XGroup(iXG1) & ProcX<=XGroup(iXG1+1));
                    YG_ave1(iCondI,iXG1) = mean(YGroup1{iCondI,iXG1})-YG_ave1(1,iXG1);
                    YG_med1(iCondI,iXG1) = median(YGroup1{iCondI,iXG1});
                    YG_std1(iCondI,iXG1) = std(YGroup1{iCondI,iXG1});
                    XG_med1(iCondI,iXG1) = mean([XGroup(iXG1),XGroup(iXG1+1)]);
                end
            end

        end
        iCondI = 1;
        % Fit the sin wave
        for iCond = CondItemp(iCondG,2:end)
            iCondI = iCondI+1;           
            p{iCondI} = plot(XG_med1(iCondI,:),YG_ave1(iCondI,:),'Color',colorRGB2(iCondI,:),'LineWidth',2);
        end
        % plot a horizontal stright line
        plot(Xlim1:Xlim2,zeros(size(Xlim1:Xlim2)),'--k','LineWidth',1.5)
        % plot some vertical stright lines
        % at zero, at pi/2, at -pi/2, at -pi, at pi
        % plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
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
            xlabel('Target Location')
        end
        title(['Subject ', num2str(iSubJ)],'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
        sgtitle(['Relation Between Curvature Difference 2 Control and Target Location at ',TiteName{iFig}],'FontSize',15)
        saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
    end
    end
end
iFigAcc = iFigAcc+iFig;

%% Sacc location with curvature SineWave fit
% target location at 100ms before saccade onset
Xlim1 = -pi;
Xlim2 = pi;
XGN = 16;

Ylim1 = -pi/4;
Ylim2 = pi/4;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_SacLoc_Sine';
TiteName{1} = 'Saccade Onset, SineFit';

iCondI = 0;
figure(iFig + iFigAcc)
set(gcf,'Position',[1,129,1061,848]);
tiledlayout(2,4,"TileSpacing","compact");
for iCond = CondI
    iCondI = iCondI+1;
    nexttile
    hold on
    XGroup = linspace(Xlim1, Xlim2, XGN);
    YGroup1 = [];
    YG_ave1 = [];
    YG_med1 = [];
    YG_std1 = [];
    XG_med1 = [];
    FitX = [];
    FitY = [];
    for iSubJ = 1:SubjN-1
        datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] == iSubJ);
        SacEndLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            SacEndLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacLocGoc2{1}(4,end));
        end
        ProcX = []; ProcY = [];
        ProcX = SacEndLocAng;
        ProcY = sbd.SacCurPara1(datas);

        % add mean value + errorBar, line figure
        for iXG1 = 1:length(XGroup)-1
            YGroup1{iSubJ,iXG1} = ProcY(ProcX>=XGroup(iXG1) & ProcX<=XGroup(iXG1+1));
            YG_ave1(iSubJ,iXG1) = mean(YGroup1{iSubJ,iXG1});
            YG_med1(iSubJ,iXG1) = median(YGroup1{iSubJ,iXG1});
            YG_std1(iSubJ,iXG1) = std(YGroup1{iSubJ,iXG1});
            XG_med1(iSubJ,iXG1) = mean([XGroup(iXG1),XGroup(iXG1+1)]);
        end

        fill([XG_med1(iSubJ,:),fliplr(XG_med1(iSubJ,:))],[YG_ave1(iSubJ,:)-YG_std1(iSubJ,:),...
            fliplr(YG_ave1(iSubJ,:)+YG_std1(iSubJ,:))],colorRGB1(iCondI,:),'EdgeColor','none','FaceAlpha',0.4);

        % clear nan
        nanIndices = isnan(YG_ave1(iSubJ,:));
        YG_ave1 = YG_ave1(iSubJ,:);
        XG_med1 = XG_med1(iSubJ,:);
        YG_ave1(nanIndices) = [];
        XG_med1(nanIndices) = [];
        % fit the sin wave
        SinCurPara1 = sineFit(XG_med1,YG_ave1,0);
        FitX{iSubJ} = XG_med1;
        FitY{iSubJ} = SinCurPara1(1) + SinCurPara1(2) * sin(2*pi*SinCurPara1(3)*FitX{iSubJ}...
            +SinCurPara1(4))+SinCurPara1(5);
    end

    % Fit the sin wave
    for iSubJ = 1:SubjN-1
        p{iSubJ} = plot(FitX{iSubJ},FitY{iSubJ},'Color',colorRGB2(iCondI,:),'LineWidth',2);
        if iSubJ == 1
            p{iSubJ}.LineStyle = '--';
        elseif iSubJ ==2
            p{iSubJ}.LineStyle = '-';
            p{iSubJ}.LineWidth = 2.5;
        elseif iSubJ ==3
            p{iSubJ}.LineStyle = '-.';
        end
    end
    % plot a horizontal stright line
    plot(Xlim1:Xlim2,zeros(size(Xlim1:Xlim2)),'--k','LineWidth',1.5)
    % plot some vertical stright lines
    % at zero, at pi/2, at -pi/2, at -pi, at pi
    % plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    % plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    % plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    % plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    % plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
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
        xlabel('Target Location')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
    sgtitle('Relation Between Curvature and Saccade Ending Theta','FontSize',15)
    % saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc+iFig;

%% Target location with curvature Mean value
% target location at 100ms before saccade onset
Xlim1 = -pi;
Xlim2 = pi;
XGN = 13;

Ylim1 = -pi/4;
Ylim2 = pi/4;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_SacLoc_Ave';

TiteName{1} = 'Saccade Onset';

    iCondI = 0;
    figure(iFig + iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    tiledlayout(2,4,"TileSpacing","compact");
    for iCond = CondI
        iCondI = iCondI+1;
        nexttile
        hold on
        % plot std first
        XGroup = linspace(Xlim1, Xlim2, XGN);
        YGroup1 = [];
        YG_ave1 = [];
        YG_med1 = [];
        YG_std1 = [];
        XG_med1 = [];
        for iSubJ = 1:SubjN-1           
            datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] == iSubJ);
            SacEndLocAng = [];
            iTrialI = 0;
            for iTrial = datas
                iTrialI = iTrialI+1;
                SacEndLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacLocGoc2{1}(4,end));
            end
            ProcX = []; ProcY = [];
            ProcX = SacEndLocAng;
            ProcY = sbd.SacCurPara1(datas);
            % plot the real dot point
            % scatter(ProcX,ProcY,20,colorRGB1(iCondI,:),'filled');

            % add mean value + errorBar, line figure
            
            for iXG1 = 1:length(XGroup)-1
                YGroup1{iSubJ,iXG1} = ProcY(ProcX>=XGroup(iXG1) & ProcX<=XGroup(iXG1+1));
                YG_ave1(iSubJ,iXG1) = mean(YGroup1{iSubJ,iXG1});
                YG_med1(iSubJ,iXG1) = median(YGroup1{iSubJ,iXG1});
                YG_std1(iSubJ,iXG1) = std(YGroup1{iSubJ,iXG1});
                XG_med1(iSubJ,iXG1) = mean([XGroup(iXG1),XGroup(iXG1+1)]);
            end

            fill([XG_med1(iSubJ,:),fliplr(XG_med1(iSubJ,:))],[YG_ave1(iSubJ,:)-YG_std1(iSubJ,:),...
                fliplr(YG_ave1(iSubJ,:)+YG_std1(iSubJ,:))],colorRGB1(iCondI,:),'EdgeColor','none','FaceAlpha',0.4);
        end
        
        % plot mean value
        for iSubJ = 1:SubjN-1           
            p{iSubJ} = plot(XG_med1(iSubJ,:),YG_ave1(iSubJ,:),'Color',colorRGB2(iCondI,:),'LineWidth',2);
            if iSubJ == 1
                p{iSubJ}.LineStyle = '--';
            elseif iSubJ ==2
                p{iSubJ}.LineStyle = '-';
                p{iSubJ}.LineWidth = 2.5;
            elseif iSubJ ==3
                p{iSubJ}.LineStyle = '-.';
            end
        end

        % plot a horizontal stright line
        plot(Xlim1:Xlim2,zeros(size(Xlim1:Xlim2)),'--k','LineWidth',1.5)
        % plot some vertical stright lines
        % at zero, at pi/2, at -pi/2, at -pi, at pi
        % plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
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
            xlabel('Target Location')
        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
        sgtitle('Relation Between Curvature and Saccade Ending Theta','FontSize',15)
        saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
    end
iFigAcc = iFigAcc+iFig;

%% Target location with Curvature size, all together in one plot
% target location at 100ms before saccade onset
Xlim1 = -pi;
Xlim2 = pi;
XGN = 13;

Ylim1 = -pi/4;
Ylim2 = pi/4;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_SacLoc_EachSubj';
SaveName{2} = '/SacCur_SacLocSacOff_EachSubj';

TiteName{1} = 'Saccade Onset, SineFit';
TiteName{2} = 'Saccade Offset, SineFit';

for iFig = 1:2
    figure(iFig + iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    tiledlayout(2,4,"TileSpacing","compact");
    for iCondG = 1:2
        CondItemp = [0,1,3,5;0,2,4,6];
    for iSubJ = 1:SubjN
        iCondI = 0;
        nexttile
        hold on
        XGroup = linspace(Xlim1, Xlim2, XGN);
        YGroup1 = [];
        YG_ave1 = [];
        YG_med1 = [];
        YG_std1 = [];
        XG_med1 = [];
        FitX = [];
        FitY = [];
        for iCond = CondItemp(iCondG,:)
            iCondI = iCondI+1;
            datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] == iSubJ);
            SacEndLocAng = [];
            iTrialI = 0;
            for iTrial = datas
                iTrialI = iTrialI+1;
                SacEndLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacLocGoc2{1}(4,end));
            end
            ProcX = []; ProcY = [];
            ProcX = SacEndLocAng;
            ProcY = sbd.SacCurPara1(datas);

            % add mean value + errorBar, line figure
            for iXG1 = 1:length(XGroup)-1
                YGroup1{iCondI,iXG1} = ProcY(ProcX>=XGroup(iXG1) & ProcX<=XGroup(iXG1+1));
                YG_ave1(iCondI,iXG1) = mean(YGroup1{iCondI,iXG1});
                YG_med1(iCondI,iXG1) = median(YGroup1{iCondI,iXG1});
                YG_std1(iCondI,iXG1) = std(YGroup1{iCondI,iXG1});
                XG_med1(iCondI,iXG1) = mean([XGroup(iXG1),XGroup(iXG1+1)]);
            end
           
            fill([XG_med1(iCondI,:),fliplr(XG_med1(iCondI,:))],[YG_ave1(iCondI,:)-YG_std1(iCondI,:),...
                fliplr(YG_ave1(iCondI,:)+YG_std1(iCondI,:))],colorRGB1(iCondI,:),'EdgeColor','none','FaceAlpha',0.4);

        end
        iCondI = 0;
        % Fit the sin wave
        for iCond = CondItemp(iCondG,:)
            iCondI = iCondI+1;           
            p{iCondI} = plot(XG_med1(iCondI,:),YG_ave1(iCondI,:),'Color',colorRGB2(iCondI,:),'LineWidth',2);
        end
        % plot a horizontal stright line
        plot(Xlim1:Xlim2,zeros(size(Xlim1:Xlim2)),'--k','LineWidth',1.5)
        % plot some vertical stright lines
        % at zero, at pi/2, at -pi/2, at -pi, at pi
        % plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
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
            xlabel('Target Location')
        end
        title(['Subject ', num2str(iSubJ)],'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
        sgtitle('Relation Between Curvature and Saccade Ending Theta','FontSize',15)
        saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
    end
    end
end
iFigAcc = iFigAcc+iFig;

%% Target location with Curvature signed size, all together in one plot
% target location at 100ms before saccade onset
Xlim1 = -pi;
Xlim2 = pi;
XGN = 13;

Ylim1 = -pi/4;
Ylim2 = pi/4;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur2Contl_SacLoc_EachSubj';
SaveName{2} = '/SacCur2Contl_SacLocSacOff_EachSubj';

TiteName{1} = 'Saccade Onset, SineFit';
TiteName{2} = 'Saccade Offset, SineFit';

for iFig = 1:2
    figure(iFig + iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    tiledlayout(2,4,"TileSpacing","compact");
    for iCondG = 1:2
        CondItemp = [0,1,3,5;0,2,4,6];
    for iSubJ = 1:SubjN
        iCondI = 0;
        nexttile
        hold on
        XGroup = linspace(Xlim1, Xlim2, XGN);
        YGroup1 = [];
        YG_ave1 = [];
        YG_med1 = [];
        YG_std1 = [];
        XG_med1 = [];
        FitX = [];
        FitY = [];
        for iCond = CondItemp(iCondG,:)
            iCondI = iCondI+1;
            datas = find([Dataf1.TarDir] == iCond & [Dataf1.SubjN] == iSubJ);
            SacEndLocAng = [];
            iTrialI = 0;
            for iTrial = datas
                iTrialI = iTrialI+1;
                SacEndLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacLocGoc2{1}(4,end));
            end
            ProcX = []; ProcY = [];
            ProcX = SacEndLocAng;
            ProcY = sbd.SacCurPara1(datas);

            % add mean value + errorBar, line figure
            for iXG1 = 1:length(XGroup)-1
                if iCondI == 1
                    YGroup1{iCondI,iXG1} = ProcY(ProcX>=XGroup(iXG1) & ProcX<=XGroup(iXG1+1));
                    YG_ave1(iCondI,iXG1) = mean(YGroup1{iCondI,iXG1});
                    YG_med1(iCondI,iXG1) = median(YGroup1{iCondI,iXG1});
                    YG_std1(iCondI,iXG1) = std(YGroup1{iCondI,iXG1});
                    XG_med1(iCondI,iXG1) = mean([XGroup(iXG1),XGroup(iXG1+1)]);
                else
                    YGroup1{iCondI,iXG1} = ProcY(ProcX>=XGroup(iXG1) & ProcX<=XGroup(iXG1+1));
                    YG_ave1(iCondI,iXG1) = mean(YGroup1{iCondI,iXG1})-YG_ave1(1,iXG1);
                    YG_med1(iCondI,iXG1) = median(YGroup1{iCondI,iXG1});
                    YG_std1(iCondI,iXG1) = std(YGroup1{iCondI,iXG1});
                    XG_med1(iCondI,iXG1) = mean([XGroup(iXG1),XGroup(iXG1+1)]);
                end
            end

        end
        iCondI = 1;
        % Fit the sin wave
        for iCond = CondItemp(iCondG,2:end)
            iCondI = iCondI+1;           
            p{iCondI} = plot(XG_med1(iCondI,:),YG_ave1(iCondI,:),'Color',colorRGB2(iCondI,:),'LineWidth',2);
        end
        % plot a horizontal stright line
        plot(Xlim1:Xlim2,zeros(size(Xlim1:Xlim2)),'--k','LineWidth',1.5)
        % plot some vertical stright lines
        % at zero, at pi/2, at -pi/2, at -pi, at pi
        % plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
        % plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
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
            xlabel('Target Location')
        end
        title(['Subject ', num2str(iSubJ)],'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
        sgtitle('Relation Between Curvature Difference 2 Control and Saccade Ending Theta','FontSize',15)
        saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
    end
    end
end
iFigAcc = iFigAcc+iFig;