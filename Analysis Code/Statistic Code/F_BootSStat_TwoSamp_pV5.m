% function pVals = F_BootSStat_GroupAve_pV5(ObsV, NullV)
function pVals = F_BootSStat_TwoSamp_pV5(ObsV1, ObsV2, ObsVAve1, ObsVAve2, ReTime)
% This code is used to calculate the BootS p Value
% It is used for subject level bootstrap of the group-mean difference
% before using this code, I should already have each subjects' boots and
% null traces, and the average of them
% then I get the bootstrap distribution of the group-mean difference by
% resampling subjects with replacements

% ObsV: each subject's observation vectors
% NullV: each subjects' null vectors
% ObsVAve: averaged subject's observation vectors
% NullVAve: averaged subject's null vectors
% ReTime are the BootS repeatted times

% % Created on Jul 12, 2025, Xuan
% rng("shuffle")
% % SampN = size(ObsV,1);
% numX = size(ObsV,2);
% pVals = nan(1,numX);
% 
% for x = 1:numX
%   % differences across subjects at this x
%   d = ObsV(:,x) - NullV(:,x);
%   % skip nan:
%   if sum(~isnan(d))<2
%       pVals(x) = 1;
%       continue
%   end
%   % paired t-test H0: mean(d)=0
%   % [~, pVals(x)] = ttest(d);
%   % or nonparametric:
%   pVals(x) = signrank(d);
% end

rng("shuffle")
% plot the observed sliding window first..
obsDiff = ObsVAve1 - ObsVAve2; %observation to null diff

% Pool the data together
bootsDiff = zeros(ReTime, numel(obsDiff));
poolAll = [ObsV1; ObsV2];
SampS = size(ObsV1,1);
for iReTime = 1:ReTime
    SampN = randperm(SampS + SampS);
    gobs = circ_mean_nan(poolAll(SampN(1:SampS),:));  % 1×numX
    gnull = circ_mean_nan(poolAll(SampN(SampS+1:end),:));
    bootsDiff(iReTime,:) = gobs - gnull;
end
obsDiffAll = obsDiff(ones(ReTime,1),:);

% count how many bootstrap diffs are at least as large in magnitude as the observed
% this is same as {d >= o} AND {d <= -o}
extremeCount = sum( abs(bootsDiff) >= abs(obsDiffAll) , 1); % 1 * numY
pVals = extremeCount./ (ReTime+1); % 1 * numY

