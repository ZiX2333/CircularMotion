% this code uss to read circular motion

% Reading the datafile
% this Code is used for reading the recording datafile and generate a new
% organized data file
% Contains Trial Number, Block Num, Trial Status, Trial Type
% Trial Start Time, Target on time, Target Off Time, Delay duration
% Target Speed, Target Direction, Target Starting location
% Eye used, Gaze data

% in the current code, no result output record trial type. Which will
% improve later Aug 09 2023

% adjusted on Sep 04, add real time target location check.

%% load data
load('zx07_040923_rawData.mat');

% trial_NumAll = size(EyeData.trial,1) * size(EyeData.trial,2);

%% Deal with FEVENT
% count the write in number
iWrite = 0;
% Start to read following Eyelink info
ReadFlag = 0;
% Each trials' start Event
iEventS = 0;
% Each trials' end Event
iEventE = 0;

for iEvent = 1:size(edfStruct.FEVENT,2)
    % a start of new trial should contain 'BLOCKID', use this to find each
    % trial

    if ~isempty(strfind(edfStruct.FEVENT(iEvent).message, 'BLOCKID'))
        iWrite = iWrite + 1;
        % trial Start, Readflag = 1
        ReadFlag = 1;
        iEventS = iEvent;
        % define this trial
        DataEdf(iWrite).message = nan; 
        DataEdf(iWrite).sttimeTS = nan; % Trial Start Time
        DataEdf(iWrite).sttime0 = nan; % Eyelink Start Recording Time
        DataEdf(iWrite).sttime1 = nan; % Fixation Point Appear Time
        DataEdf(iWrite).sttime2 = nan; % Fixation acquired, Start Fixation Time
        DataEdf(iWrite).sttime3 = nan; % Stimulus Appear Time
        DataEdf(iWrite).sttime4 = nan; % Gocue Time/ Fixation Off Time
        DataEdf(iWrite).sttime5 = nan; % Smooth Pursuit Start Time
        DataEdf(iWrite).sttime6 = nan; % Saccade Start Time
        DataEdf(iWrite).sttime7 = nan; % Saccade End Time
        DataEdf(iWrite).sttime8 = nan; % Trial End Time
        DataEdf(iWrite).TrialStatus = 1; % Trial Status, 1 means complete 0 means break

        DataEdf(iWrite).message = edfStruct.FEVENT(iEvent).message;
        % Trial Start time
        DataEdf(iWrite).sttimeTS = double(edfStruct.FEVENT(iEvent).sttime);
    end

    if ReadFlag == 1
        % just after the start of a trial
        if ~isempty(strfind(edfStruct.FEVENT(iEvent).message, '!MODE '))
            % Eyelink start record time
            DataEdf(iWrite).sttime0 = double(edfStruct.FEVENT(iEvent).sttime);

        % Fixation point appear time
        elseif ~isempty(strfind(edfStruct.FEVENT(iEvent).message, 'FRAME_NUM 1, StateI 1'))
            % Fixation Point appear time
            DataEdf(iWrite).sttime1 = double(edfStruct.FEVENT(iEvent).sttime);

        % Fixation aquired time, start fixation
        elseif ~isempty(strfind(edfStruct.FEVENT(iEvent).message, 'FRAME_NUM 1, StateI 2'))
            % Stimulus Appear time
            DataEdf(iWrite).sttime2 = double(edfStruct.FEVENT(iEvent).sttime);

        % Stimulus appear time, fixation acquired
        elseif ~isempty(strfind(edfStruct.FEVENT(iEvent).message, 'FRAME_NUM 1, StateI 3'))
            % Stimulus Appear time
            DataEdf(iWrite).sttime3 = double(edfStruct.FEVENT(iEvent).sttime);

        % Fixation off, delay aquired, gocue time
        elseif ~isempty(strfind(edfStruct.FEVENT(iEvent).message, 'FRAME_NUM 1, StateI 4'))
            % Go cue time
            DataEdf(iWrite).sttime4 = double(edfStruct.FEVENT(iEvent).sttime);

        % Enter sti win, smooth pursuit start time
        elseif ~isempty(strfind(edfStruct.FEVENT(iEvent).message, 'FRAME_NUM 1, StateI 5'))
            % Go cue time
            DataEdf(iWrite).sttime5 = double(edfStruct.FEVENT(iEvent).sttime);

        % Start and end of Saccade time (by Eyelink)
        elseif ~isempty(strfind(edfStruct.FEVENT(iEvent).codestring, 'ENDSACC'))
            % Stimulus Appear time
            DataEdf(iWrite).sttime6 = double(edfStruct.FEVENT(iEvent).sttime);
            DataEdf(iWrite).sttime7 = double(edfStruct.FEVENT(iEvent).entime);

        % Trial Status
        elseif ~isempty(strfind(edfStruct.FEVENT(iEvent).message, 'TRIAL RESULT 0'))
            % Trial end time
            DataEdf(iWrite).TrialStatus = 0;

        % Trial end
        elseif ~isempty(strfind(edfStruct.FEVENT(iEvent).message, 'BLANK_SCREEN'))
            % Trial end time
            DataEdf(iWrite).sttime8 = double(edfStruct.FEVENT(iEvent).sttime);
            % Trial stops, readflag = 0
            ReadFlag = 0;
            iEventE = iEvent;
            DataEdf(iWrite).AllEvent = edfStruct.FEVENT(iEventS:iEventE);
        end
    end
end

%% write in struct

% TarPathX = [Sti.PathXs{1};Sti.PathXs{2};Sti.PathXs{3}];
% TarPathY = [Sti.PathYs{1};Sti.PathYs{2};Sti.PathYs{3}];
for iTrial = 1:length(DataEdf)
    %% Trial info

    % Trial Number
    Dataf(iTrial).TrialNumAll = iTrial;

    % Block Number
    Block_TrialNum = regexp(DataEdf(iTrial).message, '\d+', 'match');
    Dataf(iTrial).BlockNum = str2double(Block_TrialNum{1});
    Dataf(iTrial).TrialNum = str2double(Block_TrialNum{2});

    % Trial Status
    TimeSeq = [];
    TimeSeq = cat(2,DataEdf(iTrial).sttimeTS, DataEdf(iTrial).sttime0, DataEdf(iTrial).sttime1, ...
        DataEdf(iTrial).sttime2, DataEdf(iTrial).sttime3, DataEdf(iTrial).sttime4, DataEdf(iTrial).sttime5, ...
        DataEdf(iTrial).sttime6, DataEdf(iTrial).sttime7, DataEdf(iTrial).sttime8);
    Dataf(iTrial).TrialStatus = 0;
    % TrialStatus = 1, completed
    % TrialStatus = 2, error before/during fixation onset
    % TrialStatus = 3, error before stimulus onset
    % TrialStatus = 4, error before gocue onset
    % TrialStatus = 5, error before smooth pursuit
    % TrialStatus = 6, eyelink recording error
    % TrialStatus = 7, start Trial Error
    % TrialStatus = 0, error can't explain
    if DataEdf(iTrial).TrialStatus == 0
        for iTimeSeq = 1:length(TimeSeq)-3
            if isnan(TimeSeq(iTimeSeq)) && iTimeSeq > 2
                Dataf(iTrial).TrialStatus = iTimeSeq-2;
                break;
            elseif isnan(TimeSeq(iTimeSeq)) && iTimeSeq == 2 % TrialStatus error before fixation onset
                Dataf(iTrial).TrialStatus = iTimeSeq;
                break;
            elseif isnan(TimeSeq(iTimeSeq)) && iTimeSeq == 1 % eyelink recording error
                Dataf(iTrial).TrialStatus = length(TimeSeq)-3 +1;
                break;
            elseif isnan(TimeSeq(iTimeSeq)) && iTimeSeq == 0 % Start Trial Error
                Dataf(iTrial).TrialStatus = length(TimeSeq)-3 +2;
                break;
            end
        end
    else
        if sum(isnan(TimeSeq(1:length(TimeSeq)-3))) >=1
            Dataf(iTrial).TrialStatus = 0; % error can't explain
        elseif sum(isnan(TimeSeq(1:length(TimeSeq)-3))) == 0
            Dataf(iTrial).TrialStatus = 1; % No error!
        end
    end

    % Trial Type
    % rem = 1 counter clock wise?
    % rem = 2 clockwise
    % rem = 0 control
    Dataf(iTrial).TrialType = num_CondSec(iTrial);

    %% Time info
    % Trial Event Time Sequence
    % 1/TS Trial Start Time
    % 2/0 Eyelink Start Recording Time
    % 3/1 Fixation Point Appear Time
    % 4/2 Start Fixation Time
    % 5/3 Stimulus Appear Time
    % 6/4 Gocue Time/ Fixation Off Time
    % 7/5 Smooth Pursuit Start Time
    % 8/6 Saccade Start Time
    % 9/7 Saccade End Time
    % 10/8 Trial End Time
    Dataf(iTrial).TimeSeq = TimeSeq;

    % Trial Fixation Onset Time toward Eyelink Start Time
    Dataf(iTrial).TimeFixOn1 = Dataf(iTrial).TimeSeq(3) - Dataf(iTrial).TimeSeq(2);

    % Subject look at the fixation point, Fixation latency
    Dataf(iTrial).TimeFixOn2 = Dataf(iTrial).TimeSeq(4) - Dataf(iTrial).TimeSeq(2);

    % Trial Target Onset Time toward Eyelink Start Time
    Dataf(iTrial).TimeTarOn = Dataf(iTrial).TimeSeq(5) - Dataf(iTrial).TimeSeq(2);

    % Trial Gocue Onset Time toward Eyelink Start Time
    Dataf(iTrial).TimeGocOn = Dataf(iTrial).TimeSeq(6) - Dataf(iTrial).TimeSeq(2);

    % Trial Fixation Duration
    Dataf(iTrial).DurFix = Dataf(iTrial).TimeSeq(5) - Dataf(iTrial).TimeSeq(4);

    % Trial Delay Duration
    Dataf(iTrial).DurDelay = Dataf(iTrial).TimeSeq(6) - Dataf(iTrial).TimeSeq(5);

    %% Screen and Target info
    % screen
    Dataf(iTrial).ppd = screen.ppd;
    Dataf(iTrial).rect = screen.Rect;
    Dataf(iTrial).center = [screen.CenterX, screen.CenterY];

    % target speed
    % Dataf(iTrial).TarSpeed = Sti.Speed * 180/pi;
    Dataf(iTrial).TarSpeed = Sti.Vel(rem(num_CondSec(Dataf(iTrial).TrialNum,Dataf(iTrial).BlockNum),num_Cond)+1);

    % target direction
    % rem = odd Clockwise
    % rem = even Counterclockwise
    % rem = 0 control
    Dataf(iTrial).TarDir = rem(num_CondSec(Dataf(iTrial).TrialNum,Dataf(iTrial).BlockNum),num_Cond);

    % target eccentricity
    Dataf(iTrial).TarEcc = Sti.Distance;

    % fixation point location
    Dataf(iTrial).FixLocX = FP.LocX;
    Dataf(iTrial).FixLocY = FP.LocY;

    % Target Starting location, IniAng
    % Dataf(iTrial).TarIniAng = Sti.IniAng(iTrial)*180/pi;

    % Target Path
    Dataf(iTrial).TarPathXSet = zeros(2,length(Sti.PathXs{iTrial}));
    Dataf(iTrial).TarPathYSet = zeros(2,length(Sti.PathYs{iTrial}));
    Dataf(iTrial).TarPathAngSet = zeros(2,length(Sti.PathAngs{iTrial}));

    Dataf(iTrial).TarPathXSet(1,:) = Sti.PathXs{iTrial};
    Dataf(iTrial).TarPathYSet(1,:) = Sti.PathYs{iTrial};
    Dataf(iTrial).TarPathAngSet(1,:) = Sti.PathAngs{iTrial};

    iTime = [];
    for iEvent = 1:length(DataEdf(iTrial).AllEvent)
        if ~isempty(strfind(DataEdf(iTrial).AllEvent(iEvent).message, 'StateI 3'))
            iTime = [iTime,DataEdf(iTrial).AllEvent(iEvent).sttime];
        elseif ~isempty(strfind(DataEdf(iTrial).AllEvent(iEvent).message, 'StateI 4'))
            iTime = [iTime,DataEdf(iTrial).AllEvent(iEvent).sttime];
        elseif ~isempty(strfind(DataEdf(iTrial).AllEvent(iEvent).message, 'StateI 5'))
            iTime = [iTime,DataEdf(iTrial).AllEvent(iEvent).sttime];
        end
    end
    
    Dataf(iTrial).TarPathXSet(2,1:length(iTime)) = iTime-Dataf(iTrial).TimeSeq(2);
    Dataf(iTrial).TarPathYSet(2,1:length(iTime)) = iTime-Dataf(iTrial).TimeSeq(2);
    Dataf(iTrial).TarPathAngSet(2,1:length(iTime)) = iTime-Dataf(iTrial).TimeSeq(2);

    % Target path in real time
    Dataf(iTrial).TarPathXReal = [];
    Dataf(iTrial).TarPathYReal = [];
    Dataf(iTrial).TarPathAngReal = [];

    iTime = [];
    for iEvent = 1:size(DataEdf(iTrial).AllEvent,2)
        x_pattern = [];
        y_pattern = [];
        ang_pattern = [];
        x_value = [];
        y_value = [];
        ang_value = [];

        if ~isempty(strfind(DataEdf(iTrial).AllEvent(iEvent).message, 'Targ_POS'))
            % extrac the number in the str
            x_pattern = 'X\s+(-?\d+\.?\d*)';
            y_pattern = 'Y\s+(-?\d+\.?\d*)';
            ang_pattern = 'Ang\s+(-?\d+\.?\d*)';
            x_value = str2double(regexp(DataEdf(iTrial).AllEvent(iEvent).message, x_pattern, 'tokens', 'once'));
            y_value = str2double(regexp(DataEdf(iTrial).AllEvent(iEvent).message, y_pattern, 'tokens', 'once'));
            ang_value = str2double(regexp(DataEdf(iTrial).AllEvent(iEvent).message, ang_pattern, 'tokens', 'once'));
            
            % Record the time info
            iTime = DataEdf(iTrial).AllEvent(iEvent).sttime-Dataf(iTrial).TimeSeq(2);

            % Write in the real time sequence
            Dataf(iTrial).TarPathXReal = [Dataf(iTrial).TarPathXReal, [x_value;iTime]];
            Dataf(iTrial).TarPathYReal = [Dataf(iTrial).TarPathYReal, [y_value;iTime]];
            Dataf(iTrial).TarPathAngReal = [Dataf(iTrial).TarPathAngReal, [ang_value;iTime]];
        end
    end

    %% Gaze info

    % eye used
    % 0 = left
    % 1 = right
    Dataf(iTrial).EyeUsed = EyeData.trial{iTrial}.eyeUsed;

    % Gaze time trian
    Dataf(iTrial).EyeTime = edfStruct.FSAMPLE.time(1,find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(2),1,'first'):...
        find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(10),1,'last'));

    % Gaze location
    Dataf(iTrial).EyeLocX = edfStruct.FSAMPLE.gx(Dataf(iTrial).EyeUsed+1,find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(2),1,'first'):...
        find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(10),1,'last'));
    Dataf(iTrial).EyeLocY = edfStruct.FSAMPLE.gy(Dataf(iTrial).EyeUsed+1,find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(2),1,'first'):...
        find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(10),1,'last'));
    % find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(2),1,'first');
    % find(edfStruct.FSAMPLE.time == Dataf(iTrial).TimeSeq(9),1,'last');
end

%%
clearvars -except DataEdf Dataf Sti FP Pre_FP screen
save('zx07_040923_PreProcessed1.mat','-v7.3')