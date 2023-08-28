% This code is using for extract saccade data
% also can do some pre-analysis and plot some figures here
% Aug 09, 2023

% Because our eyelink data is recorded in 2k Hz, the first step is to
% transfer it into 1k Hz by averaging

% % Gaze_Coords
% GazeCoordX = 1920;
% GazeCoordY = 1080;

% load data and input
userID = 'eve01';
userDate = '110823';
SacTraFolder = 'SacTraFig';
DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/', userID, '/'];
FigDir = [DataDir, SacTraFolder];
mkdir(FigDir);

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
    for iTime = 3:(length(EyeLocVelRX)-2)
        EyeLocVelRX(iTime) = (EyeLocRX(iTime+2)-EyeLocRX(iTime-2)+EyeLocRX(iTime+1)-EyeLocRX(iTime-1))/6*1000;
        EyeLocVelRY(iTime) = (EyeLocRY(iTime+2)-EyeLocRY(iTime-2)+EyeLocRY(iTime+1)-EyeLocRY(iTime-1))/6*1000;
        EyeLocVelRRds(iTime) = (EyeLocRRds(iTime+2)-EyeLocRRds(iTime-2)+EyeLocRRds(iTime+1)-EyeLocRRds(iTime-1))/6*1000;
    end

    % X, Y, Radius velocity
    Dataf(iTrial).EyeLocRVel = [EyeLocVelRX;EyeLocVelRY;EyeLocVelRRds];

    % Mark the EyeLocVel by 15deg/sec
    Dataf(iTrial).EyeLocRVelM = zeros(size(Dataf(iTrial).EyeLocRVel));
    for iType = 1:size(Dataf(iTrial).EyeLocRVel,1)
        for iTime = 1:size(Dataf(iTrial).EyeLocRVel,2)
            if abs(Dataf(iTrial).EyeLocRVel(iType,iTime)) >= VelThrs
                Dataf(iTrial).EyeLocRVelM(iType,iTime) = 1;
            end
        end
    end

    % Data file relative to fixation, fixation and gocue onset and saccade onset (assign some space)
    % X, Y, Radius, Theta, Displacement, Accumulate Displacement, Vel X,
    % Vel Y, Vel Radius, Mark Vel X, MV Y, MV Radius
    % define Time Window
    FixW = [-100,900]; FixT = Dataf(iTrial).TimeFixOn2;
    TarW = [-400,600]; TarT = Dataf(iTrial).TimeTarOn;
    GocW = [-500,500]; GocT = Dataf(iTrial).TimeGocOn;
    SacW = [-500,500];

    if Dataf(iTrial).TrialStatus ~= 1
        Dataf(iTrial).EyeLocRFix = nan;
        Dataf(iTrial).EyeLocRTar = nan;
        Dataf(iTrial).EyeLocRGoc = nan;
        Dataf(iTrial).EyeLocRSac = nan;

        % change here later. 2khz
    elseif Dataf(iTrial).TrialStatus == 1
        % Relative to fixation start time: [-100ms,900ms]
        Dataf(iTrial).EyeLocRFix = [Dataf(iTrial).EyeLocR(:,FixT+FixW(1):FixT+FixW(2));...
            Dataf(iTrial).EyeLocRVel(:,FixT+FixW(1):FixT+FixW(2));...
            Dataf(iTrial).EyeLocRVelM(:,FixT+FixW(1):FixT+FixW(2))];

        % Relative to Target Onset Time: [-400ms, 600ms]
        Dataf(iTrial).EyeLocRTar = [Dataf(iTrial).EyeLocR(:,TarT+TarW(1):TarT+TarW(2));...
            Dataf(iTrial).EyeLocRVel(:,TarT+TarW(1):TarT+TarW(2));...
            Dataf(iTrial).EyeLocRVelM(:,TarT+TarW(1):TarT+TarW(2))];

        % Relative to Gocue Onset Time: [-400ms, 600ms]
        Dataf(iTrial).EyeLocRGoc = [Dataf(iTrial).EyeLocR(:,GocT+GocW(1):GocT+GocW(2));...
            Dataf(iTrial).EyeLocRVel(:,GocT+GocW(1):GocT+GocW(2));...
            Dataf(iTrial).EyeLocRVelM(:,GocT+GocW(1):GocT+GocW(2))];

        % Relative to Saccade Onset Time: [-500ms, 500ms]
        Dataf(iTrial).EyeLocRSac = zeros(size(Dataf(iTrial).EyeLocRGoc));
    end

    % Detect Saccade
    for iType = 1:size(Dataf(iTrial).EyeLocRVel,1)
        TimeS = [];
        TimeE = [];
        TimeDur = [];
        TimePV = [];
        [TimeS,TimeE,TimeDur,TimePV] = SaccDetect(Dataf(iTrial).EyeLocRVel(iType,:), Dataf(iTrial).EyeLocRVelM(iType,:), DurThrs);
        % a sequence of saccade start time, end time, duration, Peak
        % Velocity
        % X, Y, Radius
        Dataf(iTrial).SaccSeqInfo{iType} = [TimeS;TimeE;TimeDur;TimePV];
    end
end

%% extract Saccades: only cares about the first saccade after go cue onset
% using radius to detect
% 1 X, 2 Y, 3 Radius
iColm = 3; % find Radius
for iTrial = 1:size(Dataf,2)
    % The way to use find:
    % find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(2),1,'first')

    % find the first saccade after gocue
    % SaccTemp = [];
    % SaccTemp = Dataf(iTrial).SaccSeqInfo{3};
    % do not include peak velocity in time
    % Start time, End time, Duration, Reaction Time
    WhichC = find(Dataf(iTrial).SaccSeqInfo{iColm}(1,:)>=Dataf(iTrial).TimeGocOn,1,"first");
    for iRows = 1:size(Dataf(iTrial).SaccSeqInfo{iColm},1)-1 
        Dataf(iTrial).SacTimeGoc1(:,iRows) = Dataf(iTrial).SaccSeqInfo{iColm}(iRows,WhichC);
    end
    % Reaction Time: Start time - Gocue TIme
    Dataf(iTrial).SacTimeGoc1(:,iRows+1) = Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC)-Dataf(iTrial).TimeGocOn;

    % 11 12 X start and end location, 21 22 Y Start and End location, 31 32 XY Start and end
    % location, Theta Start and end, Displacement Start and end, Acc Disp
    % Start and End
    for iType = 1:size(Dataf(iTrial).EyeLocR,1)
        Dataf(iTrial).SacLocGoc1(iType,:) = Dataf(iTrial).EyeLocR(iType, [Dataf(iTrial).SacTimeGoc1(:,1), Dataf(iTrial).SacTimeGoc1(:,2)]);
    end
    % find the peak velocity
    Dataf(iTrial).SacPvelGoc1 = Dataf(iTrial).SaccSeqInfo{iColm}(end,WhichC);
end

%% Check if saccade correctly detected
GocC = find(GocW(1):GocW(2) == 0);
for iTrial  = 1:size(Dataf,2)
    if Dataf(iTrial).TrialStatus ~= 1
        continue
    end
    figure(iTrial)
    set(gcf,'Position',[1,1,1380,865])
    p1 = []; p2 = []; p3 = [];
    EyeLoc = [];
    TimeS = [];
    TimeE = [];
    EyeLoc = Dataf(iTrial).EyeLocRGoc;
    TimeS = Dataf(iTrial).SacTimeGoc1(1)-Dataf(iTrial).TimeGocOn;
    TimeE = Dataf(iTrial).SacTimeGoc1(2)-Dataf(iTrial).TimeGocOn;
    % plot cartesian
    subplot(1,2,1)
    % plot x location
    p1 = plot(1:length(EyeLoc(1,:)),EyeLoc(1,:),'LineWidth',2);
    hold on
    % plot y location
    p2 = plot(1:length(EyeLoc(2,:)),EyeLoc(2,:),'LineWidth',2);
    % plot reference line
    plot([GocC,GocC],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],':k','LineWidth',1)
    % plot Start and end Saccade Location
    plot([TimeS+GocC,TimeS+GocC],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--k','LineWidth',1);
    plot([TimeE+GocC,TimeE+GocC],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--k','LineWidth',1);
    xlabel('Time from Fixation Off, ms')
    ylabel('Saccade Amplitude, deg')
    legend([p1,p2],{'X','Y'},"Box","off");
    set(gca,'FontSize',16);
    hold off
    
    % plot polar plot
    subplot(1,2,2)
    p3 = polarplot(EyeLoc(4,:),EyeLoc(3,:),'LineWidth',2,'Color',[0.4660 0.6740 0.1880]);
    hold on
    % mark the saccade onset and offset point
    polarplot(EyeLoc(4,TimeS+GocC),EyeLoc(3,TimeS+GocC),'rx', 'MarkerSize', 8,'LineWidth',1.5)
    polarplot(EyeLoc(4,TimeE+GocC),EyeLoc(3,TimeE+GocC),'rx', 'MarkerSize', 8,'LineWidth',1.5)
    legend(p3,'Rho','Location', 'Northoutside','Box', 'off');
    set(gca,'FontSize',16);
    hold off

    sgtitle(['Eye traces for example trial: ',num2str(iTrial),', Target Dir: ',num2str(Dataf(iTrial).TarDir)],'FontSize',16);

    saveas(gcf,[FigDir,'/ExampleEyeTrace',num2str(iTrial),'.fig'])
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
save([DataDir,userID,'_',userDate,'_PreProcessed2.mat'],varSave{:});
clearvars -except DataEdf Dataf Sti FP Pre_FP screen
%save('zx01_110823_PreProcessed2')

%% change individual trials
iTrial = 349;
iColm = 3; % find Radius
GocW = [-500,500];
GocC = find(GocW(1):GocW(2) == 0);
userID = 'zx01';
userDate = '110823';
SacTraFolder = 'SacTraFig';
DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/', userID, '/'];
FigDir = [DataDir, SacTraFolder];
% find the first saccade after gocue, this part is also used for change
% this saccade
% SaccTemp = [];
% SaccTemp = Dataf(iTrial).SaccSeqInfo{3};
% do not include peak velocity in time
% Start time, End time, Duration, Reaction Time
WhichC = find(Dataf(iTrial).SaccSeqInfo{iColm}(1,:)>=Dataf(iTrial).TimeGocOn,1,"first");

% % adjust the onset time
% num2adjust = 100;
% Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC) = num2adjust + Dataf(iTrial).TimeGocOn-GocC;
% % adjust the offset time
num2adjust = 807;
Dataf(iTrial).SaccSeqInfo{iColm}(2,WhichC) = num2adjust + Dataf(iTrial).TimeGocOn-GocC;

% ajust the duration and peakvelocity based on the adjustment
Dataf(iTrial).SaccSeqInfo{iColm}(3,WhichC) = Dataf(iTrial).SaccSeqInfo{iColm}(2,WhichC)-...
    Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC);
Dataf(iTrial).SaccSeqInfo{iColm}(4,WhichC) = max(Dataf(iTrial).EyeLocRVel...
    (iColm,Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC):Dataf(iTrial).SaccSeqInfo{iColm}(2,WhichC)));


% adjust the following
for iRows = 1:size(Dataf(iTrial).SaccSeqInfo{iColm},1)-1
    Dataf(iTrial).SacTimeGoc1(:,iRows) = Dataf(iTrial).SaccSeqInfo{iColm}(iRows,WhichC);
end
% Reaction Time: Start time - Gocue TIme
Dataf(iTrial).SacTimeGoc1(:,iRows+1) = Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC)-Dataf(iTrial).TimeGocOn;

% 11 12 X start and end location, 21 22 Y Start and End location, 31 32 XY Start and end
% location, Theta Start and end, Displacement Start and end, Acc Disp
% Start and End
for iType = 1:size(Dataf(iTrial).EyeLocR,1)
    Dataf(iTrial).SacLocGoc1(iType,:) = Dataf(iTrial).EyeLocR(iType, [Dataf(iTrial).SacTimeGoc1(:,1), Dataf(iTrial).SacTimeGoc1(:,2)]);
end
% find the peak velocity
Dataf(iTrial).SacPvelGoc1 = Dataf(iTrial).SaccSeqInfo{iColm}(end,WhichC);

% plot this trial to check
figure(2)
set(gcf,'Position',[1,1,1380,865])
p1 = []; p2 = []; p3 = [];
EyeLoc = [];
TimeS = [];
TimeE = [];
EyeLoc = Dataf(iTrial).EyeLocRGoc;
TimeS = Dataf(iTrial).SacTimeGoc1(1)-Dataf(iTrial).TimeGocOn;
TimeE = Dataf(iTrial).SacTimeGoc1(2)-Dataf(iTrial).TimeGocOn;
% plot cartesian
subplot(1,2,1)
% plot x location
p1 = plot(1:length(EyeLoc(1,:)),EyeLoc(1,:),'LineWidth',2);
hold on
% plot y location
p2 = plot(1:length(EyeLoc(2,:)),EyeLoc(2,:),'LineWidth',2);
% plot reference line
plot([GocC,GocC],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],':k','LineWidth',1)
% plot Start and end Saccade Location
plot([TimeS+GocC,TimeS+GocC],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--k','LineWidth',1);
plot([TimeE+GocC,TimeE+GocC],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--k','LineWidth',1);
xlabel('Time from Fixation Off, ms')
ylabel('Saccade Amplitude, deg')
legend([p1,p2],{'X','Y'},"Box","off");
set(gca,'FontSize',16);
hold off

% plot polar plot
subplot(1,2,2)
p3 = polarplot(EyeLoc(4,:),EyeLoc(3,:),'LineWidth',2,'Color',[0.4660 0.6740 0.1880]);
hold on
% mark the saccade onset and offset point
polarplot(EyeLoc(4,TimeS+GocC),EyeLoc(3,TimeS+GocC),'rx', 'MarkerSize', 8,'LineWidth',1.5)
polarplot(EyeLoc(4,TimeE+GocC),EyeLoc(3,TimeE+GocC),'rx', 'MarkerSize', 8,'LineWidth',1.5)
legend(p3,'Rho','Location', 'Northoutside','Box', 'off');
set(gca,'FontSize',16);
hold off

sgtitle(['Eye traces for example trial: ',num2str(iTrial),', Target Dir: ',num2str(Dataf(iTrial).TarDir)],'FontSize',16);
saveas(gcf,[FigDir,'/ExampleEyeTrace',num2str(iTrial),'_adj.fig'])


%% save and clear all data
varSave = {'DataEdf','Dataf','Sti','FP','Pre_FP','screen'};
save([DataDir,userID,'_',userDate,'_PreProcessed3.mat'],varSave{:});
clearvars -except DataEdf Dataf Sti FP Pre_FP screen
%save('zx01_110823_PreProcessed2')




