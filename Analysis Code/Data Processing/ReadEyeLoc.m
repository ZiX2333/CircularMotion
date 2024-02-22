% This code is using for extract saccade data
% also can do some pre-analysis and plot some figures here
% Aug 09, 2023

% Because our eyelink data is recorded in 2k Hz, the first step is to
% transfer it into 1k Hz by averaging

% add more parameters calculation, also data structure transfer to circular

% Jan 01 2024, delete repeated part

% % Gaze_Coords
% GazeCoordX = 1920;
% GazeCoordY = 1080;

% load data and input
userID = 'EM01';
userDate = '100124';
SacTraFolder = 'SacTraFigNew';
DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/', userID, '/'];
FigDir = [DataDir, SacTraFolder];
mkdir(FigDir);
mkdir([FigDir,'/CW/']);
mkdir([FigDir,'/CCW/']);
mkdir([FigDir,'/Sta/']);

% basic settings
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

TarDir = {'Sta','CCW','CW','CCW','CW','CCW','CW'};
TarVel = {'0','15','-15','30','-30','45','-45'};

% Saccade para settings
TimeReso = 1/1000; % 1000hz
VelThrs = 15; %deg/sec
DurThrs = 10; % Saccade duration threshold 10ms

% try butter filt and then do a reverse and feedback filtering
order = 7;      % Filter order
Fs = 1000;      % Sample rate
Fc = 100;       % Cutoff frequency
[b, a] = butter(order, Fc / (Fs/2), 'low');

% % Design the Savitzky-Golay filter
% degree = 2; % Degree of polynomial
% window_size = 11; % Window size for Savitzky-Golay filter

for iTrial = 1:size(Dataf,2)
    EyeLocRX = [];
    EyeLocRY = [];
    EyeLocRRds = [];
    EyeLocRAng = [];
    EyeLocDisp = [];
    EyeLocDispAcc = [];
    % transfer from 2khz to 1khz
    % all the eye location should be
    if rem(length(Dataf(iTrial).EyeTime),2) == 0
        Dataf(iTrial).EyeRTime = 1:length(Dataf(iTrial).EyeTime)/2;
        % butterworth filting
        EyeLocRX = filtfilt(b,a,((Dataf(iTrial).EyeLocX(1:2:end) + Dataf(iTrial).EyeLocX(2:2:end))/2 ...
            - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1));
        EyeLocRY = filtfilt(b,a,((Dataf(iTrial).EyeLocY(1:2:end) + Dataf(iTrial).EyeLocY(2:2:end))/2 ...
            - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2));

        % % sgolayfilting
        % EyeLocRX1 = sgolayfilt(double(((Dataf(iTrial).EyeLocX(1:2:end) + Dataf(iTrial).EyeLocX(2:2:end))/2 ...
        %     - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1)), degree, window_size);
        % EyeLocRY1 = sgolayfilt(double(((Dataf(iTrial).EyeLocY(1:2:end) + Dataf(iTrial).EyeLocY(2:2:end))/2 ...
        %     - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2)), degree, window_size);
        %
        % EyeLocRX = filtfilt(EyeLocRX1, 1, double(((Dataf(iTrial).EyeLocX(1:2:end) + Dataf(iTrial).EyeLocX(2:2:end))/2 ...
        %     - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1)));
        % EyeLocRY = filtfilt(EyeLocRY1, 1, double(((Dataf(iTrial).EyeLocY(1:2:end) + Dataf(iTrial).EyeLocY(2:2:end))/2 ...
        %     - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2)));

    elseif rem(length(Dataf(iTrial).EyeTime),2) == 1
        % it should be even number. if not, there must be something strange
        % happen during
        Dataf(iTrial).TrialStatus = 0;
        Dataf(iTrial).EyeRTime = 1:(length(Dataf(iTrial).EyeTime)-1)/2;

        % butterworth filting
        EyeLocRX = filtfilt(b,a,((Dataf(iTrial).EyeLocX(1:2:end-1) + Dataf(iTrial).EyeLocX(2:2:end-1))/2 ...
            - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1));
        EyeLocRY = filtfilt(b,a,((Dataf(iTrial).EyeLocY(1:2:end-1) + Dataf(iTrial).EyeLocY(2:2:end-1))/2 ...
            - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2));

        % % sgolayfilting
        % EyeLocRX1 = sgolayfilt(double(((Dataf(iTrial).EyeLocX(1:2:end-1) + Dataf(iTrial).EyeLocX(2:2:end-1))/2 ...
        %     - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1)), degree, window_size);
        % EyeLocRY1 = sgolayfilt(double(((Dataf(iTrial).EyeLocY(1:2:end-1) + Dataf(iTrial).EyeLocY(2:2:end-1))/2 ...
        %     - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2)), degree, window_size);
        %
        % EyeLocRX = filtfilt(EyeLocRX1, 1, double(((Dataf(iTrial).EyeLocX(1:2:end-1) + Dataf(iTrial).EyeLocX(2:2:end-1))/2 ...
        %     - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1)));
        % EyeLocRY = filtfilt(EyeLocRY1, 1, double(((Dataf(iTrial).EyeLocY(1:2:end-1) + Dataf(iTrial).EyeLocY(2:2:end-1))/2 ...
        %     - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2)));
    end

    % adjust the size by minus the Gaze_Coords location
    % EyeLocXR = Eye location X Relative to the center of the screen and transfer
    % to degree
    % Dataf(iTrial).EyeLocRX = (Dataf(iTrial).EyeLocX - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1);
    % Dataf(iTrial).EyeLocRY = (Dataf(iTrial).EyeLocY - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2);
    % EyeLocRRds = sqrt(EyeLocRX.^2 + EyeLocRY.^2);
    % EyeLocRAng = atan2(EyeLocRY, EyeLocRX);
    [EyeLocRAng, EyeLocRRds] = cart2pol(EyeLocRX,EyeLocRY); % cart2pol is actually using the same way to calcu
    EyeLocDisp = [0, sqrt((EyeLocRX(2:end) - EyeLocRX(1:end-1)).^2 + (EyeLocRY(2:end) - EyeLocRY(1:end-1)).^2)];
    EyeLocDispAcc = cumsum(EyeLocDisp);

    % X, Y, Radius, Theta, Displacement, Accumulate Displacement
    Dataf(iTrial).EyeLocR = [EyeLocRX;EyeLocRY;EyeLocRRds;EyeLocRAng;EyeLocDisp;EyeLocDispAcc];

    % Calculate Saccade Velocity
    EyeLocVelRX = zeros(size(EyeLocRX));
    EyeLocVelRY = zeros(size(EyeLocRY));
    EyeLocVelRRds = zeros(size(EyeLocRRds));
    EyeLocVelRAng = zeros(size(EyeLocRAng));
    EyeLocVelDisp = zeros(size(EyeLocDisp));
    EyeLocVelDispAcc = zeros(size(EyeLocDispAcc));
    for iTime = 3:(length(EyeLocVelRX)-2)
        EyeLocVelRX(iTime) = (EyeLocRX(iTime+2)-EyeLocRX(iTime-2)+EyeLocRX(iTime+1)-EyeLocRX(iTime-1))/6*1000;
        EyeLocVelRY(iTime) = (EyeLocRY(iTime+2)-EyeLocRY(iTime-2)+EyeLocRY(iTime+1)-EyeLocRY(iTime-1))/6*1000;
        EyeLocVelRRds(iTime) = (EyeLocRRds(iTime+2)-EyeLocRRds(iTime-2)+EyeLocRRds(iTime+1)-EyeLocRRds(iTime-1))/6*1000;
        EyeLocVelRAng(iTime) = (EyeLocRAng(iTime+2)-EyeLocRAng(iTime-2)+EyeLocRAng(iTime+1)-EyeLocRAng(iTime-1))/6*1000;
        EyeLocVelDisp(iTime) = (EyeLocDisp(iTime+2)-EyeLocDisp(iTime-2)+EyeLocDisp(iTime+1)-EyeLocDisp(iTime-1))/6*1000;
        EyeLocVelDispAcc(iTime) = (EyeLocDispAcc(iTime+2)-EyeLocDispAcc(iTime-2)+EyeLocDispAcc(iTime+1)-EyeLocDispAcc(iTime-1))/6*1000;
    end

    % X, Y, Radius velocity
    Dataf(iTrial).EyeLocRVel = [EyeLocVelRX;EyeLocVelRY;EyeLocVelRRds;EyeLocVelRAng;EyeLocVelDisp;EyeLocVelDispAcc];

    % Mark the EyeLocVel by 15deg/sec
    Dataf(iTrial).EyeLocRVelM = zeros(size(Dataf(iTrial).EyeLocRVel));
    for iType = 1:size(Dataf(iTrial).EyeLocRVel,1)
        for iTime = 1:size(Dataf(iTrial).EyeLocRVel,2)
            if abs(Dataf(iTrial).EyeLocRVel(iType,iTime)) >= VelThrs
                Dataf(iTrial).EyeLocRVelM(iType,iTime) = 1;
            end
        end
    end

    % Calculate Saccade Accelerate
    EyeLocAccRX = zeros(size(EyeLocRX));
    EyeLocAccRY = zeros(size(EyeLocRY));
    EyeLocAccRRds = zeros(size(EyeLocRRds));
    EyeLocAccRAng = zeros(size(EyeLocRAng));
    EyeLocAccDisp = zeros(size(EyeLocDisp));
    EyeLocAccDispAcc = zeros(size(EyeLocDispAcc));
    TimeAll = length(EyeLocRX);
    EyeLocAccRX(2:TimeAll) = diff(EyeLocVelRX);
    EyeLocAccRY(2:TimeAll) = diff(EyeLocVelRY);
    EyeLocAccRRds(2:TimeAll) = diff(EyeLocVelRRds);
    EyeLocAccRAng(2:TimeAll) = diff(EyeLocVelRAng);
    EyeLocAccDisp(2:TimeAll) = diff(EyeLocVelDisp);
    EyeLocAccDispAcc(2:TimeAll) = diff(EyeLocVelDispAcc);
    Dataf(iTrial).EyeLocRAcc = [EyeLocAccRX;EyeLocAccRY;EyeLocAccRRds;EyeLocAccRAng;EyeLocAccDisp;EyeLocAccDispAcc];

    % Data file relative to fixation, fixation and gocue onset and saccade onset (assign some space)
    % X, Y, Radius, Theta, Displacement, Accumulate Displacement, Vel X,
    % Vel Y, Vel Radius, Mark Vel X, MV Y, MV Radius
    % define Time Window
    FixW = [-100,900]; FixT = Dataf(iTrial).TimeFixOn2;
    TarW = [-400,600]; TarT = Dataf(iTrial).TimeTarOn;
    GocW = [-500,500]; GocT = Dataf(iTrial).TimeGocOn;
    SacW = [-500,500];
    % GocW2E
    % GocW2E Start from gocue to the end of saccade

    if Dataf(iTrial).TrialStatus ~= 1 && Dataf(iTrial).TrialStatus ~= 5
        Dataf(iTrial).EyeLocRFix = nan;
        Dataf(iTrial).EyeLocRTar = nan;
        Dataf(iTrial).EyeLocRGoc = nan;
        Dataf(iTrial).EyeLocRSac = nan;
        Dataf(iTrial).EyeLocRGoc2E = nan;

        % change here later. 2khz
    elseif Dataf(iTrial).TrialStatus == 1
        % Relative to fixation start time: [-100ms,900ms]
        Dataf(iTrial).EyeLocRFix = [Dataf(iTrial).EyeLocR(:,FixT+FixW(1):FixT+FixW(2));...
            Dataf(iTrial).EyeLocRVel(:,FixT+FixW(1):FixT+FixW(2));...
            Dataf(iTrial).EyeLocRVelM(:,FixT+FixW(1):FixT+FixW(2));...
            Dataf(iTrial).EyeLocRAcc(:,FixT+FixW(1):FixT+FixW(2))];

        % Relative to Target Onset Time: [-400ms, 600ms]
        Dataf(iTrial).EyeLocRTar = [Dataf(iTrial).EyeLocR(:,TarT+TarW(1):TarT+TarW(2));...
            Dataf(iTrial).EyeLocRVel(:,TarT+TarW(1):TarT+TarW(2));...
            Dataf(iTrial).EyeLocRVelM(:,TarT+TarW(1):TarT+TarW(2));...
            Dataf(iTrial).EyeLocRAcc(:,TarT+TarW(1):TarT+TarW(2))];

        % Relative to Gocue Onset Time: [-500ms, 500ms]
        Dataf(iTrial).EyeLocRGoc = [Dataf(iTrial).EyeLocR(:,GocT+GocW(1):GocT+GocW(2));...
            Dataf(iTrial).EyeLocRVel(:,GocT+GocW(1):GocT+GocW(2));...
            Dataf(iTrial).EyeLocRVelM(:,GocT+GocW(1):GocT+GocW(2));...
            Dataf(iTrial).EyeLocRAcc(:,GocT+GocW(1):GocT+GocW(2))];

        % Relative to Saccade Onset Time: [-500ms, 500ms]
        Dataf(iTrial).EyeLocRSac = zeros(size(Dataf(iTrial).EyeLocRGoc));

        % Relative to Gocue Onset Time to the end of saccade: [-500ms, end]
        Dataf(iTrial).EyeLocRGoc2E = [Dataf(iTrial).EyeLocR(:,GocT+GocW(1):end);...
            Dataf(iTrial).EyeLocRVel(:,GocT+GocW(1):end);...
            Dataf(iTrial).EyeLocRVelM(:,GocT+GocW(1):end);...
            Dataf(iTrial).EyeLocRAcc(:,GocT+GocW(1):end)];

    elseif Dataf(iTrial).TrialStatus == 5
        Dataf(iTrial).EyeLocRFix = nan;
        Dataf(iTrial).EyeLocRTar = nan;
        Dataf(iTrial).EyeLocRGoc = nan;
        Dataf(iTrial).EyeLocRSac = nan;
        % Relative to Gocue Onset Time to the end of saccade: [-500ms, end]
        Dataf(iTrial).EyeLocRGoc2E = [Dataf(iTrial).EyeLocR(:,GocT+GocW(1):end);...
            Dataf(iTrial).EyeLocRVel(:,GocT+GocW(1):end);...
            Dataf(iTrial).EyeLocRVelM(:,GocT+GocW(1):end);...
            Dataf(iTrial).EyeLocRAcc(:,GocT+GocW(1):end)];
    end

    % Detect Saccade
    for iType = 1:size(Dataf(iTrial).EyeLocRVel,1)
        TimeS1 = [];
        TimeE1 = [];
        TimeDur = [];
        PeakV = []; % Peak velocity value
        TimePV = []; % time at peak velocity
        [TimeS1,TimeE1,TimeDur,PeakV,TimePV] = SaccDetect(Dataf(iTrial).EyeLocRVel(iType,:), Dataf(iTrial).EyeLocRVelM(iType,:), DurThrs);
        % a sequence of saccade start time, end time, duration, Peak
        % Velocity
        % X, Y, Radius
        Dataf(iTrial).SaccSeqInfo{iType} = [TimeS1;TimeE1;TimeDur;PeakV;TimePV];
    end
end

%% extract Saccades: only cares about saccade after gocue
% using radius to detect
% 1 X, 2 Y, 3 Radius, 4 And, 5 Disp, 6 Acc Disp
iColm = 3; % find Acc Disp
for iTrial = 1:size(Dataf,2)
    % The way to use find:
    % find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(2),1,'first')

    % find the saccades before gocue
    % SaccTemp = [];
    % SaccTemp = Dataf(iTrial).SaccSeqInfo{3};
    % do not include peak velocity in time
    % Start time, End time, Duration, Reaction Time
    WhichC = find(Dataf(iTrial).SaccSeqInfo{iColm}(1,:)>=Dataf(iTrial).TimeGocOn,1,"first");
    if WhichC == 1 % no saccade before gocue
        Dataf(iTrial).SacTimeGoc1 = [];
        Dataf(iTrial).SacLocGoc1 = [];
        Dataf(iTrial).SacPvelGoc1 = [];
    else
        for iCols = 1:size(Dataf(iTrial).SaccSeqInfo{iColm},1)-2
            Dataf(iTrial).SacTimeGoc1(iCols,:) = Dataf(iTrial).SaccSeqInfo{iColm}(iCols,1:WhichC-1);
        end
        % Reaction Time: Start time - Gocue TIme
        Dataf(iTrial).SacTimeGoc1(iCols+1,:) = Dataf(iTrial).SaccSeqInfo{iColm}(1,1:WhichC-1)-Dataf(iTrial).TimeGocOn;

        % 11 12 X start and end location, 21 22 Y Start and End location, 31 32 XY Start and end
        % location, Theta Start and end, Displacement Start and end, Acc Disp
        % Start and End
        % instead of finding start and end, finding the whole traces
        for iSacc = 1:WhichC-1
            Dataf(iTrial).SacLocGoc1{iSacc} = [Dataf(iTrial).EyeLocR(:, Dataf(iTrial).SacTimeGoc1(1,iSacc): Dataf(iTrial).SacTimeGoc1(2,iSacc));...
                Dataf(iTrial).EyeLocRVel(:, Dataf(iTrial).SacTimeGoc1(1,iSacc): Dataf(iTrial).SacTimeGoc1(2,iSacc));...
                Dataf(iTrial).EyeLocRAcc(:, Dataf(iTrial).SacTimeGoc1(1,iSacc): Dataf(iTrial).SacTimeGoc1(2,iSacc))];
        end
        % find the peak velocity
        Dataf(iTrial).SacPvelGoc1(1:2,:) = Dataf(iTrial).SaccSeqInfo{iColm}(end-1:end,1:WhichC-1);
    end

    % find the saccades after gocue
    % SaccTemp = [];
    % SaccTemp = Dataf(iTrial).SaccSeqInfo{3};
    % do not include peak velocity in time
    % Start time, End time, Duration, Reaction Time
    for iCols = 1:size(Dataf(iTrial).SaccSeqInfo{iColm},1)-2
        Dataf(iTrial).SacTimeGoc2(iCols,:) = Dataf(iTrial).SaccSeqInfo{iColm}(iCols,WhichC:end);
    end
    % Reaction Time: Start time - Gocue TIme
    Dataf(iTrial).SacTimeGoc2(iCols+1,:) = Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC:end)-Dataf(iTrial).TimeGocOn;

    % 11 12 X start and end location, 21 22 Y Start and End location, 31 32 XY Start and end
    % location, Theta Start and end, Displacement Start and end, Acc Disp
    % Start and End
    for iSacc = 1:size(Dataf(iTrial).SacTimeGoc2,2)
        Dataf(iTrial).SacLocGoc2{iSacc} = [Dataf(iTrial).EyeLocR(:, Dataf(iTrial).SacTimeGoc2(1,iSacc): Dataf(iTrial).SacTimeGoc2(2,iSacc));...
            Dataf(iTrial).EyeLocRVel(:, Dataf(iTrial).SacTimeGoc2(1,iSacc): Dataf(iTrial).SacTimeGoc2(2,iSacc));...
            Dataf(iTrial).EyeLocRAcc(:, Dataf(iTrial).SacTimeGoc2(1,iSacc): Dataf(iTrial).SacTimeGoc2(2,iSacc))];
    end
    % find the peak velocity
    Dataf(iTrial).SacPvelGoc2(1:2,:) = Dataf(iTrial).SaccSeqInfo{iColm}(end-1:end,WhichC:end);
end

%% Check if saccade correctly detected
GocC = find(GocW(1):GocW(2) == 0);

for iTrial  = 351:size(Dataf,2)
    if Dataf(iTrial).TrialStatus ~= 1
        continue
    end
    if isempty(Dataf(iTrial).SacTimeGoc2)
        Dataf(iTrial).TrialStatus = 4;
        continue
    end
    figure(iTrial)
    set(gcf,'Position',[1,1,1380,865])
    p1 = []; p2 = []; p3 = [];
    EyeLoc = [];
    % find the first saccade after gocue
    TimeS1 = [];
    TimeE1 = [];
    EyeLoc = Dataf(iTrial).EyeLocRGoc2E;
    TimeS1 = Dataf(iTrial).SacTimeGoc2(1,1)-Dataf(iTrial).TimeGocOn+1;
    TimeE1 = Dataf(iTrial).SacTimeGoc2(2,1)-Dataf(iTrial).TimeGocOn+1;
    TimeV1 = Dataf(iTrial).SacPvelGoc2(2,1)-Dataf(iTrial).TimeGocOn+1;

    % find the second saccade after gocue (if exist)
    TimeS2 = [];
    TimeE2 = [];
    TimeV2 = [];
    if size(Dataf(iTrial).SacTimeGoc2,2) >1
        TimeS2 = Dataf(iTrial).SacTimeGoc2(1,2)-Dataf(iTrial).TimeGocOn+1;
        TimeE2 = Dataf(iTrial).SacTimeGoc2(2,2)-Dataf(iTrial).TimeGocOn+1;
        TimeV2 = Dataf(iTrial).SacPvelGoc2(2,2)-Dataf(iTrial).TimeGocOn+1;
    end
    TarTime = double(Dataf(iTrial).TarPathXReal(2,:))-Dataf(iTrial).TimeGocOn+1;
    TarLocX = (double(Dataf(iTrial).TarPathXReal(1,:))- Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1);
    TarLocY = (double(Dataf(iTrial).TarPathYReal(1,:))- Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2);
    % plot cartesian
    subplot(1,2,1)

    hold on
    % plot target lcoation
    p1_1 = plot(TarTime,TarLocX,'LineWidth',2,'LineStyle','-.','Color',colorRGB1(1,:));
    p2_1 = plot(TarTime,TarLocY,'LineWidth',2,'LineStyle','-.','Color',colorRGB1(4,:));

    % plot eye x location
    p1 = plot(GocW(1):length(EyeLoc(1,:))+GocW(1)-1,EyeLoc(1,:),'LineWidth',2,'Color',colorRGB(1,:));
    % plot y location
    p2 = plot(GocW(1):length(EyeLoc(2,:))+GocW(1)-1,EyeLoc(2,:),'LineWidth',2,'Color',colorRGB(4,:));
    % plot the velocity traces xy
    p3 = plot(GocW(1):length(EyeLoc(1,:))+GocW(1)-1,EyeLoc(9,:)/100,'LineWidth',2,'Color',colorRGB(3,:));
    % plot the velocity traces acc disp
    plot(GocW(1):length(EyeLoc(1,:))+GocW(1)-1,EyeLoc(12,:)/100,'LineWidth',2.5,'Color',colorRGB(3,:),'LineStyle','-.');


    % plot reference line
    plot([0,0],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],':k','LineWidth',1)
    % plot Start and end of first Saccade Location
    plot([TimeS1,TimeS1],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--k','LineWidth',1);
    plot([TimeE1,TimeE1],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--k','LineWidth',1);
    % mark the peak velocity point
    plot(TimeV1,EyeLoc(9,TimeV1-GocW(1))/100,'ko','MarkerSize',10);

    % plot Start and end of second Saccade Location if exist
    if ~isempty(TimeS2)
        plot([TimeS2,TimeS2],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--r','LineWidth',1);
        plot([TimeE2,TimeE2],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--r','LineWidth',1);
        plot(TimeV2,EyeLoc(9,TimeV2-GocW(1))/100,'ro','MarkerSize',10);
    end


    xlabel('Time from Fixation Off, ms')
    ylabel('Saccade Amplitude, deg')

    xlim([GocW(1),length(EyeLoc(1,:))+GocW(1)-1]);
    ylim([-10,10]);

    legend([p1,p2,p3,p1_1,p2_1],{'Eye X','Eye Y','Eye Vel','Tar X','Tar Y'},"Box","off");
    set(gca,'FontSize',16);
    hold off

    % plot polar plot
    subplot(1,2,2)
    [TarAng, TarRho] = cart2pol(TarLocX,TarLocY);
    TarAngTemp = TarAng(TarTime>=TimeS1-100 & TarTime<=TimeE1);
    TarRhoTemp = TarRho(TarTime>=TimeS1-100 & TarTime<=TimeE1);

    p3 = polarplot(wrapToPi(EyeLoc(4,:)),EyeLoc(3,:),'LineWidth',2,'Color',[0.4660 0.6740 0.1880]);
    hold on
    polarplot(wrapToPi(TarAng(TarTime>=TimeS1-100)), TarRho(TarTime>=TimeS1-100),...
        'LineWidth',2,'Color','Black');

    % mark the saccade onset and offset point and peak velocity location
    polarplot(EyeLoc(4,TimeS1-GocW(1)),EyeLoc(3,TimeS1-GocW(1)),'kx', 'MarkerSize', 8,'LineWidth',1.5)
    polarplot(EyeLoc(4,TimeE1-GocW(1)),EyeLoc(3,TimeE1-GocW(1)),'kx', 'MarkerSize', 8,'LineWidth',1.5)
    polarplot(EyeLoc(4,TimeV1-GocW(1)),EyeLoc(3,TimeV1-GocW(1)),'ko', 'MarkerSize', 8,'LineWidth',1.5)

    % mark the second saccade onset and offset point and peak velocity location 
    if ~isempty(TimeS2)
        polarplot(EyeLoc(4,TimeS2-GocW(1)),EyeLoc(3,TimeS2-GocW(1)),'rx', 'MarkerSize', 8,'LineWidth',1.5)
        polarplot(EyeLoc(4,TimeE2-GocW(1)),EyeLoc(3,TimeE2-GocW(1)),'rx', 'MarkerSize', 8,'LineWidth',1.5)
        polarplot(EyeLoc(4,TimeV2-GocW(1)),EyeLoc(3,TimeV2-GocW(1)),'ro', 'MarkerSize', 8,'LineWidth',1.5)
    end

    if ~isempty(TarAngTemp)
        % mark the target location at saccade offset
        polarplot(TarAngTemp(end),TarRhoTemp(end),'k*', 'MarkerSize', 8,'LineWidth',1.5)
    end

    rlim([0,10]);
    legend(p3,'Rho','Location', 'Northoutside','Box', 'off');
    set(gca,'FontSize',16);
    hold off

    sgtitle(['Trial: ',num2str(iTrial),', Target Dir: ',TarDir{Dataf(iTrial).TarDir+1},', Velocity: ',TarVel{Dataf(iTrial).TarDir+1}],'FontSize',16);

    saveas(gcf,[FigDir,'/',TarDir{Dataf(iTrial).TarDir+1},'/ExampleEyeTrace',num2str(iTrial),'.fig'])
end

%
% %% plot example trials
% iTrial = 26;
% plot(1:length(Dataf(iTrial).EyeLoc1kXR),Dataf(iTrial).EyeLoc1kXR,'LineWidth',1);
% hold on
% plot(1:length(Dataf(iTrial).EyeLoc1kYR),Dataf(iTrial).EyeLoc1kYR,'LineWidth',1);
% plot(1:length(Dataf(iTrial).EyeLoc1kXYR),Dataf(iTrial).EyeLoc1kXYR,'LineWidth',1);
% plot(1:length(Dataf(iTrial).EyeLoc1kXYR),Dataf(iTrial).TarEcc*ones(size(Dataf(iTrial).EyeLoc1kXYR)),'k','LineWidth',0.5);
% plot([Dataf(iTrial).TimeGocOn,Dataf(iTrial).TimeGocOn],...
%     [min([min(Dataf(iTrial).EyeLoc1kYR),min(Dataf(iTrial).EyeLoc1kXR),min(Dataf(iTrial).EyeLoc1kXYR)])-2,10],'k','LineWidth',0.5)
% legend({'X','Y','XY','Target'},'Box','off')
% ylabel('Amplitude, degree')
% xlabel('Time from start recording, ms')
% ylim([min([min(Dataf(iTrial).EyeLoc1kYR),min(Dataf(iTrial).EyeLoc1kXR),min(Dataf(iTrial).EyeLoc1kXYR)])-2,10])
% title(['Eye traces for example trial: ',num2str(iTrial),', Target Dir: ',num2str(Dataf(iTrial).TarDir)])

%% save and clear all data
varSave = {'DataEdf','Dataf','Sti','FP','Pre_FP','screen'};
save([DataDir,userID,'_',userDate,'_PreProcessed4.mat'],varSave{:});
clearvars -except DataEdf Dataf Sti FP Pre_FP screen
%save('zx01_110823_PreProcessed2')
