function pVal = F_BootSStat_Perm_pV4(XV1, YV1, XV2, YV2, ReTime,winSize,stepSize,winRange)
% This function is to check if the entire curve YV1 is significantlly
% different from the entire curve YV2
% create on Jul 15, 2025, Xuan
% Pseudo-code for T = integrated squared difference

% plot the observed sliding window first..
[XAve1, YAve1, ~] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV1',YV1',winRange);
[XAve2, YAve2, ~] = F_CartScaSlidWin_PolData2(winSize,stepSize,XV2',YV2',winRange);
XAve = circ_mean_nan([XAve1; XAve2]);
[XAve,I] = sort(XAve);
YAve = YAve1 - YAve2; YAve = YAve(I);
obsAveDiff = trapz(XAve, YAve.^2);

% Permutation:
bootsDiff = nan(ReTime,1);
XP = [XV1,XV2];
YP = [YV1,YV2];
SampS1 = numel(YV1); SampS2 = numel(YV2);
for iReTime = 1:ReTime
    SampN = randperm(SampS1 + SampS2);
    XP1 = XP(SampN(1:SampS1));
    YP1 = YP(SampN(1:SampS1));
    XP2 = XP(SampN(SampS1+1:end));
    YP2 = YP(SampN(SampS1+1:end));
    % do the sliding window of the pooled data
    [XPAve1, YPAve1, ~] = F_CartScaSlidWin_PolData2(winSize,stepSize,XP1',YP1',winRange);
    [XPAve2, YPAve2, ~] = F_CartScaSlidWin_PolData2(winSize,stepSize,XP2',YP2',winRange);
    XPAve = circ_mean_nan([XPAve1; XPAve2]);
    [XPAve,I] = sort(XPAve);
    YPAve = YPAve1 - YPAve2; YPAve = YPAve(I);
    bootsDiff(iReTime) = trapz(XPAve, YPAve.^2);
end
pVal = sum(bootsDiff >= obsAveDiff)/(ReTime+1);
end