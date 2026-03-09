function [SampPhi,SampLaxis,SampSaxis] = F_BootSEllipse(inputXV,inputYV,SampS,ReTime)
% this function is used for bootstrap the ellipse fitting result
% The ellipse fitting is based on the fuction: F_FitEllipse, which is based
% on the least square criterion
% I change the randperm to datasample to do a resample with replacement
% Changed on June 06, 2024 Xuan

% inputXV = rand(1,100)*100;
% inputYV = rand(1,100)*200;
% ReTime = 100;
% SampS = 50; % Sample size

% Reseeds the random number generator
rng("shuffle")
GroupS = length(inputXV);
SampPhi = []; SampLaxis = []; SampSaxis = [];
for iReTime = 1:ReTime
    % randomly select SampS number of points from GroupS
    SampN = []; SampXV = []; SampYV = []; ellipse_t = [];
    % SampN = randperm(GroupS,SampS);
    [SampXV,SampN] = datasample(inputXV,SampS,'Replace',true);
    % SampXV = inputXV(SampN); % sample XV 
    SampYV = inputYV(SampN); % sample YV
    % iReTime
    % do the ellipse fitting based on the sample data and
    ellipse_t = F_FitEllipse(SampXV,SampYV,0);
    SampPhi = [SampPhi, ellipse_t.angXtoL];
    SampLaxis = [SampLaxis, ellipse_t.long_axis];
    SampSaxis = [SampSaxis, ellipse_t.short_axis];
end
end