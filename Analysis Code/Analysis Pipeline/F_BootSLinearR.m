function YResult = F_BootSLinearR(inputXV,inputYV,XDots,SampS,ReTime)
% this function is used for bootstrap the sliding window results on
% cartesian axis. the sliding window function is F_CartScaSlidWin_PolData2
% in this code, I use datasample to do a resample with replacement
% Created on May 23, 2024, Xuan
% Adjusted on Aug 21, 2024, Xuan
%       Changed the results output to make my code more clean

% inputXV = rand(1,100)*100;
% inputYV = rand(1,100)*200;
% ReTime = 100;
% SampS = 50; % Sample size

% Reseeds the random number generator
rng("shuffle")

% XDots = linspace(min(inputXV), max(inputXV), 100)';
bootSlopes = zeros(ReTime,1);
bootIntercepts = zeros(ReTime,1);
y_boot = zeros(length(XDots), ReTime);

for iReTime = 1:ReTime
    % randomly select SampS number of points from GroupS
    [SampXV,SampN] = datasample(inputXV,SampS,'Replace',true);
    SampYV = inputYV(SampN); % sample YV
    % do the linear regression
    p = polyfit(SampXV, SampYV, 1);
    bootSlopes(iReTime) = p(1);
    bootIntercepts(iReTime) = p(2);

    y_boot(:, iReTime) = polyval(p, XDots);


end


% Pointwise mean and confidence intervals
YResult.y_mean = mean(y_boot, 2);
YResult.y_lower = prctile(y_boot, 2.5, 2);
YResult.y_upper = prctile(y_boot, 97.5, 2);

end