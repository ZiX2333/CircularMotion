% Saccade Detecting Function
% This function is using for detecting saccades
% input: Velocity, Markers
% Adjusted on Aug 13 by Xuan
%   I made a detection version based on acceleration detection method...
%   which is crazy
%   Not based on but also check the Accelration

function [TimeS,TimeE,TimeDur,PeakV,TimePV] = SaccDetectAcc(EyeLocV, EyeLocM, EyeLocA, DurThrs, AccThrs)
% Start Time
TimeS = find(diff([0, EyeLocM]) == 1);
% End Time
TimeE = find(diff([EyeLocM, 0]) == -1);
% Duration between Start Time and End Time
TimeDur = TimeE - TimeS;

% emote saccade duration that is smaller than threshold
TimeS(TimeDur<DurThrs) = [];
TimeE(TimeDur<DurThrs) = [];
TimeDur(TimeDur<DurThrs) = [];

% emote saccade acc that is smaller than threshold
% if during the [TimeS, TimeE] there is no acceleration > thrs then remove
rmTime = []; % Time that need to be removed
for iTime = 1:length(TimeS)
    if sum(abs(EyeLocA(TimeS(iTime):TimeE(iTime))) > AccThrs) == 0
        rmTime = [rmTime,iTime];
    end
end

TimeS(rmTime) = [];
TimeE(rmTime) = [];
TimeDur(rmTime) = [];

% Peak velocity time
PeakV = zeros(size(TimeS));
% time when reach to the peak velocity
TimePV = zeros(size(TimeS));
for i = 1:length(TimeS)
    PeakVTemp = max(abs(EyeLocV(TimeS(i):TimeE(i))));
    VelIndex = find(abs(EyeLocV(TimeS(i):TimeE(i))) == PeakVTemp,1,"first");
    EyeLocRange = EyeLocV(TimeS(i):TimeE(i));
    PeakV(i) = EyeLocRange(VelIndex);
    TimePV(i) = TimeS(i)+VelIndex-1;
end
end
