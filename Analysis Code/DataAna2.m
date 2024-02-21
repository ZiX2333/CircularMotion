% Data Processing
% This script is used for data processing

%% Load Data
% load('Raj01_120923_PreProcessed4.mat')

%% Condition choose
% LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
CondI = [0,1,3,5]; % CCW
CondName = 'CCW';
% CondI = [0,2,4,6];
% CondName = 'CW';

ifDoBasic = 0;
userID = 'zx07';
%% basic settings
if ifDoBasic
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
        213, 95, 43]; %pink/orange

    % Legend setting
    LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];

    FixW = [-100,900];
    TarW = [-400,600];
    GocW = [-500,500];
    SacW = [-500,500];

    GocC = find(GocW(1):GocW(2) == 0);

    DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/',userID,'/'];
    AnaData = 'Sep28';
    ResultDir = [DataDir,'ResultFig/',AnaData,'/'];
    mkdir(ResultDir);

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

%% Saccade Main Sequence
figure(1)
set(gcf,'Position',[680,1,560,976]);
t = tiledlayout(3,1);
s1 = []; s2 = []; s3 = [];
iCondi = 0;
for iCond = CondI % 0: Stationary, 1 Counterclock wise, 2: clockwise
    iCondi = iCondi+1;
    h = [];
    datas = [];
    if iCond == 0
        datas = [Dataf1.TarDir] == iCond;
        [s1{iCondi},s2{iCondi},s3{iCondi},h] = sac_mainSeq(sbd.SacAmpGoc1(datas),sbd.SacPvelGoc1(datas),...
            sbd.SacDurGoc1(datas),sbd.SacRTGoc1(datas),colorRGB(iCondi,:),t,[]);
        haxes = t.Children;
        
    else
        datas = [Dataf1.TarDir] == iCond;
        [s1{iCondi},s2{iCondi},s3{iCondi},h] = sac_mainSeq(sbd.SacAmpGoc1(datas),sbd.SacPvelGoc1(datas),...
            sbd.SacDurGoc1(datas),sbd.SacRTGoc1(datas),colorRGB(iCondi,:),t,haxes);
    end
end

legend(haxes(2),LegText(CondI+1),"Box","off","FontSize",15,'Location','northeast');
saveas(gcf,[ResultDir,'/SacMainSeq_',CondName,'.fig'])

%% plot the target distribution at gocue
i = 0;
figure(2)
set(gcf,'Position',[1,129,1061,848]);
for iCond = CondI
    i = i+1;
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    TarLocAng = [];
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(1,3));
    end
    histogram(TarLocAng,'BinWidth',1,'EdgeColor','none','FaceColor',colorRGB(i,:))
    if iCond == 0
        xlabel('Target Location at Go cue')
        ylabel('Numbers')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
end
sgtitle('Target Location Distribution at Go Cue','FontSize',15)
saveas(gcf,[ResultDir,'/TarDist_',CondName,'.fig'])

%% plot the eye traces - don't align to 90 degree
i = 0;
figure(3)
set(gcf,'Position',[1,129,1061,848]);
for iCond = CondI
    i = i+1;
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    for iTrial = datas
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLoc = sbd.SacTraGoc1{iTrial};
        % TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        % TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
        % Polar Plot
        p1 = polarplot(EyeLoc(4,:),EyeLoc(3,:),'LineWidth',0.6,'Color',colorRGB(i,:));
        [TarLocTemp(1),TarLocTemp(2)] = cart2pol(Dataf1(iTrial).SacTarGoc1(end,1),Dataf1(iTrial).SacTarGoc1(end,2));
        s1 = polarscatter(TarLocTemp(1),TarLocTemp(2),5,'black','filled');
        hold on
    end
    % polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
sgtitle('Saccade Traces in 4 Velocities with Target Location at Saccade off','FontSize',15)
saveas(gcf,[ResultDir,'/EyeTra_TarSacOff_NoRotate_',CondName,'.fig'])

%% align to saccade offset and rotate to 90 degree
i = 0;
figure(4)
set(gcf,'Position',[1,129,1061,848]);
for iCond = CondI
    i = i+1;
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    for iTrial = datas
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLoc = sbd.SacTraGoc1{iTrial};
        % TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        % TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
        p1 = polarplot(EyeLoc(4,:)-Dataf1(iTrial).SacTarGoc1(end,3)+deg2rad(90),EyeLoc(3,:),'LineWidth',0.6,'Color',colorRGB(i,:));
        hold on
    end
    polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
sgtitle('Saccade Traces in 4 Velocities, Aligned to Saccade Offset','FontSize',15)
saveas(gcf,[ResultDir,'/EyeTra_TarSacOff_Rotate90_',CondName,'.fig'])


%% plot relation between ending error (Radius add relative location, left and right) and RT / RT+Delay
figure(5)
set(gcf,'Position',[1,129,1061,848]);
% RTlim1 = 100;
% RTlim2 = 1600;
RTlim1 = 100;
RTlim2 = 400;
% RTlim1 = 0;
% RTlim2 = 60;
Erlim1 = -5;
Erlim2 = 5;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    % ProcTime = sbd.SacRTGoc1(datas);
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacEndErrRhoSign1(datas);
    hold on
    % plot the relation between RT and ending error
    scatter(ProcX,ProcY,20,"filled",'o','CData',colorRGB(i,:));
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    
    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(i) = coefficients(1); % Slope
    InterceptB(i) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(i) = corr_matrix(1, 2); % r-value between x and y
    p_value(i) = p_matrix(1,2); 

    plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(i)+InterceptB(i),'--k','LineWidth',2);
    r_value_text = sprintf('r = %.4f', r_value(i));
    p_value_text = sprintf('p = %.4f', p_value(i));
    text(RTlim1+20, Erlim2-0.5, r_value_text, 'FontSize', 12);
    text(RTlim1+20, Erlim2-1, p_value_text, 'FontSize', 12);
    hold off

    if iCond == 0
        ylabel('Radial Distance to the Target, deg')
        xlabel('RT, ms')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Radial Distance lr) and Reaction Time','FontSize',15)
saveas(gcf,[ResultDir,'/SacEndErrRho_RT_',CondName,'.fig'])
%
figure(6)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 1600;
% RTlim1 = 100;
% RTlim2 = 400;
% RTlim1 = 0;
% RTlim2 = 60;
Erlim1 = -5;
Erlim2 = 5;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    % ProcTime = sbd.SacRTGoc1(datas);
    ProcX = sbd.SacRTGoc1(datas) + [Dataf1(datas).DurDelay];
    ProcY = sbd.SacEndErrRhoSign1(datas);
    % plot the relation between RT and ending error
    scatter(ProcX,ProcY,20,"filled",'o','CData',colorRGB(i,:));
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Radial Distance to the Target, deg')
        xlabel('RT + Delay, ms')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Radial Distance lr) and Delay (from Fixation onset to Offset)','FontSize',15)
saveas(gcf,[ResultDir,'/SacEndErrRho_RT+Delay_',CondName,'.fig'])

%% plot relation between ending error (Angular distance) and RT
figure(7)
set(gcf,'Position',[1,129,1061,848]);
% RTlim1 = 100;
% RTlim2 = 1600;
RTlim1 = 100;
RTlim2 = 400;
Erlim1 = -pi/6;
Erlim2 = pi/6;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacEndErrAng2CSign1(datas);
    hold on
    % plot the relation between RT and ending error
    scatter(ProcX,ProcY,20,"filled",'o','CData',colorRGB(i,:));
    
    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(i) = coefficients(1); % Slope
    InterceptB(i) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(i) = corr_matrix(1, 2); % r-value between x and y
    p_value(i) = p_matrix(1,2); 

    plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(i)+InterceptB(i),'--k','LineWidth',2);
    r_value_text = sprintf('r = %.4f', r_value(i));
    p_value_text = sprintf('p = %.4f', p_value(i));
    text(RTlim1+20, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+20, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])

    if iCond == 0
        ylabel('Angle between Sac End and Target, deg')
        xlabel('Reaction Time, ms')
    end
    subtitle(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Angular) and Reaction Time','FontSize',15)
saveas(gcf,[ResultDir,'/SacEndErrAng_RT_',CondName,'.fig'])

figure(8)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 1600;
% RTlim1 = 100;
% RTlim2 = 400;
% RTlim1 = 0;
% RTlim2 = 60;
Erlim1 = -pi/6;
Erlim2 = pi/6;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    % ProcTime = sbd.SacRTGoc1(datas);
    ProcX = sbd.SacRTGoc1(datas) + [Dataf1(datas).DurDelay];
    ProcY = sbd.SacEndErrAng2CSign1(datas);
    % plot the relation between RT and ending error
    scatter(ProcX,ProcY,20,"filled",'o','CData',colorRGB(i,:));
    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Angle between Sac End and Target, deg')
        xlabel('RT + Delay, ms')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Angular) and RT+Delay (from Fixation onset to Offset)','FontSize',15)
saveas(gcf,[ResultDir,'/SacEndErrAng_RT+Delay_',CondName,'.fig'])
% sgtitle('Relation Between Saccadic Ending Error (Radial Distance lr) and Delay (from Fixation onset to Offset)','FontSize',15)

%% Initial error with Time
figure(9)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 400;
Erlim1 = -pi/2;
Erlim2 = pi/2;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacIniErrAngTan(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+20, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+20, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccadic Initial Direction and Reaction Time','FontSize',15)
saveas(gcf,[ResultDir,'/SacIniErrTanAng_RT_',CondName,'.fig'])

figure(10)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 1600;
Erlim1 = -pi/2;
Erlim2 = pi/2;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    % ProcTime = sbd.SacRTGoc1(datas);
    ProcX = sbd.SacRTGoc1(datas) + [Dataf1(datas).DurDelay];
    ProcY = sbd.SacIniErrAngTan(datas);
    % plot the relation between RT and ending error
    scatter(ProcX,ProcY,20,"filled",'o','CData',colorRGB(i,:));
    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Angle between Sac End and Target, deg')
        xlabel('RT + Delay, ms')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Initial Direction and RT+Delay (from Fixation onset to Offset)','FontSize',15)
saveas(gcf,[ResultDir,'/SacIniErrTanAng_RT+Delay_',CondName,'.fig'])
% sgtitle('Relation Between Saccadic Initial Direction and Reaction Time + Delay (from Target onset to Gocue)','FontSize',15)

%% plot relation between ending error (Angular distance) and Following eye velocity
figure(11)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 400;
Erlim1 = -pi/2;
Erlim2 = pi/2;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacEndErrAngTan(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+20, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+20, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccadic Ending Direction and Reaction Time','FontSize',15)
saveas(gcf,[ResultDir,'/SacEndErrTanAng_RT_',CondName,'.fig'])

figure(12)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 1600;
Erlim1 = -pi/2;
Erlim2 = pi/2;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    % ProcTime = sbd.SacRTGoc1(datas);
    ProcX = sbd.SacRTGoc1(datas) + [Dataf1(datas).DurDelay];
    ProcY = sbd.SacEndErrAngTan(datas);
    % plot the relation between RT and ending error
    scatter(ProcX,ProcY,20,"filled",'o','CData',colorRGB(i,:));
    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Angle between Sac End and Target, deg')
        xlabel('RT + Delay, ms')
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Direction and RT+Delay (from Fixation onset to Offset)','FontSize',15)
saveas(gcf,[ResultDir,'/SacIniErrTanAng_RT+Delay_',CondName,'.fig'])

%% Plot the real target location and real eye location
% Target location: from gocue osnet to eye offset;
% Eyelocation: from gocue onset to eye offset?
figure(13)
set(gcf,'Position',[1,129,1061,848]);
i = 0;
for iCond = CondI
    i = i+1;
    datas = [];
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    
    % % Relation with RT
    % scatter(sbd.SacRTGoc1(datas),sbd.SacIniErrAngTan(datas),20,colorRGB(iCond+1,:),'filled');
    SacTimeTemp = [];
    SacAngTemp = [];
    p1 = [];
    p2 = [];
    hold on
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        SacTimeTemp = [SacTimeTemp,sbd.SacRTGoc1(iTrial)+sbd.SacDurGoc1(iTrial)];
        SacAngTemp = [SacAngTemp,wrapToPi(sbd.SacTraGoc1{iTrial}(4,end)-Dataf1(iTrial).SacTarGoc1(1,3))];
        scatter(SacTimeTemp(iTrialI),wrapToPi(SacAngTemp(iTrialI)),20,colorRGB(i,:),"filled",'o'); 
        scatter(SacTimeTemp(iTrialI),wrapToPi(Dataf1(iTrial).SacTarGoc1(end,3)-Dataf1(iTrial).SacTarGoc1(1,3)),...
            20,'black','*','LineWidth',1); 
    end
    

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    if iCond == 0
        p1 = plot([0,500],wrapToPi([0,500*0/1000]),'--k','LineWidth',1);
        % ylim([-pi/4,pi/4])
    else
        p1 = plot([0,500],wrapToPi([0,500*Dataf1(iTrial).TarSpeed/1000]),'--k','LineWidth',1);
        % ylim([0,pi/2])
    end

    % fit a linear model
    coefficients = polyfit(SacTimeTemp, SacAngTemp, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    % [corr_matrix,p_matrix] = corrcoef(SacTimeTemp, SacAngTemp);
    % r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    % p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(0:500,[0:500]*SlopeK(iCond+1)+InterceptB(iCond+1),'-.b','LineWidth',1);
    % r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    % p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    % % text(200+20, Erlim2-0.5, r_value_text, 'FontSize', 12);
    % text(200+20, Erlim2-1, p_value_text, 'FontSize', 12);

    if iCond == 0
        legend([p1,p2],{'Target Ang';'Eye Ang Fitted Line'},'Box','off','Location','southeast','FontSize',13)
    end

    hold off

    xlim([0,500])
    if CondI(2) == 1
        ylim([-pi/5,4*pi/3])
    elseif CondI(2) == 2
        ylim([-4*pi/3,pi/5])
    end
    if iCond == 0
        ylabel('Saccade and Target Ending Angle, deg')
    end
    if iCond == 1
        xlabel({'Time fron GoCue Onset, ms',LegText{iCond+1}})
    else
        xlabel(LegText{iCond+1})
    end
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Comparing Saccade Ending Angle and Target Angle at Saccade End','FontSize',15)
saveas(gcf,[ResultDir,'/SacEndAng_TarAng_',CondName,'.fig'])
% sgtitle('Relation Between Saccadic Initial Direction and Reaction Time + Delay (from Target onset to Gocue)','FontSize',15)

%% the following start with curvature analysis
% duration with curvature
figure(14)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 10;
RTlim2 = 100;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacDurGoc1(datas);
    ProcY = abs(sbd.SacCurPara1(datas));
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+10, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+10, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('Duration, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between abs Curvature and Duration','FontSize',15)
saveas(gcf,[ResultDir,'/SacCurAbs_Dur_',CondName,'.fig'])

% duration with curvature not abs
figure(15)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 10;
RTlim2 = 100;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacDurGoc1(datas);
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+10, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+10, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('Duration, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and Duration','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur1_Dur_',CondName,'.fig'])

% same figure as above but add 2 lines
figure(16)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 10;
RTlim2 = 100;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacDurGoc1(datas);
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % plot a stright line
    plot(RTlim1:RTlim2,zeros(size(RTlim1:RTlim2)),'--k','LineWidth',1.5)

    % fit two linear model
    coefficients = polyfit(ProcX(ProcY>=0), ProcY(ProcY>=0), 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX(ProcY>=0), ProcY(ProcY>=0));
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+10, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+10, Erlim2-0.2, p_value_text, 'FontSize', 12);

    coefficients = polyfit(ProcX(ProcY<0), ProcY(ProcY<0), 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX(ProcY<0), ProcY(ProcY<0));
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p3 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+10, Erlim1+0.2, r_value_text, 'FontSize', 12);
    text(RTlim1+10, Erlim1+0.1, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('Duration, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and Duration','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur2_Dur_',CondName,'.fig'])

%% Reaction time with Curvature
figure(17)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 400;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = abs(sbd.SacCurPara1(datas));
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+10, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+10, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between abs Curvature and Reaction Time','FontSize',15)
saveas(gcf,[ResultDir,'/SacCurAbs_RT_',CondName,'.fig'])

% duration with curvature not abs
figure(18)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 400;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+10, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+10, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and Reaction Time','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur1_RT_',CondName,'.fig'])

% same figure as above but add 2 lines
figure(19)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 400;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % plot a stright line
    plot(RTlim1:RTlim2,zeros(size(RTlim1:RTlim2)),'--k','LineWidth',1.5)
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and Reaction Time','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur2_RT_',CondName,'.fig'])

%% RT + delay with curvature
figure(20)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 1600;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas)+ [Dataf1(datas).DurDelay];
    ProcY = abs(sbd.SacCurPara1(datas));
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+10, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+10, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT+Delay, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between abs Curvature and RT+Delay','FontSize',15)
saveas(gcf,[ResultDir,'/SacCurAbs_RT+Delay_',CondName,'.fig'])

% same figure as above but add 2 lines
figure(21)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 1600;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas)+ [Dataf1(datas).DurDelay];
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % plot a stright line
    plot(RTlim1:RTlim2,zeros(size(RTlim1:RTlim2)),'--k','LineWidth',1.5)
    hold off

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT+Delay, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and RT+Delay','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur1_RT+Delay_',CondName,'.fig'])

%% Target location with curvature
% target location at 100ms before saccade onset
i = 0;
figure(22)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = -pi;
RTlim2 = pi;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    TarLocAng = [];
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(2,3)); % 100ms before saccade onset
    end
    ProcX = TarLocAng;
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
    % plot a stright line
    plot(RTlim1:RTlim2,zeros(size(RTlim1:RTlim2)),'--k','LineWidth',1.5)
    hold off

    ytickValues = -pi/2 :pi/10 :pi/2;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);

    xtickValues = RTlim1 :pi/5 :RTlim2;
    xticks(xtickValues);
    xtickLabels = arrayfun(@num2str, rad2deg(xtickValues), 'UniformOutput', false);
    xticklabels(xtickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and Target Location at 100ms before Saccade onset','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur_TarLocSacOnN100_',CondName,'.fig'])

% target location at saccade onset
i = 0;
figure(23)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = -pi;
RTlim2 = pi;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    TarLocAng = [];
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)); % 100ms before saccade onset
    end
    ProcX = TarLocAng;
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
    % plot a stright line
    plot(RTlim1:RTlim2,zeros(size(RTlim1:RTlim2)),'--k','LineWidth',1.5)
    hold off

    ytickValues = -pi/2 :pi/10 :pi/2;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);

    xtickValues = RTlim1 :pi/5 :RTlim2;
    xticks(xtickValues);
    xtickLabels = arrayfun(@num2str, rad2deg(xtickValues), 'UniformOutput', false);
    xticklabels(xtickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and Target Location at Saccade onset','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur_TarLocSacOn_',CondName,'.fig'])

% target location at saccade offset
i = 0;
figure(24)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = -pi;
RTlim2 = pi;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    TarLocAng = [];
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(end,3)); % 100ms before saccade onset
    end
    ProcX = TarLocAng;
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
    % plot a stright line
    plot(RTlim1:RTlim2,zeros(size(RTlim1:RTlim2)),'--k','LineWidth',1.5)
    hold off

    ytickValues = -pi/2 :pi/10 :pi/2;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);

    xtickValues = RTlim1 :pi/5 :RTlim2;
    xticks(xtickValues);
    xtickLabels = arrayfun(@num2str, rad2deg(xtickValues), 'UniformOutput', false);
    xticklabels(xtickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and Target Location at Saccade offset','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur_TarLocSacOff_',CondName,'.fig'])

% target location at gocue
i = 0;
figure(25)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = -pi;
RTlim2 = pi;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    TarLocAng = [];
    iTrialI = 0;
    for iTrial = datas
        iTrialI = iTrialI+1;
        TarLocAng(iTrialI) = wrapToPi(Dataf1(iTrial).SacTarGoc1(1,3)); % 100ms before saccade onset
    end
    ProcX = TarLocAng;
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');
    % plot a stright line
    plot(RTlim1:RTlim2,zeros(size(RTlim1:RTlim2)),'--k','LineWidth',1.5)
    hold off

    ytickValues = -pi/2 :pi/10 :pi/2;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);

    xtickValues = RTlim1 :pi/5 :RTlim2;
    xticks(xtickValues);
    xtickLabels = arrayfun(@num2str, rad2deg(xtickValues), 'UniformOutput', false);
    xticklabels(xtickLabels);
    
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Initial Direaction Difference with Target, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Curvature and Target Location at Go Cue','FontSize',15)
saveas(gcf,[ResultDir,'/SacCur_TarLocGoCue_',CondName,'.fig'])

%% Reaction Time with smoothpursuit velocity
figure(26)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 400;
% Erlim1 = 5;
% Erlim2 = 70;
i = 0;
for iCond = CondI
    i = i+1;
    if i ==1
        datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>0 & sbd.SmPVelGoc1<20;
        Erlim1 = 0;
        Erlim2 = 20;
    elseif i==2
        datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>10 & sbd.SmPVelGoc1<30;
        Erlim1 = 5;
        Erlim2 = 30;
    elseif i==3
        datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>15 & sbd.SmPVelGoc1<50;
        Erlim1 = 15;
        Erlim2 = 50;
    elseif i==4
        datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>20 & sbd.SmPVelGoc1<70;
        Erlim1 = 20;
        Erlim2 = 70;
    end
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SmPVelGoc1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % % fit a linear model
    % coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    % SlopeK(iCond+1) = coefficients(1); % Slope
    % InterceptB(iCond+1) = coefficients(2); % Intercept
    % 
    % [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    % r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    % p_value(iCond+1) = p_matrix(1,2); 
    % p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    % r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    % p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    % text(RTlim1+20, Erlim2-0.1, r_value_text, 'FontSize', 12);
    % text(RTlim1+20, Erlim2-0.2, p_value_text, 'FontSize', 12);
    % hold off
    % 
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Smooth Pursuit Velocity, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Smooth Pursuit Velocity and Reaction Time','FontSize',15)
saveas(gcf,[ResultDir,'/SacSmPVel_RT_',CondName,'.fig'])

%% Curvature with Smooth Pursuit Velocity
figure(27)
set(gcf,'Position',[1,129,1061,848]);
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    % datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>0 & sbd.SmPVelGoc1<100;
    if i ==1
        datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>0 & sbd.SmPVelGoc1<20;
        RTlim1 = 0;
        RTlim2 = 20;
    elseif i==2
        datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>10 & sbd.SmPVelGoc1<30;
        RTlim1 = 5;
        RTlim2 = 30;
    elseif i==3
        datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>15 & sbd.SmPVelGoc1<50;
        RTlim1 = 15;
        RTlim2 = 50;
    elseif i==4
        datas = [Dataf1.TarDir] == iCond & sbd.SmPVelGoc1>20 & sbd.SmPVelGoc1<70;
        RTlim1 = 20;
        RTlim2 = 70;
    end
    subplot(2,2,i)
    ProcX = sbd.SmPVelGoc1(datas);
    ProcY = sbd.SacCurPara1(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % fit a linear model
    coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+5, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+5, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off
    % 
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Saccade Curvature, deg')
        xlabel('Smooth PursuitVelocity, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccade Curvature and Smooth Pursuit Velocity','FontSize',15)
saveas(gcf,[ResultDir,'/SacSmPVel_Cur_',CondName,'.fig'])

%% Reaction Time with velocity Skewness
sbd.SacVelSkew = (sbd.SacPvelTmGoc1-sbd.SacSTmGoc1+1)./sbd.SacDurGoc1;
figure(28)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 100;
RTlim2 = 400;
Erlim1 = 0;
Erlim2 = 1;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcX = sbd.SacRTGoc1(datas);
    ProcY = sbd.SacVelSkew(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % % fit a linear model
    % coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    % SlopeK(iCond+1) = coefficients(1); % Slope
    % InterceptB(iCond+1) = coefficients(2); % Intercept
    % 
    % [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    % r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    % p_value(iCond+1) = p_matrix(1,2); 
    % p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    % r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    % p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    % text(RTlim1+20, Erlim2-0.1, r_value_text, 'FontSize', 12);
    % text(RTlim1+20, Erlim2-0.2, p_value_text, 'FontSize', 12);
    % hold off
    % 
    ylim([Erlim1,Erlim2])
    xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Velocity Skewness, deg')
        xlabel('RT, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Reaction Time and Velocity Skewness','FontSize',15)
saveas(gcf,[ResultDir,'/SacVelSkew_RT_',CondName,'.fig'])

%% Curvature with velocity Skewness
% sbd.SacVelSkew = (sbd.SacPvelTmGoc1-sbd.SacSTmGoc1+1)./sbd.SacDurGoc1;
figure(29)
set(gcf,'Position',[1,129,1061,848]);
RTlim1 = 0;
RTlim2 = 1;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = CondI
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    ProcY = sbd.SacCurPara1(datas);
    ProcX = sbd.SacVelSkew(datas);
    % Relation with RT
    hold on
    scatter(ProcX,ProcY,20,colorRGB(i,:),'filled');

    % % fit a linear model
    % coefficients = polyfit(ProcX, ProcY, 1); % 1 indicates linear model
    % SlopeK(iCond+1) = coefficients(1); % Slope
    % InterceptB(iCond+1) = coefficients(2); % Intercept
    % 
    % [corr_matrix,p_matrix] = corrcoef(ProcX, ProcY);
    % r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    % p_value(iCond+1) = p_matrix(1,2); 
    % p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    % r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    % p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    % text(RTlim1+20, Erlim2-0.1, r_value_text, 'FontSize', 12);
    % text(RTlim1+20, Erlim2-0.2, p_value_text, 'FontSize', 12);
    % hold off
    % 
    % ylim([Erlim1,Erlim2])
    % xlim([RTlim1,RTlim2])
    if iCond == 0
        ylabel('Curvature, deg')
        xlabel('Velocity Skewness, ms')

    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Velocity Skewness and Saccade Curvature','FontSize',15)
saveas(gcf,[ResultDir,'/SacVelSkew_Cur_',CondName,'.fig'])