% This code is used for the first step of processing the data
% In this code, I will read the target lcoation and eye movement data and
% trial information from the psychotoolbox data and trellis data.
% Trial information will come from the psychotollbox data, and eye movement
% data will come fomr trellis. Before combine these two data together, I
% will also adjust the timeline based on the photodiode data.

% 05-06-24: Create the file. Xuan
% 10-30-24: Keep editing... I really don't want to write this. Xuan
% 01-21-25: Keep editing... I don't know what I'm doing. Xuan
% 01-23-25: Add Saccade detection part. Xuan
% 02-05-25: Adjust the photodiode states alignment. Xuan
% 02-05-25: Adjust the target position writting in a more appropriate way. Xuan
% 02-05-25: Adjust the saccade detection based on Goettker, A., & Gegenfurtner, K. R. (2024)

%% load data
load('e.mat');
%% Align the Psychtoolbox and Trellis data
% Save two data file into new valueables
Subject = e.subject_name;
PsyTBD = struct2table(e.trial);
TlisD = struct2table(data_epoch);

% delete the lines that no trellis data is recording (why will have lines like this?)
if iscell(PsyTBD.trellis_trial_number)
    eptRows = cellfun(@isempty, PsyTBD.trellis_trial_number);
else
    eptRows = isempty(PsyTBD.trellis_trial_number);
end
PsyTBD(eptRows, :) = [];

% transfer the trellis trial number into mat not struct and sort based on it
if iscell(PsyTBD.trellis_trial_number)
    PsyTBD.trellis_trial_number = cell2mat(PsyTBD.trellis_trial_number);
end
PsyTBD = sortrows(PsyTBD, 'trellis_trial_number');

% Compare psyTB and trellis data to see if mathch and remove the unmatched one
PsyTBnumT = PsyTBD.trellis_trial_number;
TlisnumT = (1:size(TlisD,1))';

if length(TlisnumT) < length(PsyTBnumT)
    % if trellis recordings shorter, stop the code and check what's going on
    warning('Trellis recodings shorter than PsyTB records on trellis data');
    error('Trellis recodings must be the same or longer than PsyTB recordings');
elseif length(TlisnumT) > length(PsyTBnumT)
    % remove the unmatched trials in trellis recoding
    unmatchRows = setdiff(TlisnumT, PsyTBnumT);
    TlisD(unmatchRows,:) = [];
end

%% Start writing the Datax:
Datax.trialNum = PsyTBD.trellis_trial_number;
Datax.trialType = PsyTBD.ttype;
% write the target anuglar speed
for iTrial = 1:size(PsyTBD,1)
    TargetNames = [];
    TargetNames = fieldnames(PsyTBD.targets{iTrial});
    % I only cares about the last name
    Datax.TargVel(iTrial,1) = PsyTBD.targets{iTrial}.(TargetNames{end}).speed;
end
% Assgin the trail group... now that occupy this column
Datax.trialGrp = zeros(size(PsyTBD,1),1);
Datax.trialST = PsyTBD.tstarttime; % recorded in s
Datax.trialED = PsyTBD.tstoptime;  % recorded in s
% errType: 1 (success), 0 (trial break), 2 (system errors), 3 (saccade
% errors)
Datax.trialErr = ones(size(PsyTBD,1),1); % trial error type, willbe explain later
Datax.state = PsyTBD.state; % each experiment state
Datax = struct2table(Datax);

%% Assign Trial Groups
% Step: 0; Sta 1, CCW108 2, CCW215 3, CCW323 4, CW-108 5, CW-215 6, CW-323 7
for iTrial = 1:size(PsyTBD,1)
    if contains(Datax.trialType{iTrial},'Step')
        continue
    else
        switch Datax.TargVel(iTrial)
            case 0
                Datax.trialGrp(iTrial) = 1;
            case 108
                Datax.trialGrp(iTrial) = 2;
            case 215
                Datax.trialGrp(iTrial) = 3;
            case 323
                Datax.trialGrp(iTrial) = 4;
            case -108
                Datax.trialGrp(iTrial) = 5;
            case -215
                Datax.trialGrp(iTrial) = 6;
            case -323
                Datax.trialGrp(iTrial) = 7;
        end
    end

end

%% write the psyTB photodiode, Trellis photodiode and aligned flags
% the 1st colomn record the time based on psyTB time
% the 2nd colomn is the 1st colomn but alined with the lag between PTB and trellis
% the 3rd colomn is the photodiode flip time based on the second colomn
% the 4th colom is to fill up the pdd gap base on 2 and 3rd colomn, why Im doing this?
for iTrial = 1:size(Datax,1)
    % write the psyTB photodiode time
    if iscell(PsyTBD.data)
        Datax.stateReal{iTrial} = PsyTBD.data{iTrial}.DiodeFlipStates;
        Datax.pddPsyTB{iTrial} = PsyTBD.data{iTrial}.photodiode;
    else
        Datax.stateReal{iTrial} = PsyTBD.data(iTrial).DiodeFlipStates;
        Datax.pddPsyTB{iTrial} = PsyTBD.data(iTrial).photodiode;
    end
    Datax.pddTlis{iTrial} = TlisD.photodiode{iTrial};
    Datax.pddTlisBi{iTrial} = TlisD.photodiode_bi{iTrial};

    % align the time, first align the psyTB time
    curstate = [];
    curstate = struct2cell(PsyTBD.state{iTrial});
    curstateTime = zeros(length(curstate),1);
    for iState = 1:length(curstate)
        if iscell(Datax.trialST)
            curstateTime(iState) = curstate{iState}.time - Datax.trialST{iTrial};
        else
            curstateTime(iState) = curstate{iState}.time - Datax.trialST(iTrial);
        end
    end
    % 1
    % the first colomn record the time based on psyTB time
    Datax.FlagTimeAl{iTrial} = curstateTime*1000;

    % psyTB and trellis also have a time difference, we need to find that and shift the time
    % make sure the xcorr is used for signals centered on zero
    % Compute cross-correlation
    c = []; lags = []; I = []; shiftTime = [];
    [c, lags] = xcorr(zscore(Datax.pddTlis{iTrial}), zscore(Datax.pddPsyTB{iTrial}));
    [~, I] = max(c); % Find the peak in the cross-correlation
    shiftTime = lags(I);
    % 2
    % the second colomn is the 1st colomn but alined with the lag between PTB and trellis
    Datax.FlagTimeAl{iTrial} = [Datax.FlagTimeAl{iTrial},Datax.FlagTimeAl{iTrial,1} + shiftTime];

    % % align with the Photodiode time
    % define the third row as nan colomn
    % 3
    % the third colomn is the photodiode flip time based on the second colomn
    Datax.FlagTimeAl{iTrial} = [Datax.FlagTimeAl{iTrial},nan(size(Datax.FlagTimeAl{iTrial},1),1)];
    % since currently the trial start time maybe incorrect, I will just put all the pdd event in
    pddTlisD = []; stateIdeal = []; stateReal = []; stateCheck = [];
    pddTlisD = TlisD.photodiode_event{iTrial}';
    % assign the value
    stateIdeal = fieldnames(Datax.state{iTrial});
    stateCheck = zeros(size(stateIdeal));
    stateReal = Datax.stateReal{iTrial};

    % remove the last one if the real state number is odd. Becuase the system
    % will add one more after odd number to make sure the pdd always changes
    % to zero (numbers change is even) --> turns out not 
    % Also some trials start with stop_autogenerated, I'm also account for that
    % if the stateReal and pddTlisD not match, check pddTlisbi start with zero or one
    if length(stateReal)~= length(pddTlisD)
        % check this one add at the beginning or at the end
        if Datax.pddTlisBi{iTrial}(1) == 1
            pddTlisD(1) = [];
        else
            pddTlisD(end) = [];
        end
        % pddTlisD(1) = [];
    end
    % check if the stateReal start with "stop_autogenerated", some trials does
    if strcmp('stop_autogenerated', stateReal{1}) == 1
        stateReal(1) = [];
        Datax.stateReal{iTrial}(1) = [];
        pddTlisD(1) = [];
    end
    % check the assigned states and real displayed states
    for iState = 1:length(stateIdeal)
        isDisp = any(cellfun(@(x) any(strcmp(x, stateIdeal{iState})), stateReal));
        if isDisp
            stateCheck(iState) = 1;
        end
    end
    stateCheck = logical(stateCheck);
    % now i get the state Check, I'm going to assign value that is true in state Check
    if length(pddTlisD) <= size(Datax.FlagTimeAl{iTrial},1)
        Datax.FlagTimeAl{iTrial}(stateCheck,3) = pddTlisD;
    else
        % some trials the pdd start from a super low number (like trial 914 from Blog 05102024 data)
        % to solve this I need to re check the pdd traces
        % right now I'm going to skip these trials
        continue
    end
end

%% Mark important events & fill in the gap of above section
% Different event time:
% T0_reach: fixation point onset time
% T0_hold:  eye enters the fixation point window
% delay_state: delay target onset state
% RT_state: Delay moving target gocue state
% T1_reach: stationary target gocue state
% T1_hold: eye enters the target window
% consider the trials into three groups:
% step_stationary, delay_stationary, delay_moving

for iTrial = 1:size(Datax,1)
    stateReal = []; FlagTime = []; stateSent = [];
    stateReal = Datax.stateReal{iTrial};
    stateSent = fieldnames(Datax.state{iTrial});
    FlagTime = Datax.FlagTimeAl{iTrial}(~isnan(Datax.FlagTimeAl{iTrial}(:,3)),3);
    if isempty(FlagTime) && ~isempty(stateReal)
        Datax.trialErr(iTrial) = 2; % weird system errors
        continue
    end

    % check if displayed state contains T1 reach, not means trial break
    if any(contains(stateSent,'T1_reach'))
        % for all the step trials
        if contains(Datax.trialType{iTrial},'Step')
            % check if displayed state contains T1 reach, not means trial break
            % if there is no T0_hold or T1_hold
            if sum(contains(stateReal,'T0_hold')) == 0 || sum(contains(stateReal,'T1_hold')) == 0
                Datax.trialErr(iTrial) = 2;
                continue
            end
            % check the FixOn Event, T0_reach may combined with T0_hold
            FixOnNum = find(contains(stateReal,'T0_reach'));
            if isempty(FixOnNum)
                FixOnNum = find(contains(stateReal,'T0_hold'));
            end
            % check the Fixation Interval Start Num
            FixItvSNum = find(contains(stateReal,'T0_hold'));
            % check the Fix Itv off Num, T1_reach may combined with T1_hold
            % This is also target on time
            FixItvENum = find(contains(stateReal,'T1_reach'));
            if isempty(FixItvENum)
                FixItvENum = find(contains(stateReal,'T1_hold'));
            end
            % check the Go cue num, T1_reach may combined with T1_hold
            GoCueNum = find(contains(stateReal,'T1_reach'));
            if isempty(GoCueNum)
                GoCueNum = find(contains(stateReal,'T1_hold'));
            end

        % for all the stationary trials
        elseif contains(Datax.trialType{iTrial},'Sta')
            % if there is no T0_hold or T1_reach
            if sum(contains(stateReal,'T0_hold')) == 0 || sum(contains(stateReal,'T1_reach')) == 0
                Datax.trialErr(iTrial) = 2;
                continue
            end
            % check the FixOn Event, T0_reach may combined with T0_hold
            FixOnNum = find(contains(stateReal,'T0_reach'));
            if isempty(FixOnNum)
                FixOnNum = find(contains(stateReal,'T0_hold'));
            end
            % check the Fixation Interval Start Num
            FixItvSNum = find(contains(stateReal,'T0_hold'));
            % check the Fix Itv off Num, Delay may combined with T1_reach
            % this is also target on time
            FixItvENum = find(contains(stateReal,'delay'));
            if isempty(FixItvENum)
                FixItvENum = find(contains(stateReal,'T1_reach'));
            end
            % check the Go cue num
            GoCueNum = find(contains(stateReal,'T1_reach'));

        % for all the moving trials
        else
            % if there is no T0_hold or RT
            if sum(contains(stateReal,'T0_hold')) == 0 || sum(contains(stateReal,'RT')) == 0
                Datax.trialErr(iTrial) = 2;
                continue
            end
            % check the FixOn Event, T0_reach may combined with T0_hold
            FixOnNum = find(contains(stateReal,'T0_reach'));
            if isempty(FixOnNum)
                FixOnNum = find(contains(stateReal,'T0_hold'));
            end
            % check the Fixation Interval Start Num
            FixItvSNum = find(contains(stateReal,'T0_hold'));
            % check the Fix Itv off Num, Delay may combined with RT
            % this is also target on time
            FixItvENum = find(contains(stateReal,'delay'));
            if isempty(FixItvENum)
                % could be RT_state or RT1_state
                FixItvENum = find(contains(stateReal,'RT'),1);
            end
            % check the Go cue num
            GoCueNum = find(contains(stateReal,'RT'),1);
        end
    else
        Datax.trialErr(iTrial) = 0;
        continue
    end
    % assign the value to datax
    Datax.FixOnTime(iTrial) = FlagTime(FixOnNum);
    Datax.FixItvSTime(iTrial) = FlagTime(FixItvSNum);
    Datax.TargOnTime(iTrial) = FlagTime(FixItvENum);
    Datax.GoCueTime(iTrial) = FlagTime(GoCueNum);
    Datax.FixItv(iTrial) = Datax.TargOnTime(iTrial) - Datax.FixItvSTime(iTrial);
    Datax.Delay(iTrial) = Datax.GoCueTime(iTrial) - Datax.TargOnTime(iTrial);
end

%% write trial and target information
% since I'm working on 1 step saccade, so I will only write T0 location and
% T1 location, and the timestamp for T1 location (will be very important in
% moving conditions. and what every it is stored in polar or cartesian, I
% will all transform to cartesian
% x,y,theta,r, (all theta wrap to 2pi)
% Then Im going to find the time stamp and real displayed target location
% based on the alignment between grap_fliptime and time stamp.
% Grap flip time use the first row
% Then I'm going to add target velocity, delay time, fixational interval,
% target initial location, target location at gocue
for iTrial = 1:size(Datax,1)
    % for iTrial = 130
    TargetNames = fieldnames(PsyTBD.targets{iTrial});
    shiftTime = Datax.FlagTimeAl{iTrial}(1,2) - Datax.FlagTimeAl{iTrial}(1,1);
    if iscell(Datax.trialST)
        TrialST = Datax.trialST{iTrial};
    else
        TrialST = Datax.trialST(iTrial);
    end
    for iNames = 1:length(TargetNames)
        % check if is cartesian or polar for Targets
        % then check if this is for stationary or for moving
        % Then record the location
        % Target Loc seq: x, y, theta, R
        loctemp1 = []; loctemp2 = [];
        if strcmp(PsyTBD.targets{iTrial}.(TargetNames{iNames}).degreestype,'cartesian')
            if contains(Datax.trialType{iTrial},'CW')
                loctemp1 = PsyTBD.targets{iTrial}.(TargetNames{iNames}).moving_position;
            else
                loctemp1 = PsyTBD.targets{iTrial}.(TargetNames{iNames}).position;
            end
            % if no data present skip
            if isempty(loctemp1)
                continue
            end
            [loctemp2(:,1),loctemp2(:,2)] = cart2pol(loctemp1(:,1),loctemp1(:,2));
            loctemp2(:,1) = wrapTo2Pi(loctemp2(:,1));
            Datax.(['T',mat2str(iNames-1),'Loc']){iTrial} = [loctemp1,loctemp2];
        else
            if contains(Datax.trialType{iTrial},'CW')
                loctemp1 = PsyTBD.targets{iTrial}.(TargetNames{iNames}).moving_position;
            else
                loctemp1 = PsyTBD.targets{iTrial}.(TargetNames{iNames}).position;
            end
            % if no data present skip
            if isempty(loctemp1)
                continue
            end
            loctemp1(:,1) = wrapTo2Pi(deg2rad(loctemp1(:,1)));
            [loctemp2(:,1),loctemp2(:,2)] = pol2cart(loctemp1(:,1),loctemp1(:,2));
            Datax.(['T',mat2str(iNames-1),'Loc']){iTrial} = [loctemp2,loctemp1];
        end

        % record the target time info
        % time stamp need to remove start time and add the shift time
        Datax.(['T',mat2str(iNames-1),'Time']){iTrial} = ...
            (PsyTBD.targets{iTrial}.(TargetNames{iNames}).timestamp' - TrialST).*1000 + shiftTime;
    end
    GrapFlipTime = [];
    if ~isempty(PsyTBD.data{iTrial}.graphics_fliptimes)
        if isstruct(PsyTBD.data{iTrial}.graphics_fliptimes)
            if ischar(PsyTBD.data{iTrial}.graphics_fliptimes.fliptimes)
                GrapFlipTime = (str2num(PsyTBD.data{iTrial}.graphics_fliptimes.fliptimes)'- TrialST).*1000 + shiftTime;
            else
                GrapFlipTime = (PsyTBD.data{iTrial}.graphics_fliptimes.fliptimes'- TrialST).*1000 + shiftTime;
            end
        else
            GrapFlipTime = (PsyTBD.data{iTrial}.graphics_fliptimes(1,:)'- TrialST).*1000 + shiftTime;
        end
    end
    Datax.GFlipTime{iTrial} = GrapFlipTime;

    % Then I need to record the target real displayed location
    for iNames = 1:length(TargetNames)
        Datax.(['T',mat2str(iNames-1),'LocReal']){iTrial} = [];
        Datax.(['T',mat2str(iNames-1),'TimeReal']){iTrial} = [];
        if isempty(Datax.(['T',mat2str(iNames-1),'Time']){iTrial})
            % empty means it probably is an stationary target, or error
            Datax.(['T',mat2str(iNames-1),'LocReal']){iTrial} = Datax.(['T',mat2str(iNames-1),'Loc']){iTrial};
            Datax.(['T',mat2str(iNames-1),'TimeReal']){iTrial} = [];
        else
            % find the time that close to the displayed time
            TTime = [];
            TTime = Datax.(['T',mat2str(iNames-1),'Time']){iTrial};
            TTime(:,2) = nan(size(TTime));
            for iTime = 1:length(GrapFlipTime)
                diffTemp = GrapFlipTime(iTime) - TTime(:,1);
                if isempty(min(diffTemp(diffTemp>0)))
                    continue
                else
                    minLoc = find(diffTemp == min(diffTemp(diffTemp>0)),1);
                end
                % abs diff is smaller than 100ms can be writen in
                % maybe 100ms
                if diffTemp(minLoc) > 100
                    % larger than thres just continue
                    continue
                elseif isnan(TTime(minLoc,2))
                    % if there is no data occupy, just write in
                    TTime(minLoc,2) = diffTemp(minLoc);
                    % write in
                    TarNum = length(TTime(~isnan(TTime(:,2)),2));
                    Datax.(['T',mat2str(iNames-1),'LocReal']){iTrial}(TarNum,:) = ...
                        Datax.(['T',mat2str(iNames-1),'Loc']){iTrial}(minLoc,:);
                    Datax.(['T',mat2str(iNames-1),'TimeReal']){iTrial}(TarNum,:) = GrapFlipTime(iTime);
                elseif ~isnan(TTime(minLoc,2)) && TTime(minLoc,2) > diffTemp(minLoc)
                    % if is the new diff is smaller than current occupy
                    TTime(minLoc,2) = diffTemp(minLoc);
                    % rewrite in
                    TarNum = length(TTime(~isnan(TTime(:,2)),2));
                    Datax.(['T',mat2str(iNames-1),'LocReal']){iTrial}(TarNum,:) = ...
                        Datax.(['T',mat2str(iNames-1),'Loc']){iTrial}(minLoc,:);
                    Datax.(['T',mat2str(iNames-1),'TimeReal']){iTrial}(TarNum,:) = GrapFlipTime(iTime);
                end
            end
            % futher move the TimeReal to align with target on time
            shiftTime1 = Datax.TargOnTime(iTrial)-Datax.T1TimeReal{iTrial}(1);
            Datax.T1TimeReal{iTrial} = Datax.T1TimeReal{iTrial}+shiftTime1;
            % Dataf.(['T',mat2str(iNames-1),'LocReal']){iTrial}
        end
    end
    % I guess my question is how I suppose to match the real time with flag
    % time... and why some time only 6 states, no T1 reach and hold state
    % but correct?
end

%% adjust the Stationary target T1LocReal
for iTrial = 1:size(Datax,1)
    if Datax.trialErr ~= 1
        % do not analysis the wrong trials
        continue
    else
        % only cares about stationary target
        if contains(Datax.trialType{iTrial},'Step')
            % target on till trial stop
            TargOnTime = Datax.TargOnTime(iTrial);
            TargOffTime = Datax.FlagTimeAl{iTrial}(end,3);
            % fill in the T1TimeReal for better future code
            Datax.T1TimeReal{iTrial} = (TargOnTime:1:TargOffTime)';
            % repeat the T1LocReal
            Datax.T1LocReal{iTrial} = Datax.T1LocReal{iTrial} .* ...
                ones(length(Datax.T1TimeReal{iTrial}),length(Datax.T1LocReal{iTrial}));
        elseif contains(Datax.trialType{iTrial},'Sta')
            % target on till trial stop
            TargOnTime = Datax.TargOnTime(iTrial);
            TargOffTime = Datax.FlagTimeAl{iTrial}(end-1,3)+100;
            % fill in the T1TimeReal for better future code
            Datax.T1TimeReal{iTrial} = (TargOnTime:1:TargOffTime)';
            % repeat the T1LocReal
            Datax.T1LocReal{iTrial} = Datax.T1LocReal{iTrial} .* ...
                ones(length(Datax.T1TimeReal{iTrial}),length(Datax.T1LocReal{iTrial}));
        end
    end
end

%% Add eye location information
% pix2deg([x * xgain + xoffset;y * ygain + yoffset])
% first write in PTB eye location, then write in trellis eye location
% the time difference between them should be equal to shift time
% try butter filt and then do a reverse and feedback filtering
order = 2;      % Filter order
Fs = 1000;      % Sample rate
Fc = 30;       % Cutoff frequency
[b, a] = butter(order, Fc / (Fs/2), 'low');
% Saccade para settings
TimeReso = 1/1000; % 1000hz
VelThrs = 30; %deg/sec
DurThrs = 10; % Saccade duration threshold 10ms

for iTrial = 1:size(Datax,1)
    Datax.EyeInfo{iTrial} = PsyTBD.System_Properties{iTrial}.eye;

    % write in the PTB eye location
    Datax.EyeLocXYPTB{iTrial} = PsyTBD.data{iTrial}.eyepos';

    % write in trellis eye location
    EyeLocXTlisTemp = []; EyeLocYTlisTemp = [];
    % transfer to visual degree
    xgain = Datax.EyeInfo{iTrial}.xgain;
    xoffset = Datax.EyeInfo{iTrial}.xoffset;
    ygain = Datax.EyeInfo{iTrial}.ygain;
    yoffset = Datax.EyeInfo{iTrial}.yoffset;

    EyeLocXTlisTemp = TlisD.gazepos{iTrial}(1,:)*xgain+xoffset;
    EyeLocYTlisTemp = TlisD.gazepos{iTrial}(2,:)*ygain+yoffset;

    Datax.EyeLocXYTlis{iTrial} = pix2deg([EyeLocXTlisTemp; EyeLocYTlisTemp]')';

    % Filter eye location, x y theta r displacem dispacc
    EyeLocX = []; EyeLocY = []; EyeLocT = []; EyeLocR = [];
    EyeLocX = filtfilt(b,a,Datax.EyeLocXYTlis{iTrial}(1,:));
    EyeLocY = filtfilt(b,a,Datax.EyeLocXYTlis{iTrial}(2,:));
    [EyeLocT,EyeLocR] = cart2pol(EyeLocX,EyeLocY);
    EyeLocDisp = [0,sqrt((EyeLocX(2:end) - EyeLocX(1:end-1)).^2 + (EyeLocY(2:end) - EyeLocY(1:end-1)).^2)];
    EyeLocDispAcc = cumsum(EyeLocDisp);
    % Save all values: X Y Theta Rho Displm DisplmAccmu
    Datax.EyeLoc{iTrial} = [EyeLocX;EyeLocY;EyeLocT;EyeLocR;EyeLocDisp;EyeLocDispAcc];

    % calculate saccade velocity
    EyeVelX = zeros(size(EyeLocX));
    EyeVelY = zeros(size(EyeLocY));
    EyeVelT = zeros(size(EyeLocT));
    EyeVelR = zeros(size(EyeLocR));
    EyeVelDisp = zeros(size(EyeLocDisp));
    EyeVelDispAcc = zeros(size(EyeLocDispAcc));
    for iTime = 3:(length(EyeVelX)-2)
        EyeVelX(iTime) = (EyeLocX(iTime+2)-EyeLocX(iTime-2)+EyeLocX(iTime+1)-EyeLocX(iTime-1))/6*1000;
        EyeVelY(iTime) = (EyeLocY(iTime+2)-EyeLocY(iTime-2)+EyeLocY(iTime+1)-EyeLocY(iTime-1))/6*1000;
        EyeVelT(iTime) = (EyeLocT(iTime+2)-EyeLocT(iTime-2)+EyeLocT(iTime+1)-EyeLocT(iTime-1))/6*1000;
        EyeVelR(iTime) = (EyeLocR(iTime+2)-EyeLocR(iTime-2)+EyeLocR(iTime+1)-EyeLocR(iTime-1))/6*1000;
        EyeVelDisp(iTime) = (EyeLocDisp(iTime+2)-EyeLocDisp(iTime-2)+EyeLocDisp(iTime+1)-EyeLocDisp(iTime-1))/6*1000;
        EyeVelDispAcc(iTime) = (EyeLocDispAcc(iTime+2)-EyeLocDispAcc(iTime-2)+EyeLocDispAcc(iTime+1)-EyeLocDispAcc(iTime-1))/6*1000;
    end
    % save all velocity values
    Datax.EyeVel{iTrial} = [EyeVelX;EyeVelY;EyeVelT;EyeVelR;EyeVelDisp;EyeVelDispAcc];
    
    % Mark the EyeVel by VelThrs
    Datax.EyeVelMark{iTrial} = zeros(size(Datax.EyeVel{iTrial}));
    for iType = 1:size(Datax.EyeVel{iTrial},1)
        for iTime = 1:size(Datax.EyeVel{iTrial},2)
            if abs(Datax.EyeVel{iTrial}(iType,iTime)) >= VelThrs
                Datax.EyeVelMark{iTrial}(iType,iTime) = 1;
            end
        end
    end

    % Calculate Saccade Accelerate
    EyeAccX = zeros(size(EyeLocX));
    EyeAccY = zeros(size(EyeLocY));
    EyeAccT = zeros(size(EyeLocT));
    EyeAccR = zeros(size(EyeLocR));
    EyeAccDisp = zeros(size(EyeLocDisp));
    EyeAccDispAcc = zeros(size(EyeLocDispAcc));
    EyeAccX(2:end) = diff(EyeVelX);
    EyeAccY(2:end) = diff(EyeVelY);
    EyeAccT(2:end) = diff(EyeVelT);
    EyeAccR(2:end) = diff(EyeVelR);
    EyeAccDisp(2:end) = diff(EyeVelDisp);
    EyeAccDispAcc(2:end) = diff(EyeVelDispAcc);
    % Save all acceleration values
    Datax.EyeAcc{iTrial} = [EyeAccX;EyeAccY;EyeAccT;EyeAccR;EyeAccDisp;EyeAccDispAcc];

    % Detect Saccades
    SaccSeqInfo = cell(size(Datax.EyeLoc{iTrial},1),1);
    for iType = 1:size(Datax.EyeLoc{iTrial},1)
        TimeS1 = [];
        TimeE1 = [];
        TimeDur = [];
        PeakV = []; % Peak velocity value
        TimePV = []; % time at peak velocity
        [TimeS1,TimeE1,TimeDur,PeakV,TimePV] = SaccDetect(Datax.EyeVel{iTrial}(iType,:), ...
            Datax.EyeVelMark{iTrial}(iType,:), DurThrs);
        % saccade start time, end time, duration, Peak Vel, Time Peak V
        SaccSeqInfo{iType,1} = [TimeS1;TimeE1;TimeDur;PeakV;TimePV];
    end
    Datax.SaccSeqInfo{iTrial} = SaccSeqInfo;
end

%% Extract Saccades: only cares about saccade after gocue
% using radius to detectDatax.SacTimeGoc1Datax.SacTimeGoc1Datax.SacLocGoc1
% 1 X, 2 Y, 3 And, 4 Radius, 5 Disp, 6 Acc Disp
iColm = 4; % find Radius
for iTrial = 1:size(Datax,1)
    % assign value first
    % before gocue
    Datax.SacTimeGoc1{iTrial} = [];
    Datax.SacLocGoc1{iTrial} = [];
    Datax.SacPvelGoc1{iTrial} = [];
    % after gocue
    Datax.SacTimeGoc2{iTrial} = [];
    Datax.SacLocGoc2{iTrial} = [];
    Datax.SacPvelGoc2{iTrial} = [];
    % The way to use find:
    % find(edfStruct.FSAMPLE.time == Datax.TimeSeq(2),1,'first')

    % find the saccades before gocue
    % SaccTemp = [];
    % SaccTemp = Datax.SaccSeqInfo{3};
    % do not include peak velocity in time
    % Start time, End time, Duration, Reaction Time
    WhichC = find(Datax.SaccSeqInfo{iTrial}{iColm}(1,:)>=Datax.GoCueTime(iTrial),1,"first");
    % if not target after gocue
    if isempty(WhichC)
        continue
    end

    if WhichC > 1 % have saccade before gocue
        for iCols = 1:size(Datax.SaccSeqInfo{iTrial}{iColm},1)-2
            Datax.SacTimeGoc1{iTrial}(iCols,:) = Datax.SaccSeqInfo{iTrial}{iColm}(iCols,1:WhichC-1);
        end
        % Reaction Time: Start time - Gocue Time
        % Wait, this is not Reaction time
        Datax.SacTimeGoc1{iTrial}(iCols+1,:) = Datax.SaccSeqInfo{iTrial}{iColm}(1,1:WhichC-1)-Datax.GoCueTime(iTrial);

        % Finding the whole saccadic eye traces
        % Loc;Vel;Acc
        for iSacc = 1:WhichC-1
            Datax.SacLocGoc1{iTrial}{iSacc} = [Datax.EyeLoc{iTrial}(:, Datax.SacTimeGoc1{iTrial}(1,iSacc): Datax.SacTimeGoc1{iTrial}(2,iSacc));...
                Datax.EyeVel{iTrial}(:, Datax.SacTimeGoc1{iTrial}(1,iSacc): Datax.SacTimeGoc1{iTrial}(2,iSacc));...
                Datax.EyeAcc{iTrial}(:, Datax.SacTimeGoc1{iTrial}(1,iSacc): Datax.SacTimeGoc1{iTrial}(2,iSacc))];
        end
        % find the peak velocity time and value
        Datax.SacPvelGoc1{iTrial}(1:2,:) = Datax.SaccSeqInfo{iTrial}{iColm}(end-1:end,1:WhichC-1);
    end

    % find the saccades after gocue
    % SaccTemp = [];
    % SaccTemp = Datax.SaccSeqInfo{3};
    % do not include peak velocity in time
    % Start time, End time, Duration, Reaction Time
    for iCols = 1:size(Datax.SaccSeqInfo{iTrial}{iColm},1)-2
        Datax.SacTimeGoc2{iTrial}(iCols,:) = Datax.SaccSeqInfo{iTrial}{iColm}(iCols,WhichC:end);
    end
    % Reaction Time: Start time - Gocue TIme
    Datax.SacTimeGoc2{iTrial}(iCols+1,:) = Datax.SaccSeqInfo{iTrial}{iColm}(1,WhichC:end)-Datax.GoCueTime(iTrial);

    % Find the whole saccadic eye traces
    % Loc;Vel;Acc
    for iSacc = 1:size(Datax.SacTimeGoc2{iTrial},2)
        Datax.SacLocGoc2{iTrial}{iSacc} = [Datax.EyeLoc{iTrial}(:, Datax.SacTimeGoc2{iTrial}(1,iSacc): Datax.SacTimeGoc2{iTrial}(2,iSacc));...
            Datax.EyeVel{iTrial}(:, Datax.SacTimeGoc2{iTrial}(1,iSacc): Datax.SacTimeGoc2{iTrial}(2,iSacc));...
            Datax.EyeAcc{iTrial}(:, Datax.SacTimeGoc2{iTrial}(1,iSacc): Datax.SacTimeGoc2{iTrial}(2,iSacc))];
    end
    % find the peak velocity
    Datax.SacPvelGoc2{iTrial}(1:2,:) = Datax.SaccSeqInfo{iTrial}{iColm}(end-1:end,WhichC:end);
end


