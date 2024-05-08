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

%% Load Data
userID = 'EM01';
userDate = '100124';

%%
load([userID,'_',userDate,'_','PreProcessed3.mat'])

%% MKDIR and Condition choose

DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/',userID,'/'];
AnaData = 'Feb16';
ResultDir = [DataDir,'ResultFig/',AnaData,'/'];

LegText = [{'Stationary'},{'CCW 15'},{'CW 15'},{'CCW 30'},{'CW 30'},{'CCW 45'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';
CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondIComp1 = [0,1,3,5; 0,2,4,6]; % When I want to compare with stationary
CondIComp1Name = {'CCW','CW'};
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
    iniT = 15; % select first 10ms for the first saccade
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

thsDeg = 7;
thsRadian = deg2rad(thsDeg);

%% Saccade tilting representation 1 - number of saccade

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);
iFig = 1;

SaveName = [];
SaveName = '/SacKDE';

TiteName = [];
TiteName = 'SacKDE kernel: 0.1 rad, step: 1 deg';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = [];
    datas = find([Dataf1.TarDir] == iCond);
    EyeEndTta = zeros(size(datas));
    iTriali = 0;
    for iTrial = datas
        iTriali = iTriali+1;
        % EyeLocPol = [];
        % EyeLocPol = sbd.EyeLocMovPol{iTrial};
        EyeEndTta(iTriali) = wrapTo2Pi(mean(sbd.EyeLocMovPol{iTrial}(1,end-4:end))); % last 5 ms
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
iFigAcc = iFigAcc+iFig;

%% Saccade tilting representation 2 - Saccade curvature

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);
iFig = 1;

SaveName = [];
SaveName = '/SacCurDist';

TiteName = [];
TiteName = 'SacCurDist winRange: pi/6, step: pi/18';

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

thsCur = thsRadian;
thsCurNorm2 = abs(log(thsCur/max(abs(sbd.SacCurPara1))))/MaxCurTf;

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = [];
    datas = find([Dataf1.TarDir] == iCond);
    iTriali = 0;
    CurNorm2 = zeros(size(datas));
    EyeEndTta = zeros(size(datas));
    for iTrial = datas
        iTriali = iTriali+1;
        % SacCur(iTriali) = 1-abs(sbd.SacCurPara1(iTrial))/MaxCur(1);
        CurNorm2(iTriali) = CurTransf(iTrial)/MaxCurTf(1);
        EyeEndTta(iTriali) = wrapTo2Pi(mean(sbd.EyeLocMovPol{iTrial}(1,end-4:end)));
    end

    % Initialize vectors to hold the moving average results
    AveDir = [];
    AveRad = [];

    % Define the start and end points of the moving window
    for startAngle = 0:stepSize:(2*pi - winRange)
        endAngle = startAngle + winRange;

        % Find the indices of theta that fall within the current window
        winIndices = EyeEndTta >= startAngle & EyeEndTta < endAngle;
        winTheta = EyeEndTta(winIndices);
        winRadi = CurNorm2(winIndices);

        % Skip if no data points fall within the window range
        if isempty(winTheta)
            continue;
        end

        AveDir1 = [];
        AveRad1 = [];
        % Calculate mean direction for the window
        AveDir1 = circ_mean(winTheta');

        % Calculate mean vector length for the window
        AveRad1 = mean(winRadi);

        % Store the results
        AveDir = [AveDir AveDir1];
        AveRad = [AveRad AveRad1];
    end

    p1 = []; p2 = []; p3 = [];
    p1 = polarscatter(EyeEndTta,CurNorm2,30,'Marker','o','MarkerFaceColor',colorRGB1(iCondI,:),'MarkerEdgeColor','none');
    hold on
    p2 = polarplot([AveDir,AveDir(1)],[AveRad,AveRad(1)],'Color',colorRGB2(iCondI,:),'LineWidth',1.5);
    p3 = polarplot(linspace(0,2*pi,200),thsCurNorm2.*ones(1,200),'Color',colorRGB(iCondI,:),'LineWidth',0.7,'LineStyle','--');
    rlim([0,0.65])
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    hold off
end
sgtitle([TiteName, ' Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
iFigAcc = iFigAcc+iFig;

%% Raw rotate eye traces with remove too straight saccade
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1261 651]);
tiledlayout(2,4,"TileSpacing","compact");

SaveName = [];
SaveName = '/EyeTra_Rotated_Thrs';

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = find([Dataf1.TarDir] == iCond & abs(sbd.SacCurPara1)>=thsRadian);
    for iTrial = datas
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLocRtt = [];
        EyeLocRtt = sbd.EyeLocRttPol{iTrial};
        p1 = [];
        p1 = polarplot(EyeLocRtt(1,:),EyeLocRtt(2,:),'LineWidth',0.6,'Color',colorRGB(iCondI,:));
        hold on
    end
    % polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    % legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end

sgtitle(['Saccadic Eye Traces Rotated, Threshold ',num2str(thsDeg), 'deg, Subj ', userID],'FontSize',15)
saveas(gcf,[ResultDir,SaveName,'Subj_',userID,'.fig'])











