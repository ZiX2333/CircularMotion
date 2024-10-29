  % Psychtoolbox plus EyeLink integration test code for Xuan's human
% psychophys project on interceptive saccades to targets moving in a
% circular motion. JPM June 11 2023.

% WARNING: I think the code only requires a saccade to a moving target and
% does NOT include some amount of circular pursuit after the saccade.


% This code sets up an interceptive saccade task where a target stimulus
% moves in a circle, and the participant needs to make a saccade to intercept
% it. The fixation point is displayed in the center of the screen, and the
% target stimulus appears at a random position on ach trial.
% The code initializes the EyeLink eye tracker, sets up calibration
% parameters, and opens a Psychtoolbox window. It defines the fixation and
% target parameters, as well as the circle parameters. The EyeLink data
% file is created, and the eye data buffers are set up. The eye tracking
% recording is started, and a message is sent to the EyeLink. The code then
% sets up the trial parameters and runs the main loop for each  trial.
% Within each trial, the target onset is randomized, and the trajectory
% loop is executed. The fixation point is drawn, and if the current
% position is after the target onset, the target stimulus is drawn at that
% position. The screen is updated, eye position is retrieved from the
% EyeLink, and gaze position is updated. The loop continues until the
% trajectory is completed. After each trial, the screen is cleared and a
% random inter-trial interval is introduced. Finally, the eye tracking
% recording is stopped, the EyeLink connection is closed, and the s
% Psychtoolbox window is closed.
 
% experiment design:
% The displacing part include 6 (or 5) stages: Instruction stage (maybe
% not), PreFixation state (1000 frame), Fixation state (500-750 frame),
% Stimulus onset state (0-1200 frame), Saccade state (1000 frame, check later),
% Tracking state (200 frame)

% Delete eye traces on console computer, adjust parameters settings, Xuan
% Aug 02

%/media/mayolab/Backup Plus/Interceptive Saccade/Experiment/Ref/ % for reference code

%n 10.220.169.49

clear;
close all;
clc;
% Screen('Preference', 'SkipSyncTests', 1);
IsCalibrate = 1; % Require calibration before run the task
driftCounter = 0; % Check if drift check is required
dataDir = '/home/rajlab/CircularMotion';

InitializePsychSound;
% try
%% Record Subject Information

%% Hide cursor, define key
HideCursor;
AssertOpenGL;
KbName('UnifyKeyNames');
esc_key = KbName('q');
enter_Key = KbName('space');

%% Number of conditions and trials
num_Cond = 2; % 2dir (clockwise or counterclockw) * velocity * ecc
num_multp = 30; % How many trials in each condition
num_trial = num_Cond * num_multp;
num_CondSec = zeros(num_trial,1);
for i = 1:num_Cond
    num_CondSec((i-1)*num_multp+1:i*num_multp,1) = ones(num_multp,1)*i;
end
num_CondSec(randperm(num_trial),1) = num_CondSec(:,1);
% num_trial = 2;

%% Define screen parameters
% screen.Width=60; % width of screen (CM)
% screen.Height=33.5; % height of screen (CM)
% monitor screen is screens(1), display screen is screens(2)
screen.screens=Screen('Screens');
% for the calibration screen
[screen.Width, screen.Height] = Screen('DisplaySize',screen.screens(2));
screen.Width = screen.Width/10;
screen.Height = screen.Height/10;
screen.Distance=60; % distance from Screen to subject eye (CM)
screen.caliEyeScreen = screen.screens(2); % if only monitor screen then skip this line
screen.monitorScreen = screen.screens(1); % the screen used to display current eye location
screen.Number=max(screen.screens); % for a third screen to See how the experiment going
screen.BgColor = [200,200,200];

%% Stimulus Parameters
colorthreshold = 50; % Fixation and Tagrtet Color
colorvalue = 50;
caliEyeColor_L = colorvalue.*[0 1 0];
caliEyeColor_R = colorvalue.*[1 0 1];

% pre-FP
Pre_FP.maxDuration = 1000; % Subject need to fixate to the center within 1000ms
% Pre_FP.NeedToFixDuration = 100; % Stay in fixation point for 100ms to open next stage
 
 
% Fixation Point
FP.OnDurRange = [500,750]; % fixational interval, from 500 to 750 ms
FP.OffDurRange = [0,1200]; % time after stimulus osnet, FP disappear
%FP.Preduration = 600;
FP.Size = 0.5; % fixation size in degree
FP.Angle = 0; % fixation angle to the horizontal line, radius
FP.Distance = 0; % fixation distance to the center, eccentricity
FP.Color = colorthreshold.*[1 1 1];  % fixation color
FE.ColorHit = [0,128,0]; % Green
FP.ColorFail = [139,0,0]; % Red
FP.WindowSize = 6; % diameter

% Stimulus Parameters 
Sti.SaccLimT = 500; % time limit for the first saccade
% Sti.SaccRspT = 500; % after fixation off, saccade has to enter the check window within 500ms
Sti.SaccEntT = 100; % saccade has to enter the target window within 500ms
Sti.SmPurDur = 500; % following smooth pursuit time
Sti.size = 0.5;
Sti.Color = colorthreshold.*[1 1 1];
Sti.ColorHit = [0,128,0]; % Green
Sti.ColorFail = [139,0,0]; % Red
Sti.Distance = 8; % Stimulus eccentricity in degree
Sti.IniAngRange = [0,2*pi]; % Stimulus initial angle to the horizontal line
Sti.DirMove = [-1,1]; % mov ing clockwise or counter clockwise
Sti.Speed = 215 * pi/180; % 200 degree/s = 0.2 degree/ms, linear speed = ang speed * radius
Sti.WindowSize = 8   ; % diameter

% Saccade Parameters

%% EyeLink Connection and Calibration Paremeters
% % Initialize EyeLink connection
% % el = EyelinkInitDefaults(screen.caliEyeScreen);
% el = EyelinkInitDefaults(w2); 
%
% % Set calibration parameters
% el.calibrationtargetsize = 1;
% el.calibrationtargetwidth = 0.5;

% STEP 1: INITIALIZE EYELINK CONNECTION; OPEN EDF FILE; GET EYELINK TRACKER VERSION

% Initialize EyeLink connection (dummymode = 0) or run in "Dummy Mode" without an EyeLink connection (dummymode = 1);
dummymode = 0;
EyelinkInit(dummymode); % Initialize EyeLink connection
status = Eyelink('IsConnected');
if status < 1 % If EyeLink not connected
    dummymode = 1;
end

% Open dialog box for EyeLink Data file name entry. File name up to 8 characters
prompt = {'Enter EDF file name (up to 6 characters)'};
dlg_title = 'Create EDF file';
def = {'test'}; % Create a default edf file name
answer = inputdlg(prompt, dlg_title, 1, def); % Prompt for new EDF file name
% Print some text in Matlab's Command Window if a file name has not been entered
if  isempty(answer)
    fprintf('Session cancelled by user\n')
    % cleanup; % Abort experiment (see cleanup function below)
    return
end
edfFile = [answer{1},'_c']; % Save file name to a variable
edfFolder = answer{1};
% Print some text in Matlab's Command Window if file name is longer than 8 characters
if length(edfFile) > 8
    fprintf(2,'\n\nFilename needs to be no more than 6 characters long (letters, numbers and underscores only)\n\n');
    % cleanup; % Abort experiment (see cleanup function below)
    return
end

% Check if Folder exists, if so abort experiment
if isfolder(fullfile(path,edfFolder))
    if isfile(fullfile(path,edfFolder,edfFile + ".mat"))
        fprintf('Filename already exists \n');
        answer =  questdlg('Would you like to overwrite it?', 'Create EDF file','Yes', 'No','No');
        switch answer
            case 'Yes'
                fprintf("Overwrting %s\n", edfFile);
            otherwise
                fprintf(2, "\n\nExperiment Aborted!!! Please enter a new EDF name \n\n");
                % cleanup;
                return
        end
    end
end

mkdir(edfFolder)
cd(edfFolder)
path = pwd;

% Open an EDF file and name it
failOpen = Eyelink('OpenFile', edfFile);
if failOpen ~= 0 % Abort if it fails to open
    fprintf('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
    % cleanup; %see cleanup function below
    return
end

% Get EyeLink tracker and software version
% <ver> returns 0 if not connected
% <versionstring> returns 'EYELINK I', 'EYELINK II x.xx', 'EYELINK CL x.xx' where 'x.xx' is the software version
ELsoftwareVersion = 0; % Default EyeLink version in dummy mode
[ver, versionstring] = Eyelink('GetTrackerVersion');
if dummymode == 0 % If connected to EyeLink
    % Extract software version number.
    [~, vnumcell] = regexp(versionstring,'.*?(\d)\.\d*?','Match','Tokens'); % Extract EL version before decimal point
    ELsoftwareVersion = str2double(vnumcell{1}{1}); % Returns 1 for EyeLink I, 2 for EyeLink II, 3/4 for EyeLink 1K, 5 for EyeLink 1KPlus, 6 for Portable Duo
    % Print some text in Matlab's Command Window
    fprintf('Running experiment on %s version %d\n', versionstring, ver );
end
% Add a line of text in the EDF file to identify the current experimemt name and session. This is optional.
% If your text starts with "RECORDED BY " it will be available in DataViewer's Inspector window by clicking
% the EDF session node in the top panel and looking for the "Recorded By:" field in the bottom panel of the Inspector.
preambleText = sprintf('RECORDED BY Psychtoolbox demo %s session name: %s', mfilename, edfFile);
Eyelink('Command', 'add_file_preamble_text "%s"', preambleText);


%% SELECT AVAILABLE SAMPLE/EVENT DATA on eyelink
% See EyeLinkProgrammers Guide manual > Useful EyeLink Commands > File Data Control & Link Data Control

% Select which events are saved in the EDF file. Include everything just in case
Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
% Select which events are available online for gaze-contingent experiments. Include everything just in case
Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');
% Select which sample data is saved in EDF file or available online. Include everything just in case
if ELsoftwareVersion > 3  % Check tracker version and include 'HTARGET' to save head target sticker data for supported eye trackers
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
else
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,GAZERES,BUTTON,STATUS,INPUT');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end

%% Open the screen and calculate the parameter
% Priority(1);
% [screen.window, screen.Rect] = Screen('OpenWindow',screen.screens(1),screen.BgColor);
% w1 = screen.window;
% % pixel per degree, defined by visual angle
% ppd = pi * (screen.Rect(3)-screen.Rect(1)) / atan(screen.Width/screen.Distance/2) / 360;
% screen.ppd = ppd;
% [CenterX1, CenterY2] = RectCenter(screen.Rect);

[screen.window, screen.Rect] = Screen('OpenWindow',screen.caliEyeScreen,screen.BgColor);
w1 = screen.window;
ppd = pi * (screen.Rect(3)-screen.Rect(1)) / atan(screen.Width/screen.Distance/2) / 360;  % pixel per degree
screen.ppd = ppd;
[CenterX, CenterY] = RectCenter(screen.Rect);

fps = Screen('FrameRate',w1);                      % frames per second, depend on monitor refresh rate
ifi = Screen('GetFlipInterval', w1);               % inter flip interval
if ifi==0
    ifi=1/fps;
end
screen.fps = fps;
screen.ifi = ifi;
screen.CenterX = CenterX;
screen.CenterY = CenterY;

%% Calculate time in frame:
% Pre_FP.NeedToFixDuration_Frames  = round(Pre_FP.NeedToFixDuration/ 1000 / ifi);
Pre_FP.maxDuration_Frames = round(Pre_FP.maxDuration/ 1000 / ifi);

% generate rand frame in each trial
for i = 1:num_trial
    FP.OnFrames(i) = round(randi(FP.OnDurRange) /1000 / ifi);
    FP.OffFrames(i) = round(randi(FP.OffDurRange) /1000 / ifi);
end
Sti.SacFrames = round(Sti.SaccLimT /1000 / ifi);
Sti.SEnFrames = round(Sti.SaccEntT /1000 / ifi); % saccade enter frames
Sti.SmPFrames = round(Sti.SmPurDur /1000 / ifi);

% Other.ResponseFrames = round(Other.ResponseDuration / 1000/ ifi);
% Other.RedrawFP_Frames = round(Other.RedrawFPDuration /1000 / ifi); % state 4: Redraw FP
% Other.ITI_Frames = round(Other.InterTrialInterval /1000 / ifi); % state 5: Inter trial interval
% Other.RecordAfterBreak_Frames = round(Other.RecordAfterBreak / 1000 / ifi);

%% Calculate Size into Pixel
FP.sizePixel = round(FP.Size * ppd );
FP.LocX = FP.Distance * cos(FP.Angle) * ppd  + CenterX;
FP.LocY = FP.Distance * sin(FP.Angle) * ppd  + CenterY;
FP.Pos = [FP.LocX - round(FP.sizePixel/2),FP.LocY - round(FP.sizePixel/2),FP.LocX + round(FP.sizePixel/2),FP.LocY + round(FP.sizePixel/2)];
FP.WindowPixel = round(FP.WindowSize * ppd );

Sti.sizePixel = round(Sti.size * ppd );
% generate random initial sti location
for i = 1:num_trial
    Sti.IniAng(i) = 2*pi*rand(1);
    % Sti.LocYs(i) = round(Sti.Distance * sin(randi(Sti.IniAngRange)) * ppd ) + CenterY;
    % generate following sequence:
    IniAngCur = Sti.IniAng(i);
    % Generate trials based on preallocated condition sequence
    if  num_CondSec(i) == 1 % counterclockwise
        for j = 1:(FP.OffFrames(i)+Sti.SacFrames+Sti.SmPFrames)
            Sti.PathXs(i,j) = Sti.Distance* cos(IniAngCur)*ppd + CenterX;
            Sti.PathYs(i,j) = Sti.Distance* sin(IniAngCur)*ppd + CenterY;
            IniAngCur = IniAngCur + Sti.Speed*ifi;
        end
    elseif num_CondSec(i) == 2 %clockwise
        for j = 1:(FP.OffFrames(i)+Sti.SacFrames+Sti.SmPFrames)
            Sti.PathXs(i,j) = Sti.Distance* cos(IniAngCur)*ppd + CenterX;
            Sti.PathYs(i,j) = Sti.Distance* sin(IniAngCur)*ppd + CenterY;
            IniAngCur = IniAngCur - Sti.Speed*ifi;
        end
    end
end
Sti.WindowPixel = round(Sti.WindowSize * ppd );

%% Instruction:
BreakSession = 0;

while 1
    [~,~,Key_press] = KbCheck;

    text1 = double('Task Instruction');
    text2 = double('There will be a circle at the cennter of the screen, then another circle moving around the center');
    text3 = double('Please keep you head stable and watch the scenter. Watch the moving circle quickly and correctly after the center circle disappear');
    Screen('DrawText',w1,text1,CenterX - 100,CenterY-50, Sti.Color);
    Screen('DrawText',w1,text2,CenterX - 500,CenterY,Sti.Color);
    Screen('DrawText',w1,text3,CenterX - 700,CenterY+50,Sti.Color);
    % Screen('DrawText',w,text1,CenterX2 - 200,CenterY-50,[255 255 255]);
    % Screen('DrawText',w,text2,CenterX2 - 450,CenterY,[255 255 255]);
    % Screen('DrawText',w,text3,CenterX2 - 400,CenterY+50,[255 255 255])
    Screen(w1,'Flip');
    % Screen(w2,'Flip');
    if Key_press(enter_Key)
        enter_Key = 1;
        break;
    end

end

% different state
state_PreFP_flag = 1;
state_FP_flag = 0;
state_Delay_flag = 0;
state_Sti_flag = 0;
state_SacResp_flag = 0;
state_SmPResp_flag = 0;


%     %% preallocatioon space for eye location storage
%
%     % set up EyeLink data file
%     % edfFile = 'interceptive_saccade.edf';
%     % Eyelink('OpenFile', edfFile);
%
%     % Set up eye data buffers
%     eyeData = struct('time', [], 'x', [], 'y', []);
%     maxSamples = 5000;  % Maximum number of eye samples to store
%     eyeData.time = zeros(1, maxSamples);
%     eyeData.x = zeros(1, maxSamples);
%     eyeData.y = zeros(1, maxSamples);
%     sampleCount = 0;
%
%     % Begin eye tracking recording
%     Eyelink('StartRecording');
%
%     % Send message to EyeLink
%     Eyelink('Message', 'Start of interceptive saccade task');

% %% Start Eyelink Recording
% Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before drawing Host PC graphics and before recording
% Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
% WaitSecs(0.1);  % Allow some time for drawing
% 
% % Check if a drift check is required, if subject fail to
% % fixature two trials in a row
% % if driftCounter >= 2
% %     driftCounter = 0;
% %     EyelinkDoDriftCorrection(el, FP.LocX, FP.LocY);
% % end
% 
% %STEP 5.3: START RECORDING
% 
% % Put tracker in idle/offline mode before recording. Eyelink('SetOfflineMode') is recommended
% % however if Eyelink('Command', 'set_idle_mode') is used allow 50ms before recording as shown in the commented code:
% % Eyelink('Command', 'set_idle_mode');% Put tracker in idle/offline mode before recording
% % WaitSecs(0.05); % Allow some time for transition
% Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before recording
% Eyelink('StartRecording'); % Start tracker recording
% WaitSecs(0.1); % Allow some time to record a few samples before presenting first stimulus

%% SET CALIBRATION SCREEN COLOURS; PROVIDE WINDOW SIZE TO EYELINK HOST & DATAVIEWER; SET CALIBRATION PARAMETERS; CALIBRATE

% Provide EyeLink with some defaults, which are returned in the structure "el".
el = EyelinkInitDefaults(w1);
% set calibration/validation/drift-check(or drift-correct) size as well as background and target colors.
% It is important that this background colour is similar to that of the stimuli to prevent large luminance-based
% pupil size changes (which can cause a drift in the eye movement data)
el.calibrationtargetsize = 3;% Outer target size as percentage of the screen
el.calibrationtargetwidth = 0.7;% Inner target size as percentage of the screen
el.backgroundcolour = screen.BgColor;% RGB white
el.calibrationtargetcolour = FP.Color;% RGB black
% set "Camera Setup" instructions text colour so it is different from background colour
el.msgfontcolour = [0 0 0];% RGB black
el.targetbeep = 0;
el.feedbackbeep = 0;
% You must call this function to apply the changes made to the el structure above
EyelinkUpdateDefaults(el);

% Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, screen.Rect(3)-1, screen.Rect(1)-1);
% Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
% See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, screen.Rect(3)-1, screen.Rect(1)-1);
% Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
Eyelink('Command', 'calibration_type = HV9'); % horizontal-vertical 9-points
% Hide mouse cursor
HideCursor(w1);
if dummymode == 1
    ShowCursor(0,w1);
end
% Start listening for keyboard input. Suppress keypresses to Matlab windows.
ListenChar(-1);

abort = 0;
blockNo = 1;

%% run trial
Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
% Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
EyelinkDoTrackerSetup(el);

for i_trial = 1:num_trial
    BreakTrial_FP = 0; % Break trial happened at only FP exist
    BreakTrial_FS = 0; % Break trial happened at FP and Sti both exist and subject need to keep Fixation
    % BreakTrial_FS2 = 0; % Break trial happened at FP and Sti both exist and subject need to make Saccade
    BreakTrial_Sti = 0; % Break trial happened at only Sti exist
    % different state
    state_PreFP_flag = 1;
    state_FP_flag = 0;
    state_Delay_flag = 0;
    state_Sti_flag = 0;
    state_SacResp_flag = 0;
    state_SmPResp_flag = 0;

    %% Send Eyelink Message

    % Write TRIALID message to EDF file: marks the start of a trial for DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Defining the Start and End of a Trial
    Eyelink('Message', 'TRIALID %d', i_trial);
    % Write !V CLEAR message to EDF file: creates blank backdrop for DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Simple Drawing
    Eyelink('Message', '!V CLEAR %d %d %d', el.backgroundcolour(1), el.backgroundcolour(2), el.backgroundcolour(3));
    % Supply the trial number and type as a line of text on Host PC screen

    Eyelink('Command', 'record_status_message "TrialNum %d', i_trial);
    % Eyelink('Message', 'BLOCK %d, TRIAL %d/%d', blockNo, trialIndex, data.trialPerBlock);
    % Eyelink('Message', 'Dir %d, Speed %s, Ecc %d', num_CondSec(i_trial), Sti.Speed*180/pi, Sti.Distance);


    % Draw target trajectory lines on the EyeLink Host PC display.
    % See section 25.7 'Drawing Commands' in the EyeLink Programmers Guide manual

    % Put tracker in idle/offline mode before recording. Eyelink('SetOfflineMode') is recommended
    % however if Eyelink('Command', 'set_idle_mode') is used allow 50ms before recording as shown in the commented code:
    % Eyelink('Command', 'set_idle_mode');% Put tracker in idle/offline mode before recording
    % WaitSecs(0.05); % Allow some time for transition
    Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before recording
    Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
    Eyelink('StartRecording'); % Start tracker recording
    WaitSecs(0.1); % Allow some time to record a few samples before presenting first stimulus

    % record all the following real time data in EyeData
    % Check which eye is available. Returns 0 (left), 1 (right) or 2 (binocular)
    EyeData.trial{i_trial}.eyeUsed = Eyelink('EyeAvailable');
    % Get samples from right eye if binocular
    if EyeData.trial{i_trial}.eyeUsed == 2
        EyeData.trial{i_trial}.eyeUsed = 1;
    end

    %% state: Pre-FP
    if state_PreFP_flag == 1
        CondiNo = 1; % 1 = PreFP condition
        for i_frame = 1:Pre_FP.maxDuration_Frames
            % Check that eye tracker is  still recording. Otherwise close and transfer copy of EDF file to Display PC
            err = Eyelink('CheckRecording');
            if(err ~= 0)
                fprintf('EyeLink Recording stopped!\n');
                % Transfer a copy of the EDF file to Display PC
                Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
                Eyelink('CloseFile'); % Close EDF file on Host PC
                Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
                WaitSecs(0.1); % Allow some time for screen drawing
                % Transfer a copy of the EDF file to Display PC
                break
            end

            % If in dummymode get mouse location and show cursor
            if dummymode == 1
                % ShowCursor(0,w1);
                [eyeX, eyeY] = GetMouse();
            end

            % record frame number and condition number, 1 = preFP
            Eyelink('Message', 'FRAME_NUM %d, CONDI %d', i_frame, CondiNo);
            % Write message to EDF file to mark the start time of stimulus presentation
            % Eyelink('Message', 'FP_POS %.2f %.2f', FP.LocX, FP.LocY);

            % record eye data
            % Check if a new sample is available online via the link. This is the most recent sample, which is faster than buffered data
            if Eyelink('NewFloatSampleAvailable') > 0
                % Get sample data in a Matlab structure
                % This is equivalent to eyeLink_newest_float_sample() in C API. See EyeLink Programmers Guide manual > Function Lists > Message and Command Sending/Receiving > Functions
                sample = Eyelink('NewestFloatSample');
 
                % Save sample properties as variables. See EyeLink Programmers Guide manual > Data Structures > FSAMPLE
                eyeX = sample.gx(EyeData.trial{i_trial}.eyeUsed +1); % [left eye gaze x, right eye gaze x], +1 as we're accessing a Matlab array
                eyeY = sample.gy(EyeData.trial{i_trial}.eyeUsed +1); % [left eye gaze y, right eye gaze y]
            end

            % draw fixation point
            Screen('DrawDots', w1, [FP.LocX, FP.LocY], FP.sizePixel, FP.Color, [], 2);

            % draw eye's real time location

            % update screen, present the stimulus
            [~,stTime] = Screen('Flip', w1);
            if dummymode == 0
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.trackerTime = Eyelink('TrackerTime');
            end
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.PTBTime = stTime;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeX = eyeX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeY = eyeY;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.FPX = FP.LocX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.FPY = FP.LocY;
            EyeData.trial{i_trial}.Condi{CondiNo}.string = '';
 
            % Get eye position from EyeLink
            % sample = Eyelink('NewestFloatSample');
            % if sample.gx(eyeUsed) ~= el.MISSING_DATA && sample.gy(eyeUsed) ~= el.MISSING_DATA
            %     sampleCount = sampleCount + 1;
            %     eyeData.time(sampleCount) = sample.time;
            %     eyeData.x(sampleCount) = sample.gx(eyeUsed);
            %     eyeData.y(sampleCount) = sample.gy(eyeUsed);
            % end

            % % Update EyeLink gaze position
            % Eyelink('Command', 'record_status_message "Gaze x=%.1f y=%.1f"', sample.gx(eyeUsed), sample.gy(eyeUsed));
            % % detect location

            % detect break session
            [ ~, ~, keyCode ] = KbCheck;
            if keyCode(esc_key)
                BreakSession=1;
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
                Eyelink('Message', 'Break Session');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Break Session';
                break
            else
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
            end

            % Check if gaze has already enter thr fixation window

            % Check if eye has enter the fixation window
            if sqrt(((FP.LocX-eyeX)/ppd).^2 + ((FP.LocY - eyeY)/ppd).^2)  <= FP.WindowSize / 2
                EyeData.trial{i_trial}.Condi{CondiNo}.fixStart = i_frame;
                Eyelink('Message', 'FIXATION ACQUIRED');
                % start next state
                state_PreFP_flag = 0;
                state_FP_flag = 1;
                break
                % Fixation point did not move in within the required time
            elseif i_frame *ifi *1000 > Pre_FP.maxDuration || i_frame == Pre_FP.maxDuration_Frames
                Eyelink('Message', 'FIXATION TIMEOUT');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'FIXATION TIMEOUT';
                Eyelink('Message', 'TRIAL RESULT 0');
                EyeData.trial{i_trial}.Condi{CondiNo}.result = 0;
                BreakTrial_FP = 1;
                state_PreFP_flag = 0;
                % add drift check later
                % driftCounter = driftCounter +1; % Increase Drift check counter
                break
            end
        end
    end

    %         if BreakTrial == 1
    %             continue
    %         end

    %% state: FP

    if state_FP_flag == 1
        CondiNo = 2; % second condition, prefixation condition

        for i_frame = 1:FP.OnFrames(i_trial)

            % Check that eye tracker is  still recording. Otherwise close and transfer copy of EDF file to Display PC
            err = Eyelink('CheckRecording');
            if(err ~= 0)
                fprintf('EyeLink Recording stopped!\n');
                % Transfer a copy of the EDF file to Display PC
                Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
                Eyelink('CloseFile'); % Close EDF file on Host PC
                Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
                WaitSecs(0.1); % Allow some time for screen drawing
                % Transfer a copy of the EDF file to Display PC
                break
            end

            % If in dummymode get mouse location and show cursor
            if dummymode == 1
                % ShowCursor(0,w1);
                [eyeX, eyeY] = GetMouse();
            end

            % plot fixation point
            Screen('DrawDots', w1, [FP.LocX, FP.LocY], FP.sizePixel, FP.Color, [], 2);

            % draw eye's real time location

            % update screen, present the stimulus
            [~,stTime] = Screen('Flip', w1);

            % record frame number and condition number, 1 = preFP
            Eyelink('Message', 'FRAME_NUM %d, CONDI %d', i_frame, CondiNo);
            % Write message to EDF file to mark the start time of stimulus presentation
            % Eyelink('Message', 'FP_POS %.2f %.2f', FP.LocX, FP.LocY);

            % record eye data
            % Check if a new sample is available online via the link. This is the most recent sample, which is faster than buffered data
            if Eyelink('NewFloatSampleAvailable') > 0
                % Get sample data in a Matlab structure
                % This is equivalent to eyeLink_newest_float_sample() in C API. See EyeLink Programmers Guide manual > Function Lists > Message and Command Sending/Receiving > Functions
                sample = Eyelink('NewestFloatSample');

                % Save sample properties as variables. See EyeLink Programmers Guide manual > Data Structures > FSAMPLE
                eyeX = sample.gx(EyeData.trial{i_trial}.eyeUsed +1 ); % [left eye gaze x, right eye gaze x], +1 as we're accessing a Matlab array
                eyeY = sample.gy(EyeData.trial{i_trial}.eyeUsed +1 ); % [left eye gaze y, right eye gaze y]
            end
            if dummymode == 0
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.trackerTime = Eyelink('TrackerTime');
            end
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.PTBTime = stTime;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeX = eyeX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeY = eyeY;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.FPX = FP.LocX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.FPY = FP.LocY;
            EyeData.trial{i_trial}.Condi{CondiNo}.string = '';

            % detect break session
            [ ~, ~, keyCode ] = KbCheck;
            if keyCode(esc_key)
                BreakSession=1;
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
                Eyelink('Message', 'Break Session');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Break Session';
                break
            else
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
            end

            % Check if gaze leave the fixation window
            if sqrt(((FP.LocX-eyeX)/ppd).^2 + ((FP.LocY - eyeY)/ppd).^2)  > FP.WindowSize / 2

                Eyelink('Message', 'Fixation Leave Window');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Fixation Leave Window';
                Eyelink('Message', 'TRIAL RESULT 0');
                EyeData.trial{i_trial}.Condi{CondiNo}.result = 0;
                % state_PreFP_flag = 1;
                state_FP_flag = 0;
                BreakTrial_FP = 1;
                % add drift check later
                % driftCounter = driftCounter +1; % Increase Drift check counter
                break
                % continue
            elseif i_frame == FP.OnFrames(i_trial)
                state_FP_flag = 0;
                state_Delay_flag = 1;
            end
        end
    end

    %         if BreakTrial == 1
    %             continue
    %         end

    %% state: Sti onset
    if state_Delay_flag == 1
        CondiNo = 3; %delay Contition

        for i_frame = 1:FP.OffFrames(i_trial)

            % Check that eye tracker is  still recording. Otherwise close and transfer copy of EDF file to Display PC
            err = Eyelink('CheckRecording');
            if(err ~= 0)
                fprintf('EyeLink Recording stopped!\n');
                % Transfer a copy of the EDF file to Display PC
                Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
                Eyelink('CloseFile'); % Close EDF file on Host PC
                Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
                WaitSecs(0.1); % Allow some time for screen drawing
                % Transfer a copy of the EDF file to Display PC
                break
            end

            % If in dummymode get mouse location and show cursor
            if dummymode == 1
                % ShowCursor(0,w1);
                [eyeX, eyeY] = GetMouse();
            end

            % plot fixation point before gocue
            Screen('DrawDots', w1, [FP.LocX, FP.LocY], FP.sizePixel, FP.Color, [], 2);

            % StiRect = CenterRectOnPointd([0 0 Sti.Distance Sti.Distance]*ppd, ...
            %     Sti.PathXs(i_trial,i_frame), Sti.PathYs(i_trial,i_frame));
            % Screen('FillOval',w2 ,Sti.Color,StiRect);
            Screen('DrawDots', w1, [Sti.PathXs(i_trial,i_frame), Sti.PathYs(i_trial,i_frame)],...
                Sti.sizePixel, Sti.Color, [], 2);

            % draw eye's real time location

            % update screen, present the stimulus
            [~,stTime] = Screen('Flip', w1);

            % record frame number and condition number, 1 = preFP
            Eyelink('Message', 'FRAME_NUM %d, CONDI %d', i_frame, CondiNo);
            % Write message to EDF file to mark the start time of stimulus presentation
            % Eyelink('Message', 'FP_POS %.2f %.2f', FP.LocX, FP.LocY);
            % Eyelink('Message', 'Targ_POS %.2f %.2f', Sti.PathXs(i_trial,i_frame), Sti.PathYs(i_trial,i_frame));

            % record eye data
            % Check if a new sample is available online via the link. This is the most recent sample, which is faster than buffered data
            if Eyelink('NewFloatSampleAvailable') > 0
                % Get sample data in a Matlab structure
                % This is equivalent to eyeLink_newest_float_sample() in C API. See EyeLink Programmers Guide manual > Function Lists > Message and Command Sending/Receiving > Functions
                sample = Eyelink('NewestFloatSample');

                % Save sample properties as variables. See EyeLink Programmers Guide manual > Data Structures > FSAMPLE
                eyeX = sample.gx(EyeData.trial{i_trial}.eyeUsed +1); % [left eye gaze x, right eye gaze x], +1 as we're accessing a Matlab array
                eyeY = sample.gy(EyeData.trial{i_trial}.eyeUsed +1); % [left eye gaze y, right eye gaze y]
            end
            if dummymode == 0
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.trackerTime = Eyelink('TrackerTime');
            end
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.PTBTime = stTime;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeX = eyeX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeY = eyeY;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.FPX = FP.LocX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.FPY = FP.LocX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.targX = Sti.PathXs(i_trial,i_frame);
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.targY = Sti.PathYs(i_trial,i_frame);
            EyeData.trial{i_trial}.Condi{CondiNo}.string = '';

            % detect break session
            [ ~, ~, keyCode ] = KbCheck;
            if keyCode(esc_key)
                BreakSession=1;
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
                Eyelink('Message', 'Break Session');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Break Session';
                break
            else
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
            end

            % Check if gaze leave the fixation window
            if sqrt(((FP.LocX-eyeX)/ppd).^2 + ((FP.LocY - eyeY)/ppd).^2)  > FP.WindowSize / 2

                Eyelink('Message', 'Fixation Leave Window');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Fixation Leave Window';
                Eyelink('Message', 'TRIAL RESULT 0');
                EyeData.trial{i_trial}.Condi{CondiNo}.result = 0;
                % add drift check later
                % driftCounter = driftCounter +1; % Increase Drift check counter
                state_Delay_flag = 0;
                BreakTrial_FS = 1;
                break
            elseif i_frame == FP.OffFrames(i_trial)
                state_Delay_flag = 0;
                state_SacResp_flag = 1;
            end
        end
    end

    %         if BreakTrial == 1
    %             continue
    %         end

    %% state Response, center target offset, subjects need to move their eye within certain

    if state_SacResp_flag == 1
        CondiNo = 4; % after gocue, subject required to move their eye
        i_frame1 = FP.OffFrames(i_trial);
        i_leaveF = 0;

        % start from one
        for i_frame = 1: Sti.SacFrames
            i_frame1 = i_frame1+1;

            % Check that eye tracker is  still recording. Otherwise close and transfer copy of EDF file to Display PC
            err = Eyelink('CheckRecording');
            if(err ~= 0)
                fprintf('EyeLink Recording stopped!\n');
                % Transfer a copy of the EDF file to Display PC
                Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
                Eyelink('CloseFile'); % Close EDF file on Host PC
                Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
                WaitSecs(0.1); % Allow some time for screen drawing
                % Transfer a copy of the EDF file to Display PC
                break
            end

            % If in dummymode get mouse location and show cursor
            if dummymode == 1
                % ShowCursor(0,w1);
                [eyeX, eyeY] = GetMouse();
            end

            % draw stimulus
            Screen('DrawDots', w1, [Sti.PathXs(i_trial,i_frame1), Sti.PathYs(i_trial,i_frame1)],...
                Sti.sizePixel, Sti.Color, [], 2);

            % draw eye's real time location

            % update screen, present the stimulus
            [~,stTime] = Screen('Flip', w1);

            % record frame number and condition number, 1 = preFP
            Eyelink('Message', 'FRAME_NUM %d, CONDI %d', i_frame, CondiNo);
            % Write message to EDF file to mark the start time of stimulus presentation
            % Eyelink('Message', 'Targ_POS %.2f %.2f', Sti.PathXs(i_trial,i_frame), Sti.PathYs(i_trial,i_frame));

            % record eye data
            % Check if a new sample is available online via the link. This is the most recent sample, which is faster than buffered data
            if Eyelink('NewFloatSampleAvailable') > 0
                % Get sample data in a Matlab structure
                % This is equivalent to eyeLink_newest_float_sample() in C API. See EyeLink Programmers Guide manual > Function Lists > Message and Command Sending/Receiving > Functions
                sample = Eyelink('NewestFloatSample');

                % Save sample properties as variables. See EyeLink Programmers Guide manual > Data Structures > FSAMPLE
                eyeX = sample.gx(EyeData.trial{i_trial}.eyeUsed +1); % [left eye gaze x, right eye gaze x], +1 as we're accessing a Matlab array
                eyeY = sample.gy(EyeData.trial{i_trial}.eyeUsed +1); % [left eye gaze y, right eye gaze y]
            end
            if dummymode == 0
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.trackerTime = Eyelink('TrackerTime');
            end
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.PTBTime = stTime;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeX = eyeX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeY = eyeY;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.targX = Sti.PathXs(i_trial,i_frame1);
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.targY = Sti.PathYs(i_trial,i_frame1);
            EyeData.trial{i_trial}.Condi{CondiNo}.string = '';

            % detect break session
            [ ~, ~, keyCode ] = KbCheck;
            if keyCode(esc_key)
                BreakSession=1;
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
                Eyelink('Message', 'Break Session');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Break Session';
                break
            else
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
            end

            % Check if gaze enter the stimulus window within required
            % time (200ms ?)
            % count the frame after eye leave the FP win
            if sqrt(((FP.LocX-eyeX)/ppd).^2 + ((FP.LocY - eyeY)/ppd).^2)  > FP.WindowSize / 2
                i_leaveF = i_leaveF+1;
                % check if the eye enter the sti win after leaving the FP win
                % within required time: 00 ms?
                if sqrt(((Sti.PathXs(i_trial,i_frame1)-eyeX)/ppd).^2 + ((Sti.PathYs(i_trial,i_frame1) - eyeY)/ppd).^2)  <= Sti.WindowSize / 2
                    EyeData.trial{i_trial}.Condi{CondiNo}.gazeEnter = i_frame;
                    Eyelink('Message', 'Gaze Enter Target Window');
                    % start next state
                    state_SacResp_flag = 0;
                    state_SmPResp_flag = 1;
                    break
                    % didn't enter the sti win within required time
                elseif i_leaveF * ifi *1000 >Sti.SaccEntT || i_leaveF>Sti.SEnFrames
                    Eyelink('Message', 'Fixation Fail to Enter Sti Window');
                    EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Fixation Fail to Enter Sti Window';
                    Eyelink('Message', 'TRIAL RESULT 0');
                    EyeData.trial{i_trial}.Condi{CondiNo}.result = 0;
                    state_SacResp_flag = 0;
                    BreakTrial_Sti = 1;
                    break
                end
                % Eye did not move in the sti check window within the required timei
            elseif i_frame *ifi *1000 > Sti.SaccLimT || i_frame == Sti.SacFrames
                Eyelink('Message', 'Response Timeout');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Response Timeout';
                Eyelink('Message', 'TRIAL RESULT 0');
                EyeData.trial{i_trial}.Condi{CondiNo}.result = 0;
                state_SacResp_flag = 0;
                BreakTrial_Sti = 1;
                break
                % add drift check later
                % driftCounter = driftCounter +1; % Increase Drift check counter
                % continue
            end
        end
    end

    %% smooth pursuit session
    if state_SmPResp_flag == 1 
        CondiNo = 5; % after landing

        for i_frame = 1: Sti.SmPFrames
            i_frame1 = i_frame1+1;

            % Check that eye tracker is  still recording. Otherwise close and transfer copy of EDF file to Display PC
            err = Eyelink('CheckRecording');
            if(err ~= 0)
                fprintf('EyeLink Recording stopped!\n');
                % Transfer a copy of the EDF file to Display PC
                Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
                Eyelink('CloseFile'); % Close EDF file on Host PC
                Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
                WaitSecs(0.1); % Allow some time for screen drawing
                % Transfer a copy of the EDF file to Display PC
                break
            end

            % If in dummymode get mouse location and show cursor
            if dummymode == 1
                % ShowCursor(0,w1);
                [eyeX, eyeY] = GetMouse();
            end

            % draw stimulus
            Screen('DrawDots', w1, [Sti.PathXs(i_trial,i_frame1), Sti.PathYs(i_trial,i_frame1)],...
                Sti.sizePixel, Sti.Color, [], 2);

            % draw eye's real time location

            % update screen, present the stimulus
            [~,stTime] = Screen('Flip', w1);

            % record frame number and condition number, 1 = preFP
            Eyelink('Message', 'FRAME_NUM %d, CONDI %d', i_frame, CondiNo);
            % Write message to EDF file to mark the start time of stimulus presentation
            % Eyelink('Message', 'Targ_POS %.2f %.2f', Sti.PathXs(i_trial,i_frame), Sti.PathYs(i_trial,i_frame));

            % record eye data
            % Check if a new sample is available online via the link. This is the most recent sample, which is faster than buffered data
            if Eyelink('NewFloatSampleAvailable') > 0
                % Get sample data in a Matlab structure
                % This is equivalent to eyeLink_newest_float_sample() in C API. See EyeLink Programmers Guide manual > Function Lists > Message and Command Sending/Receiving > Functions
                sample = Eyelink('NewestFloatSample');

                % Save sample properties as variables. See EyeLink Programmers Guide manual > Data Structures > FSAMPLE
                eyeX = sample.gx(EyeData.trial{i_trial}.eyeUsed +1); % [left eye gaze x, right eye gaze x], +1 as we're accessing a Matlab array
                eyeY = sample.gy(EyeData.trial{i_trial}.eyeUsed +1 ); % [left eye gaze y, right eye gaze y]
            end
            if dummymode == 0
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.trackerTime = Eyelink('TrackerTime');
            end
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.PTBTime = stTime;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeX = eyeX;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.eyeY = eyeY;
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.targX = Sti.PathXs(i_trial,i_frame1);
            EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.targY = Sti.PathYs(i_trial,i_frame1);
            EyeData.trial{i_trial}.Condi{CondiNo}.string = '';

            % detect break session
            [ ~, ~, keyCode ] = KbCheck;
            if keyCode(esc_key)
                BreakSession=1;
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
                Eyelink('Message', 'Break Session');
                EyeData.trial{i_trial}.Condi{CondiNo}.string = 'Break Session';
                break
            else
                EyeData.trial{i_trial}.Condi{CondiNo}.frame{i_frame}.BreakSess = BreakSession;
            end

            % Check if gaze leave the stimulus window
            if sqrt(((Sti.PathXs(i_trial,i_frame1)-eyeX)/ppd).^2 + ((Sti.PathYs(i_trial,i_frame1) - eyeY)/ppd).^2)  > Sti.WindowSize / 2

                EyeData.trial{i_trial}.Condi{CondiNo}.gazeLeave = i_frame;
                Eyelink('Message', 'Gaze Leave Target Window');
                % start next state
                %  
                % state_SacResp_flag = 0;
                % state_SmPResp_flag = 0;
                % BreakTrial_Sti = 1;
                % break
            end
        end
    end

    %% break session

    if BreakSession == 1
        % clean up function
        try
            Screen('CloseAll'); % Close window if it is open
        end
        % Eyelink('Shutdown'); % Close EyeLink connection

        ListenChar(0); % Restore keyboard output to Matlab
        ShowCursor; % Restore mouse cursor
        % sca; % Close Psychtoolbox window
        break;
    end

    %% Break Trial
    if BreakTrial_FP == 1
        for i = 1:10 % present 10 frame wrong feedback
            % draw fixation point
            Screen('DrawDots', w1, [FP.LocX, FP.LocY], FP.sizePixel, FP.ColorFail, [], 2);
            % update screen, present the stimulus
            [~,stTime] = Screen('Flip', w1); 
        end
    elseif BreakTrial_FS == 1
        for i = 1:10
            % draw fixation point
            Screen('DrawDots', w1, [FP.LocX, FP.LocY], FP.sizePixel, FP.ColorFail, [], 2);
            % draw stimulus location
            Screen('DrawDots', w1, [Sti.PathXs(i_trial,i_frame), Sti.PathYs(i_trial,i_frame)],...
                Sti.sizePixel, Sti.Color, [], 2);
            % update screen, present the stimulus
            [~,stTime] = Screen('Flip', w1); 
        end
    elseif BreakTrial_Sti == 1
        for i = 1:10 % present 10 frame wrong feedback
            % draw stimulus
            Screen('DrawDots', w1, [Sti.PathXs(i_trial,i_frame1), Sti.PathYs(i_trial,i_frame1)],...
                Sti.sizePixel, Sti.ColorFail, [], 2);
            % update screen, present the stimulus
            [~,stTime] = Screen('Flip', w1);
        end

    end

    %% clear and wait ITI
    % Clear the screen
    Screen('FillRect', w1, screen.BgColor);
    Screen('Flip', w1);

    Eyelink('Message', 'BLANK_SCREEN');

    % Wait for a random interval before the next  trial
    interTrialInterval = rand(1) + 1;  % Random interval between 1 and 2 seconds
    WaitSecs(interTrialInterval);

end

%%
% End eye tracking recording
% Eyelink('StopRecording');
Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
Eyelink('Command', 'clear_screen 0'); % Clear Host PC backdrop graphics at the end of the experiment

save(edfFile+".mat",'EyeData')

% Close the EyeLink connection
Eyelink('CloseFile');
Eyelink('ReceiveFile', edfFile);
Eyelink('Shutdown');

% Read out edf file
edfStruct = edfmex([edfFile,'.edf']);
% Save all of them
save([answer{1},'_all.mat']);

%%
ListenChar(0); % Restore keyboard output to Matlab
ShowCursor; % Restore mouse cursor

% Close the Psychtoolbox window
sca;
% catch
%     sca;
% end

