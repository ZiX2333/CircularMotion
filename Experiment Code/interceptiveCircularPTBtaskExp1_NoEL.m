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
% sets up the trial parameters and runs the main loop for each trial. 
% Within each trial, the target onset is randomized, and the trajectory 
% loop is executed. The fixation point is drawn, and if the current 
% position is after the target onset , the target stimulus is drawn at that 
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

% Add random fixation interval, go cue, initial location, Xuan Jun 20

% /media/mayolab/Backup Plus/Interceptive Saccade/Experiment/Ref/ % for reference code

%n 

clear;
close all;
clc;
Screen('Preference', 'SkipSyncTests', 1);
IsCalibrate = 1; % Require calibration before run the task

%% Record Subject Information

%% Hide cursor, define key
HideCursor;
AssertOpenGL;
KbName('UnifyKeyNames');
esc_key = KbName('ESCAPE');
enter_Key = KbName('space');

%% Initialize Eyelink Connection and calibration parameters
HideCursor

%% Number of conditions and trials
num_Cond = 2; % 2dir (clockwise or counterclockw) * velocity * ecc
num_multp = 20; % How many trials in each condition
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
[screen.Width, screen.Height] = Screen('DisplaySize',screen.screens(2)); % mm
screen.Width = screen.Width/10;
screen.Height = screen.Height/10;
screen.Distance=70; % distance from Screen to subject eye (CM)
screen.caliEyeScreen = screen.screens(2); % if only monitor screen then skip this line
screen.Number=max(screen.screens); % for a third screen to See how the experiment going
screen.BgColor = [0 0 0];

%% Stimulus Parameters
colorthreshold = 130; % Fixation and Tagrtet Color
colorvalue = 130;
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
FP.WindowSize = [5 5];

% Stimulus Parameters 
Sti.Duration = 1500;
Sti.size = 0.5; 
Sti.Color = colorthreshold.*[1 1 1];
Sti.Distance = 8; % Stimulus eccentricity in degree
Sti.IniAngRange = [0,2*pi]; % Stimulus initial angle to the horizontal line
Sti.DirMove = [-1,1]; % movi ng clockwise or counter clockwise
Sti.Speed = 150 * pi/180; % 200 degree/s = 0.2 degree/ms
Sti.WindowSize = [3 5];
 
% Saccade Parameters

%% Open the screen and calculate the parameter
Priority(1);
[screen.window, screen.Rect] = Screen('OpenWindow',screen.screens(2),screen.BgColor);
w1 = screen.window;
% pixel per degree, defined by visual angle
ppd = pi * (screen.Rect(3)-screen.Rect(1)) / atan(screen.Width/screen.Distance/2) / 360;
screen.ppd = ppd;
[CenterX, CenterY] = RectCenter(screen.Rect);

% [screen.window2, screen.Rect2] = Screen('OpenWindow',screen.caliEyeScreen,screen.BgColor);
% w2 = screen.window2;
% ppd2 = pi * (screen.Rect2(3)-screen.Rect2(1)) / atan(screen.Width/screen.Distance/2) / 360;  % pixel per degree
% screen.ppd2 = ppd2;
% [CenterX2, CenterY2] = RectCenter(screen.Rect2);

fps = Screen('FrameRate',w1);                      % frames per second, depend on monitor refresh rate
ifi = Screen('GetFlipInterval', w1);               % inter flip interval
if ifi==0
    ifi=1/fps;
end
screen.fps = fps;
screen.ifi = ifi;
screen.CenterX = CenterX;
screen.CenterY = CenterY;

fixSize = round(FP.Size .* screen.ppd);

%% Calculate time in frame:
% Pre_FP.NeedToFixDuration_Frames  = round(Pre_FP.NeedToFixDuration/ 1000 / ifi);
Pre_FP.maxDuration_Frames = round(Pre_FP.maxDuration/ 1000 / ifi);

% generate rand frame in each trial
for i = 1:num_trial
    FP.OnDur(i) = randi(FP.OnDurRange); 
    FP.OffDur(i) = randi(FP.OffDurRange);

    FP.OnFrames(i) = round(FP.OnDur(i) /1000 / ifi);
    FP.OffFrames(i) = round(FP.OffDur(i) /1000 / ifi);
end
Sti.Frames = round(Sti.Duration /1000 / ifi);

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
%%
for i = 1:num_trial
    Sti.IniAng(i) = 2*pi*rand(1);
    % Sti.LocYs(i) = round(Sti.Distance * sin(randi(Sti.IniAngRange)) * ppd ) + CenterY;
    % generate following sequence:
    IniAngCur = Sti.IniAng(i);
    % Generate trials based on preallocated condition sequence
    if  num_CondSec(i) == 1 % counterclockwise
        for j = 1:Sti.Frames
            Sti.PathXs(i,j) = Sti.Distance* cos(IniAngCur)*ppd + CenterX;
            Sti.PathYs(i,j) = Sti.Distance* sin(IniAngCur)*ppd + CenterY;
            IniAngCur = IniAngCur + Sti.Speed*ifi;
        end
    elseif num_CondSec(i) == 2 %clockwise
        for j = 1:Sti.Frames
            Sti.PathXs(i,j) = Sti.Distance* cos(IniAngCur)*ppd + CenterX;
            Sti.PathYs(i,j) = Sti.Distance* sin(IniAngCur)*ppd + CenterY;
            IniAngCur = IniAngCur - Sti.Speed*ifi;
        end
    end
end
Sti.WindowPixel = round(Sti.WindowSize * ppd );

%% preallocatioon space for eye location storage

%% run trials:
BreakSession = 0;

while 1
    [~,~,Key_press] = KbCheck;

    text1 = double('Task Instruction');
    text2 = double('There will be a circle at the cennter of the screen, then another circle moving around the center');
    text3 = double('Please keep you head stable and watch the scenter. Watch the moving circle quickly and correctly after the center circle disappear');
    Screen('DrawText',w1,text1,CenterX - 100,CenterY-50,[255 255 255]);
    Screen('DrawText',w1,text2,CenterX - 500,CenterY,[255 255 255]);
    Screen('DrawText',w1,text3,CenterX - 700,CenterY+50,[255 255 255]);
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
state_Sti_flag = 0;
state_Resp_flag = 0;

for i_trial = 1:num_trial

    % Eye data recordindata.trial{trialNo}.g
 

    %% state: Pre-FP
    if state_PreFP_flag == 1
        for i_frame = 1:Pre_FP.maxDuration_Frames
            % plot fixation point
            Screen('DrawDots', w1, [FP.LocX; FP.LocY], FP.sizePixel, FP.Color, [], 2);

            % record eye data
            % detect location

            
            % update screen 
            Screen('Flip', w1);

            % detect break session
            [ ~, ~, keyCode ] = KbCheck;
            if keyCode(esc_key)
                BreakSession=1;
                break;
            end
        end
        % start next state
        state_PreFP_flag = 0;
        state_FP_flag = 1;
    end

    %% state: FP

    if state_FP_flag == 1
        for i_frame = 1:FP.OnFrames(i_trial)
            % plot fixation point
            Screen('DrawDots', w1, [FP.LocX; FP.LocY], FP.sizePixel, FP.Color, [], 2);

            % record eye data
            % detect location

            % update screen
            Screen('Flip', w1);

            % detect break session
            [ ~, ~, keyCode ] = KbCheck;
            if keyCode(esc_key) 
                BreakSession=1;
                break;
            end
        end 
        state_FP_flag = 0;
        state_Sti_flag = 1;
    end

    %% state: Sti onset
    if state_Sti_flag == 1
        
        tic
        for i_frame = 1:Sti.Frames
            
            % plot fixation point before gocue
            if i_frame <= FP.OffFrames(i_trial)
                Screen('DrawDots', w1, [FP.LocX; FP.LocY], FP.sizePixel, FP.Color, [], 2);
            end
            if i_frame == FP.OffFrames(i_trial)+1
                toc
            end 
            % StiRect = CenterRectOnPointd([0 0 Sti.Distance Sti.Distance]*ppd, ...
            %     Sti.PathXs(i_trial,i_frame), Sti.PathYs(i_trial,i_frame));
            % Screen('FillOval',w1 ,Sti.Color,StiRect);
            Screen('DrawDots', w1, [Sti.PathXs(i_trial,i_frame), Sti.PathYs(i_trial,i_frame)],...
                Sti.sizePixel, Sti.Color, [], 2);

            % update screen
            Screen('Flip', w1);

            % detect break session
            [ ~, ~, keyCode ] = KbCheck;
            if keyCode(esc_key)
                BreakSession=1;
                break;
            end
            % WaitSecs(0.1);
        end
        state_Sti_flag = 0;
        state_Resp_flag = 1;
    end

    %% state Response, center target offset

    if state_Resp_flag == 1
        
        state_Resp_flag = 0;
        state_PreFP_flag = 1;

    end

    %% break session

    if keyCode(esc_key)
        BreakSession=1;
        break;
    end

    if BreakSession == 1
        makeBeep;
        break;
    end

    %% clear and wait ITI
    % Clear the screen
    Screen('FillRect', w1, screen.BgColor);
    Screen('Flip', w1);

    % Wait for a random interval before the next trial
    interTrialInterval = rand(1) + 1;  % Random interval between 1 and 2 seconds
    WaitSecs(interTrialInterval);

end

sca












