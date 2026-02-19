function pVals = F_BootSStat_Ave_pV3(YV1, YV2, ReTime)
% This code is used to calculate the BootS p Value
% It is not exactly the F_BootSpCartSldwin method, but is to use 
% pooled null method to test if the two dataset mean value are significant
% different from each other...
% The result output will be the two-sided p-value at each x, therefore each
% group should have same length of X
% BootSPara are results from F_BootSCartSlidWin Functions, 
% Para1 for the group 1; Para2 for the group 2
% BootSSz are the BootS repeatted times
% Created on Jul 11, 2025, Xuan
% Adjusted on Jul 12, 2025, Xuan
%       Big change, basically rewrite...

% plot the observed sliding window first..
YAve1 = circ_mean_nan(YV1');
YAve2 = circ_mean_nan(YV2');
obsAveDiff = YAve1 - YAve2; % 1 * winLen

% Pool the data together
bootsDiff = zeros(ReTime, 1);
YP = [YV1,YV2];
SampS1 = numel(YV1); SampS2 = numel(YV2);
for iReTime = 1:ReTime
    SampN = randperm(SampS1 + SampS2);
    YP1 = YP(SampN(1:SampS1));
    YP2 = YP(SampN(SampS1+1:end));
    % do the sliding window of the pooled data
    YPAve1 = circ_mean_nan(YP1');
    YPAve2 = circ_mean_nan(YP2');
    bootsDiff(iReTime) = YPAve1 - YPAve2;
end

% count how many bootstrap diffs are at least as large in magnitude as the observed
% this is same as {d >= o} AND {d <= -o}
extremeCount = sum( abs(bootsDiff) >= abs(obsAveDiff) , 1); % 1 * numY
pVals = extremeCount./ (ReTime+1); % 1 * numY