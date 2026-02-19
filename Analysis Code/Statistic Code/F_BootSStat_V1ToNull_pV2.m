function pVals = F_BootSStat_V1ToNull_pV2(XV, YV, ReTime, winSize,stepSize,winRange)
% This code is used to calculate the BootS p Value
% It is the comparesion between the dataset with it own shuffle
% The result output will be the two-sided p-value at each x, therefore each
% group should have same length of X
% BootSPara are results from F_BootSCartSlidWin Functions, 
% BootSPara for the BootStrap result; ShuffPara for the shuffled result
% ReTime are the BootS repeatted times
% Created on Jul 12, 2025, Xuan
rng("shuffle")
% plot the observed sliding window first..
[~, YAve, ~] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV',YV',winRange);

% Pool the data together
YNullAveAll = zeros(ReTime, numel(YAve));
SampS = numel(YV);
for iReTime = 1:ReTime
    XNull = XV(randperm(SampS));
    YNull = YV(randperm(SampS));
    % do the sliding window of the pooled data
    [~, YNullAve, ~] = F_CartScaSlidWin_PolData2(winSize,stepSize,XNull',YNull',winRange);
    YNullAveAll(iReTime,:) = YNullAve;
end
YNullAveAve = circ_mean_nan(YNullAveAll);
obsAveDiff = YAve - YNullAveAve; % 1 * winLen
bootsDiff = YNullAveAll - YNullAveAve(ones(ReTime,1),:);

% count how many bootstrap diffs are at least as large in magnitude as the observed
% this is same as {d >= o} AND {d <= -o}
extremeCount = sum( abs(bootsDiff) >= abs(obsAveDiff) , 1); % 1 * numY
pVals = extremeCount./ (ReTime+1); % 1 * numY