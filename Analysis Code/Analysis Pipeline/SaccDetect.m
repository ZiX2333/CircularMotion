% Saccade Detecting Function
% This function is using for detecting saccades
% input: Velocity, Markers

function [TimeS,TimeE,TimeDur,PeakV,TimePV] = SaccDetect(EyeLocV, EyeLocM, DurThrs)
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
