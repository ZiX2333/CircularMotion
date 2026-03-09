function SacEndErrAngShuff = F_ShuffTest1(inputXV,inputYV,ReTime,winSize,stepSize,winRange)

% this code is used for the shuffling test on the cartesian sliding window
% Created on May 28, 2024, Xuan
% Adjusted on Aug 21, 2024, Xuan
%       Change the result output way

rng("shuffle")
ShuffXAve = []; ShuffYAve = []; ShuffYStd = [];
for iReTime = 1:ReTime

    XAve = []; YAve = []; YStd = [];

    % I think only shuffle Y will be enough
    % ShuffXV = inputXV(randperm(length(inputXV)));
    ShuffYV = inputYV(randperm(length(inputYV)));

    % do the sliding window based on the shuffling result
    [XAve, YAve, YStd] = F_CartScaSlidWin_PolData2(winSize,stepSize,inputXV,ShuffYV,winRange);

    ShuffXAve = [ShuffXAve; XAve];
    ShuffYAve = [ShuffYAve; YAve];
    ShuffYStd = [ShuffYStd; YStd];
end

for iShuffY = 1:size(ShuffYAve,2)
    ShuffYAveAve(iShuffY) = nan;
    ShuffXAveAve(iShuffY) = nan;
    ShuffYUCI95(iShuffY) = nan;
    ShuffYLCI95(iShuffY) = nan;
    % nan_mean
    % SampYAveAve(iSampY) = circ_mean(SampYAve(~isnan(SampYAve(:,iSampY)),iSampY));
    % SampYAveAve(iSampY) = nanmean(SampYAve(~isnan(SampYAve(:,iSampY)),iSampY));
    ShuffXAveAve(iShuffY) = wrapTo2Pi(circ_mean_nan(ShuffXAve(:,iShuffY)));
    ShuffYAveAve(iShuffY) = circ_mean_nan(ShuffYAve(:,iShuffY));
    ShuffYLCI95(iShuffY) = prctile(ShuffYAve(:,iShuffY), 2.5);
    ShuffYUCI95(iShuffY) = prctile(ShuffYAve(:,iShuffY), 97.5);
    ShuffYLCI90(iShuffY) = prctile(ShuffYAve(:,iShuffY), 5);
    ShuffYUCI90(iShuffY) = prctile(ShuffYAve(:,iShuffY), 95);
    ShuffYUCI95Ave(iShuffY) = ShuffYUCI95(iShuffY) - ShuffYAveAve(iShuffY);
    ShuffYLCI95Ave(iShuffY) = ShuffYAveAve(iShuffY) - ShuffYLCI95(iShuffY);
    ShuffYStdErr(iShuffY) = circ_std_nan(ShuffYAve(:,iShuffY));
end

SacEndErrAngShuff.ShuffXAve = ShuffXAve;
SacEndErrAngShuff.ShuffYAve = ShuffYAve;
SacEndErrAngShuff.ShuffYStd = ShuffYStd;
SacEndErrAngShuff.ShuffXAveAve = ShuffXAveAve;
SacEndErrAngShuff.ShuffYAveAve = ShuffYAveAve;
SacEndErrAngShuff.ShuffYCI95 = [ShuffYLCI95;ShuffYUCI95];
SacEndErrAngShuff.ShuffYCI90 = [ShuffYLCI90;ShuffYUCI90];
SacEndErrAngShuff.ShuffYUCI95Ave = ShuffYUCI95Ave;
SacEndErrAngShuff.ShuffYLCI95Ave = ShuffYLCI95Ave;
SacEndErrAngShuff.ShuffYStdErr = ShuffYStdErr;

end