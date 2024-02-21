% Data Processing
% This script is used for data processing
% Analysis based on prepro 4
% adjusted on Oct 12, exclude several figures and add some new figures
% Data Save in Result/ Oct12
% Adjusted on Oct 28, add sinwave fit

%% Load Data
% load('Raj01_120923_PreProcessed4.mat')

%% Condition choose
LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';
CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondName = 'All';

ifDoBasic = 1;

userID = 'zx07';
DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/',userID,'/'];
AnaData = 'Oct28';
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

%% Target location with curvature SineWave fit
% target location at 100ms before saccade onset
Xlim1 = -pi;
Xlim2 = pi;
XGN = 20;

Ylim1 = -pi/4;
Ylim2 = pi/4;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_TarLocSacOn_';
SaveName{2} = '/SacCur_TarLocSacOff_';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

for iFig = 1:2
    i = 0;
    figure(iFig + iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    tiledlayout(2,4);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        nexttile
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig+2,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacCurPara1(datas);
        % Relation with RT
        hold on
        % plot the real dot point
        scatter(ProcX,ProcY,20,colorRGB1(i,:),'filled');

        % add mean value + errorBar, line figure
        XGroup = linspace(Xlim1, Xlim2, XGN);
        YGroup = [];
        YG_ave = [];
        YG_med = [];
        YG_std = [];
        XG_med = [];
        for iXG = 1:length(XGroup)-1
            YGroup{iXG} = ProcY(ProcX>=XGroup(iXG) & ProcX<=XGroup(iXG+1));
            YG_ave(iXG) = mean(YGroup{iXG});
            YG_med(iXG) = median(YGroup{iXG});
            YG_std(iXG) = std(YGroup{iXG});
            XG_med(iXG) = mean([XGroup(iXG),XGroup(iXG+1)]);
        end
        % fit the sin wave
        SinCurPara1{i} = sineFit(XG_med,YG_ave,0);
        FitX = XG_med;
        FitY = SinCurPara1{i}(1) + SinCurPara1{i}(2) * sin(2*pi*SinCurPara1{i}(3)*FitX...
            +SinCurPara1{i}(4))+SinCurPara1{i}(5);

        plot(FitX,FitY,'Color',colorRGB2(i,:),'LineWidth',1.5)

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

        xtickValues = Xlim1 :pi/5 :Xlim2;
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
    sgtitle(['Relation Between Curvature and Target Location at ',TiteName{iFig}],'FontSize',15)
    % saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc+iFig;

%% Target location with curvature SineWave fit
% target location at 100ms before saccade onset
Xlim1 = -pi;
Xlim2 = pi;
XGN = 18;

Ylim1 = -pi/4;
Ylim2 = pi/4;

% Only consider target location when saccade onset and offset
SaveName{1} = '/SacCur_TarLocSacOn_';
SaveName{2} = '/SacCur_TarLocSacOff_';

TiteName{1} = 'Saccade Onset';
TiteName{2} = 'Saccade Offset';

for iFig = 1:2
    i = 0;
    figure(iFig + iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    tiledlayout(2,4);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        nexttile
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig+2,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacCurPara1(datas);
        % Relation with RT
        hold on
        % plot the real dot point
        scatter(ProcX,ProcY,20,colorRGB1(i,:),'filled');

        % add mean value + errorBar, line figure
        XGroup = linspace(Xlim1, Xlim2, XGN);
        YGroup = [];
        YG_ave = [];
        YG_med = [];
        YG_std = [];
        XG_med = [];
        for iXG = 1:length(XGroup)-1
            YGroup{iXG} = ProcY(ProcX>=XGroup(iXG) & ProcX<=XGroup(iXG+1));
            YG_ave(iXG) = mean(YGroup{iXG});
            YG_med(iXG) = median(YGroup{iXG});
            YG_std(iXG) = std(YGroup{iXG});
            XG_med(iXG) = mean([XGroup(iXG),XGroup(iXG+1)]);
        end
        % plot the mean value trace
        % plot(XG_med,YG_ave,1.5,colorRGB2(i,:),'LineStyle','-');
        % add the std fill
        fill([XG_med,fliplr(XG_med)],[YG_ave-YG_std,fliplr(YG_ave+YG_std)],colorRGB1(i,:),'EdgeColor','none');
        % plot the real dot point
        scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
        % mark the mean velue point
        plot(XG_med,YG_ave,'Marker','x','MarkerSize',10,'Color','k','LineWidth',2);


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

        xtickValues = Xlim1 :pi/5 :Xlim2;
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
    sgtitle(['Relation Between Curvature and Target Location at ',TiteName{iFig}],'FontSize',15)
    % saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc+iFig;