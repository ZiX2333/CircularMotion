% Data Processing
% This script is used for data processing
% Analysis based on prepro 4
% adjusted on Oct 12, exclude several figures and add some new figures
% Data Save in Result/ Oct12
% 

%% Load Data
% load('Raj01_120923_PreProcessed4.mat')

%% Condition choose
% LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
CondI = [0,2,4,6];
CondName = 'CW';

ifDoBasic = 1;

userID = 'zx07';
DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/',userID,'/'];
AnaData = 'Oct12';
ResultDir = [DataDir,'ResultFig/',AnaData,'/'];
if exist(ResultDir,'dir')~=7
    mkdir(ResultDir);
end

%% basic settings
if ifDoBasic
    mkdir(ResultDir);

    colorRGB = [0 0.4470 0.7410;... % blue
        0.9290 0.6940 0.1250; %yellow
        0.4660 0.6740 0.1880;... % green;
        0.8500 0.3250 0.0980;];% orange
    % light one
    colorRGB1 = [202, 218, 237;...
        248, 222, 126;... % 246, 219, 117
        206, 232, 195;...
        246, 210, 168]/255;
    % dark one
    colorRGB2 = [72, 128, 184;... %blue
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

%% Target location with Curvature signed size, all together in one plot
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -pi/4;
Ylim2 = pi/4;

SaveName{1} = '/SacCurComp_TarLocGocOn_';
SaveName{2} = '/SacCurComp_TarLocSacOnN100_';
SaveName{3} = '/SacCurComp_TarLocSacOn_';
SaveName{4} = '/SacCurComp_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

p = [];

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    % plot the error area first
    XGroup = [];
    YGroup = [];
    YG_ave = [];
    YG_med = [];
    YG_std = [];
    XG_med = [];
    XGroup = linspace(Xlim1, Xlim2, XGN);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        % subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacCurPara1(datas);
        % Relation with RT
        hold on
        % add mean value + errorBar, line figure
        for iXG = 1:length(XGroup)-1
            YGroup{i,iXG} = ProcY(ProcX>=XGroup(iXG) & ProcX<=XGroup(iXG+1));
            YG_ave(i,iXG) = mean(YGroup{i,iXG});
            YG_med(i,iXG) = median(YGroup{i,iXG});
            YG_std(i,iXG) = std(YGroup{i,iXG});
            XG_med(i,iXG) = mean([XGroup(iXG),XGroup(iXG+1)]);
        end
        % plot the mean value trace
        % plot(XG_med,YG_ave,1.5,colorRGB2(i,:),'LineStyle','-');
        % add the std fill
        fill([XG_med(i,:),fliplr(XG_med(i,:))],[YG_ave(i,:)-YG_std(i,:),...
            fliplr(YG_ave(i,:)+YG_std(i,:))],colorRGB1(i,:),'EdgeColor','none','FaceAlpha',0.4);
    end
    % plot the mean traces then
    i = 0;
    for iCond = CondI
        i = i+1;
        % plot the real dot point
        % scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
        % mark the mean velue point
        p{i} = plot(XG_med(i,:),YG_ave(i,:),'Marker','x','MarkerSize',10,'Color','k','LineWidth',2);
        if i == 1
            p{i}.LineStyle = '-';
        elseif i ==2
            p{i}.LineStyle = '--';
        elseif i ==3
            p{i}.LineStyle = '-.';
        elseif i ==4
            p{i}.LineStyle = ':';
        end
    end
    % plot a horizontal stright line
    plot([Xlim1,Xlim2],[0,0],'--k','LineWidth',1.5)
    % plot some vertical stright lines
    % at zero, at pi/2, at -pi/2, at -pi, at pi
    plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    hold off

    legend([p{1},p{2},p{3},p{4}],LegText(CondI+1),'Box','off');

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
    ylabel('Max Curvature Size, deg')
    xlabel('Target Location')

    % title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
    title(['Relation Between Saccade Curvature Absolute Size and Target Location at ',TiteName{iFig}],'FontSize',15)
    % saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with Initial Error
% centered at eye location
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -pi/4;
Ylim2 = pi/4;

SaveName{1} = '/SacCurComp_TarLocGocOn_';
SaveName{2} = '/SacCurComp_TarLocSacOnN100_';
SaveName{3} = '/SacCurComp_TarLocSacOn_';
SaveName{4} = '/SacCurComp_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

p = [];

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    % plot the error area first
    XGroup = [];
    YGroup = [];
    YG_ave = [];
    YG_med = [];
    YG_std = [];
    XG_med = [];
    XGroup = linspace(Xlim1, Xlim2, XGN);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        % subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacCurPara1(datas);
        % Relation with RT
        hold on
        % add mean value + errorBar, line figure
        for iXG = 1:length(XGroup)-1
            YGroup{i,iXG} = ProcY(ProcX>=XGroup(iXG) & ProcX<=XGroup(iXG+1));
            YG_ave(i,iXG) = mean(YGroup{i,iXG});
            YG_med(i,iXG) = median(YGroup{i,iXG});
            YG_std(i,iXG) = std(YGroup{i,iXG});
            XG_med(i,iXG) = mean([XGroup(iXG),XGroup(iXG+1)]);
        end
        % plot the mean value trace
        % plot(XG_med,YG_ave,1.5,colorRGB2(i,:),'LineStyle','-');
        % add the std fill
        fill([XG_med(i,:),fliplr(XG_med(i,:))],[YG_ave(i,:)-YG_std(i,:),...
            fliplr(YG_ave(i,:)+YG_std(i,:))],colorRGB1(i,:),'EdgeColor','none','FaceAlpha',0.4);
    end
    % plot the mean traces then
    i = 0;
    for iCond = CondI
        i = i+1;
        % plot the real dot point
        % scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
        % mark the mean velue point
        p{i} = plot(XG_med(i,:),YG_ave(i,:),'Marker','x','MarkerSize',10,'Color','k','LineWidth',2);
        if i == 1
            p{i}.LineStyle = '-';
        elseif i ==2
            p{i}.LineStyle = '--';
        elseif i ==3
            p{i}.LineStyle = '-.';
        elseif i ==4
            p{i}.LineStyle = ':';
        end
    end
    % plot a horizontal stright line
    plot([Xlim1,Xlim2],[0,0],'--k','LineWidth',1.5)
    % plot some vertical stright lines
    % at zero, at pi/2, at -pi/2, at -pi, at pi
    plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    hold off

    legend([p{1},p{2},p{3},p{4}],LegText(CondI+1),'Box','off');

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
    ylabel('Max Curvature Size, deg')
    xlabel('Target Location')

    % title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
    title(['Relation Between Saccade Curvature Absolute Size and Target Location at ',TiteName{iFig}],'FontSize',15)
    % saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with Ending Error (Tangental Error, eye location -  target location)
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -pi/4;
Ylim2 = pi/4;

SaveName{1} = '/SacCurComp_TarLocGocOn_';
SaveName{2} = '/SacCurComp_TarLocSacOnN100_';
SaveName{3} = '/SacCurComp_TarLocSacOn_';
SaveName{4} = '/SacCurComp_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

p = [];

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    % plot the error area first
    XGroup = [];
    YGroup = [];
    YG_ave = [];
    YG_med = [];
    YG_std = [];
    XG_med = [];
    XGroup = linspace(Xlim1, Xlim2, XGN);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        % subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacCurPara1(datas);
        % Relation with RT
        hold on
        % add mean value + errorBar, line figure
        for iXG = 1:length(XGroup)-1
            YGroup{i,iXG} = ProcY(ProcX>=XGroup(iXG) & ProcX<=XGroup(iXG+1));
            YG_ave(i,iXG) = mean(YGroup{i,iXG});
            YG_med(i,iXG) = median(YGroup{i,iXG});
            YG_std(i,iXG) = std(YGroup{i,iXG});
            XG_med(i,iXG) = mean([XGroup(iXG),XGroup(iXG+1)]);
        end
        % plot the mean value trace
        % plot(XG_med,YG_ave,1.5,colorRGB2(i,:),'LineStyle','-');
        % add the std fill
        fill([XG_med(i,:),fliplr(XG_med(i,:))],[YG_ave(i,:)-YG_std(i,:),...
            fliplr(YG_ave(i,:)+YG_std(i,:))],colorRGB1(i,:),'EdgeColor','none','FaceAlpha',0.4);
    end
    % plot the mean traces then
    i = 0;
    for iCond = CondI
        i = i+1;
        % plot the real dot point
        % scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
        % mark the mean velue point
        p{i} = plot(XG_med(i,:),YG_ave(i,:),'Marker','x','MarkerSize',10,'Color','k','LineWidth',2);
        if i == 1
            p{i}.LineStyle = '-';
        elseif i ==2
            p{i}.LineStyle = '--';
        elseif i ==3
            p{i}.LineStyle = '-.';
        elseif i ==4
            p{i}.LineStyle = ':';
        end
    end
    % plot a horizontal stright line
    plot([Xlim1,Xlim2],[0,0],'--k','LineWidth',1.5)
    % plot some vertical stright lines
    % at zero, at pi/2, at -pi/2, at -pi, at pi
    plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    hold off

    legend([p{1},p{2},p{3},p{4}],LegText(CondI+1),'Box','off');

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
    ylabel('Max Curvature Size, deg')
    xlabel('Target Location')

    % title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
    title(['Relation Between Saccade Curvature Absolute Size and Target Location at ',TiteName{iFig}],'FontSize',15)
    % saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with Ending Error (eye location -  target location)
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -pi/4;
Ylim2 = pi/4;

SaveName{1} = '/SacEndErrNoSign2_TarLocGocOn_';
SaveName{2} = '/SacEndErrNoSign2_TarLocSacOnN100_';
SaveName{3} = '/SacEndErrNoSign2_TarLocSacOn_';
SaveName{4} = '/SacEndErrNoSign2_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacEndErrAng2C(datas);
        % Relation with RT
        hold on
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
            ylabel('Saccade Ending Error, deg')
            xlabel('Target Location')

        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
    end
    sgtitle(['Relation Between Saccade Ending Error (from center) and Target Location at ',TiteName{iFig}],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with X Ending Error (eye location -  target location)
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -4;
Ylim2 = 4;

SaveName{1} = '/SacEndErrX_TarLocGocOn_';
SaveName{2} = '/SacEndErrX_TarLocSacOnN100_';
SaveName{3} = '/SacEndErrX_TarLocSacOn_';
SaveName{4} = '/SacEndErrX_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

for iFig = 1:4
    i = 0;
    figure(iFig + iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacEndErrX(datas);
        % Relation with RT
        hold on
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

        ylim([Ylim1,Ylim2])
        xlim([Xlim1,Xlim2])
        if iCond == 0
            ylabel('Saccade Horizontal Ending Error, deg')
            xlabel('Target Location')

        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
    end
    sgtitle(['Relation Between Saccade Horizontal Ending Error and Target Location at ',TiteName{iFig}],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with Y Ending Error (eye location -  target location)
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -4;
Ylim2 = 4;

SaveName{1} = '/SacEndErrY_TarLocGocOn_';
SaveName{2} = '/SacEndErrY_TarLocSacOnN100_';
SaveName{3} = '/SacEndErrY_TarLocSacOn_';
SaveName{4} = '/SacEndErrY_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacEndErrY(datas);
        % Relation with RT
        hold on
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

        ylim([Ylim1,Ylim2])
        xlim([Xlim1,Xlim2])
        if iCond == 0
            ylabel('Saccade Vertical Ending Error, deg')
            xlabel('Target Location')

        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
    end
    sgtitle(['Relation Between Saccade Vertical Ending Error and Target Location at ',TiteName{iFig}],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with Radial Ending Error (eye location -  target location)
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -5;
Ylim2 = 5;

SaveName{1} = '/SacEndErrRho_TarLocGocOn_';
SaveName{2} = '/SacEndErrRho_TarLocSacOnN100_';
SaveName{3} = '/SacEndErrRho_TarLocSacOn_';
SaveName{4} = '/SacEndErrRho_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacEndErrRhoSign1(datas);
        % Relation with RT
        hold on
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

        ylim([Ylim1,Ylim2])
        xlim([Xlim1,Xlim2])
        if iCond == 0
            ylabel('Saccade Horizontal Ending Error, deg')
            xlabel('Target Location')

        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
    end
    sgtitle(['Relation Between Saccade Radial Ending Error and Target Location at ',TiteName{iFig}],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with Amplitude (eye location -  target location)
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = 4;
Ylim2 = 10;

SaveName{1} = '/SacAmp_TarLocGocOn_';
SaveName{2} = '/SacAmp_TarLocSacOnN100_';
SaveName{3} = '/SacAmp_TarLocSacOn_';
SaveName{4} = '/SacAmp_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacAmpGoc1(datas);
        % Relation with RT
        hold on
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

        ylim([Ylim1,Ylim2])
        xlim([Xlim1,Xlim2])
        if iCond == 0
            ylabel('Saccade Horizontal Ending Error, deg')
            xlabel('Target Location')

        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
    end
    sgtitle(['Relation Between Saccade Amplitude and Target Location at ',TiteName{iFig}],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% RT + Delay with Ending Error to center
iFig = 1;
figure(iFig+iFigAcc)
set(gcf,'Position',[1,129,1061,848]);

Xlim1 = 100;
Xlim2 = 1600;
XGN = 10;

Ylim1 = -pi/4;
Ylim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas)+ [Dataf1(datas).DurDelay];
    ProcY = sbd.SacEndErrAng2CSign1(datas);
    % Relation with RT

    hold on
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
    YG_as1 = YG_ave-YG_std;
    YG_as2 = YG_ave+YG_std;
    % filter out nan value
    % XG_med = XG_med(~isnan(YG_as1));
    YG_as1 = YG_as1(~isnan(YG_ave-YG_std));
    YG_as2 = YG_as2(~isnan(YG_ave-YG_std));
    fill([XG_med(~isnan(YG_ave-YG_std)),fliplr(XG_med(~isnan(YG_ave-YG_std)))],...
        [YG_as1,fliplr(YG_as2)],colorRGB1(i,:),'EdgeColor','none');
    % plot the real dot point
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
    % mark the mean velue point
    plot(XG_med,YG_ave,'Marker','x','MarkerSize',10,'Color','k','LineWidth',2);

    hold off
    
    ylim([Ylim1,Ylim2])
    xlim([Xlim1,Xlim2])
    if iCond == 0
        ylabel('Saccade Ending Error, deg')
        xlabel('RT+Delay, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccade Angular Ending Error (from center) and RT+Delay','FontSize',15)
saveas(gcf,[ResultDir,'/SacEndError_RT+Delay_',CondName,'.fig'])
iFigAcc = iFigAcc + iFig;

%% Target location with Curvature signed size
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -1;
Ylim2 = 3;

SaveName{1} = '/SacCurSize_TarLocGocOn_';
SaveName{2} = '/SacCurSize_TarLocSacOnN100_';
SaveName{3} = '/SacCurSize_TarLocSacOn_';
SaveName{4} = '/SacCurSize_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacMaxCurSize(datas);
        % Relation with RT
        hold on
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

        ylim([Ylim1,Ylim2])
        xlim([Xlim1,Xlim2])
        if iCond == 0
            ylabel('Max Curvature Size, deg')
            xlabel('Target Location')

        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
    end
    sgtitle(['Relation Between Saccade Curvature Absolute Size and Target Location at ',TiteName{iFig}],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with Curvature signed size, all together in one plot
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = -1;
Ylim2 = 3;

SaveName{1} = '/SacCurSizeComp_TarLocGocOn_';
SaveName{2} = '/SacCurSizeComp_TarLocSacOnN100_';
SaveName{3} = '/SacCurSizeComp_TarLocSacOn_';
SaveName{4} = '/SacCurSizeComp_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

p = [];

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    % plot the error area first
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        % subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacMaxCurSize(datas);
        % Relation with RT
        hold on
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
        fill([XG_med,fliplr(XG_med)],[YG_ave-YG_std,fliplr(YG_ave+YG_std)],colorRGB1(i,:),'EdgeColor','none','FaceAlpha',0.4);
    end
    % plot the mean traces then
    i = 0;
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        % subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacMaxCurSize(datas);
        % Relation with RT
        hold on
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
        % plot the real dot point
        % scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
        % mark the mean velue point
        p{i} = plot(XG_med,YG_ave,'Marker','x','MarkerSize',10,'Color','k','LineWidth',2);
        if i == 1
            p{i}.LineStyle = '-';
        elseif i ==2
            p{i}.LineStyle = '--';
        elseif i ==3
            p{i}.LineStyle = '-.';
        elseif i ==4
            p{i}.LineStyle = ':';
        end
    end
    % plot a horizontal stright line
    plot([Xlim1,Xlim2],[0,0],'--k','LineWidth',1.5)
    % plot some vertical stright lines
    % at zero, at pi/2, at -pi/2, at -pi, at pi
    plot([0,0],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi/2,pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi/2,-pi/2],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([pi,pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    plot([-pi,-pi],[Ylim1,Ylim2],'--k','LineWidth',1.5)
    hold off

    legend([p{1},p{2},p{3},p{4}],LegText(CondI+1),'Box','off');

    xtickValues = Xlim1 :pi/5 :Xlim2;
    xticks(xtickValues);
    xtickLabels = arrayfun(@num2str, rad2deg(xtickValues), 'UniformOutput', false);
    xticklabels(xtickLabels);

    ylim([Ylim1,Ylim2])
    xlim([Xlim1,Xlim2])
    ylabel('Max Curvature Size, deg')
    xlabel('Target Location')

    % title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
    title(['Relation Between Saccade Curvature Absolute Size and Target Location at ',TiteName{iFig}],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% Target location with Max Cur Time
% centered at center point
Xlim1 = -pi;
Xlim2 = pi;
XGN = 12;

Ylim1 = 0;
Ylim2 = 100;

SaveName{1} = '/SacCurTime_TarLocGocOn_';
SaveName{2} = '/SacCurTime_TarLocSacOnN100_';
SaveName{3} = '/SacCurTime_TarLocSacOn_';
SaveName{4} = '/SacCurTime_TarLocSacOff_';

TiteName{1} = 'Gocue Onset';
TiteName{2} = '100ms before Saccade onset';
TiteName{3} = 'Saccade Onset';
TiteName{4} = 'Saccade Offset';

for iFig = 1:4
    i = 0;
    figure(iFig+iFigAcc)
    set(gcf,'Position',[1,129,1061,848]);
    for iCond = CondI
        i = i+1;
        datas = find([Dataf1.TarDir] == iCond);
        subplot(2,2,i)
        TarLocAng = [];
        iTrialI = 0;
        for iTrial = datas
            iTrialI = iTrialI+1;
            TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(iFig,3));
        end
        ProcX = TarLocAng;
        ProcY = sbd.SacMaxCurTime(datas);
        % Relation with RT
        hold on
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

        ylim([Ylim1,Ylim2])
        xlim([Xlim1,Xlim2])
        if iCond == 0
            ylabel('Saccade Horizontal Ending Error, deg')
            xlabel('Target Location')

        end
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        axis square
    end
    sgtitle(['Relation Between Saccade Max Curvature Time and Target Location at ',TiteName{iFig}],'FontSize',15)
    saveas(gcf,[ResultDir,SaveName{iFig},CondName,'.fig'])
end
iFigAcc = iFigAcc + iFig;

%% RT + Delay with Curvature Size
iFig = 1;
figure(iFig+iFigAcc)
set(gcf,'Position',[1,129,1061,848]);

Xlim1 = 100;
Xlim2 = 400;
XGN = 10;

Ylim1 = -1;
Ylim2 = 3;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacMaxCurSize(datas);
    % Relation with RT

    hold on
    % plot the real dot point
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
    % 
    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(i) = coefficients(1); % Slope
    InterceptB(i) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(i) = corr_matrix(1, 2); % r-value between x and y
    p_value(i) = p_matrix(1,2); 

    plot(Xlim1:Xlim2,[Xlim1:Xlim2]*SlopeK(i)+InterceptB(i),'--k','LineWidth',2);
    r_value_text = sprintf('r = %.4f', r_value(i));
    p_value_text = sprintf('p = %.4f', p_value(i));
    text(Xlim1+20, Ylim2-0.1, r_value_text, 'FontSize', 12);
    text(Xlim1+20, Ylim2-0.4, p_value_text, 'FontSize', 12);

    hold off
    
    ylim([Ylim1,Ylim2])
    xlim([Xlim1,Xlim2])
    if iCond == 0
        ylabel('Saccade Max Cur Size, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccade Max Cur Size and RT','FontSize',15)
saveas(gcf,[ResultDir,'/SacCurSize_RT_',CondName,'.fig'])
iFigAcc = iFigAcc + iFig;

iFig = 1;
figure(iFig+iFigAcc)
set(gcf,'Position',[1,129,1061,848]);

Xlim1 = 100;
Xlim2 = 1600;
XGN = 10;

Ylim1 = -1;
Ylim2 = 3;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas)+ [Dataf1(datas).DurDelay];
    ProcY = sbd.SacMaxCurSize(datas);
    % Relation with RT

    hold on
    % plot the real dot point
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    hold off
    
    ylim([Ylim1,Ylim2])
    xlim([Xlim1,Xlim2])
    if iCond == 0
        ylabel('Saccade Max Cur Size, deg')
        xlabel('RT+Delay, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccade Max Cur Size and RT + Delay','FontSize',15)
saveas(gcf,[ResultDir,'/SacCurSize_RT+Delay_',CondName,'.fig'])
iFigAcc = iFigAcc + iFig;

%% RT + Delay with Max Cur Time
iFig = 1;
figure(iFig+iFigAcc)
set(gcf,'Position',[1,129,1061,848]);

Xlim1 = 100;
Xlim2 = 400;
XGN = 10;

Ylim1 = 0;
Ylim2 = 100;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacMaxCurTime(datas);
    % Relation with RT

    hold on
    % plot the real dot point
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
    % 
    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(i) = coefficients(1); % Slope
    InterceptB(i) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(i) = corr_matrix(1, 2); % r-value between x and y
    p_value(i) = p_matrix(1,2); 

    plot(Xlim1:Xlim2,[Xlim1:Xlim2]*SlopeK(i)+InterceptB(i),'--k','LineWidth',2);
    r_value_text = sprintf('r = %.4f', r_value(i));
    p_value_text = sprintf('p = %.4f', p_value(i));
    text(Xlim1+20, Ylim2-10, r_value_text, 'FontSize', 12);
    text(Xlim1+20, Ylim2-20, p_value_text, 'FontSize', 12);

    hold off
    
    ylim([Ylim1,Ylim2])
    xlim([Xlim1,Xlim2])
    if iCond == 0
        ylabel('Saccade Max Cur Time, ms')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccade Max Cur Time and RT','FontSize',15)
saveas(gcf,[ResultDir,'/SacCurTime_RT_',CondName,'.fig'])
iFigAcc = iFigAcc + iFig;

iFig = 1;
figure(iFig+iFigAcc)
set(gcf,'Position',[1,129,1061,848]);

Xlim1 = 100;
Xlim2 = 1600;
XGN = 10;

Ylim1 = 0;
Ylim2 = 100;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas)+ [Dataf1(datas).DurDelay];
    ProcY = sbd.SacMaxCurTime(datas);
    % Relation with RT

    hold on
    % plot the real dot point
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    hold off
    
    ylim([Ylim1,Ylim2])
    xlim([Xlim1,Xlim2])
    if iCond == 0
        ylabel('Saccade Max Cur Time, ms')
        xlabel('RT+Delay, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccade Max Cur Time and RT + Delay','FontSize',15)
saveas(gcf,[ResultDir,'/SacCurTime_RT+Delay_',CondName,'.fig'])
iFigAcc = iFigAcc + iFig;