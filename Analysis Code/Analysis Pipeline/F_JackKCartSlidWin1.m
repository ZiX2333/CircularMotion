function [SampXAve,SampYAve,SampYStd] = F_JackKCartSlidWin1(inputXV,inputYV,SampS,ReTime,winSize,stepSize,winRange)
% this function is used for bootstrap the sliding window results on
% cartesian axis. the sliding window function is F_CartScaSlidWin1
% actually this code is more close to jackknife but not bootstrap because
% I'm not using resampling with replacement (the randperm function will do 
% a random sampling without replacement), so I write a second version of
% this code to make my bootstrap a resampling method
% Created on May 23, 2024, Xuan

% inputXV = rand(1,100)*100;
% inputYV = rand(1,100)*200;
% ReTime = 100;
% SampS = 50; % Sample size

% Reseeds the random number generator
rng("shuffle")
GroupS = length(inputXV);
SampXAve = []; SampYAve = []; SampYStd = [];
for iReTime = 1:ReTime
    % randomly select SampS number of points from GroupS
    SampN = []; SampXV = []; SampYV = []; XAve = []; YAve = []; YStd = [];
    SampN = randperm(GroupS,SampS);
    SampXV = inputXV(SampN); % sample XV
    SampYV = inputYV(SampN); % sample YV
    % iReTime
    % do the sliding window based on the function
    [XAve, YAve, YStd] = F_CartScaSlidWin1(winSize,stepSize,SampXV,SampYV,winRange);
    
    SampXAve = [SampXAve; XAve];
    SampYAve = [SampYAve; YAve];
    SampYStd = [SampYStd; YStd];
    
end
end