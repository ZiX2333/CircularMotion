% function pVals = F_BootSStat_GroupAve_pV5(ObsV, NullV)
function pVals = F_BootSStat_OneSamp_pV6(ObsV, ObsVAve, ReTime)
% This code is used to calculate the BootS p Value
% It is used for subject level bootstrap of the group-mean difference
% before using this code, I should already have each subjects' boots and
% null traces, and the average of them
% then I get the bootstrap distribution of the group-mean difference by
% resampling subjects with replacements

% this bootstrap is the mean compare with it own shuffle
% its own null is created by sign flipping method
% reference:
% Randomization, Bootstrap and Monte Carlo Methods in Biology
% Permutation, Parametric and Bootstrap Tests of Hypotheses

% ObsV: each subject's observation vectors
% ObsVAve: averaged subject's observation vectors
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
% obsDiff = ObsVAve - NullVAve; %observation to null diff

% Pool the data together
bootsAve = zeros(ReTime, numel(ObsVAve));
SampS = size(ObsV,1);
for iReTime = 1:ReTime
    SignRand = 2*(rand(SampS,1) > 0.5) - 1;
    bootsAve(iReTime,:) = circ_mean_nan(ObsV.*SignRand); 
end
obsVAveAll = ObsVAve(ones(ReTime,1),:);

% count how many bootstrap diffs are at least as large in magnitude as the observed
% this is same as {d >= o} AND {d <= -o}
extremeCount = sum( abs(bootsAve) >= abs(obsVAveAll) , 1); % 1 * numY
pVals = (extremeCount + 1)./ (ReTime+1); % 1 * numY

