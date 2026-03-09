function SacEndErrAngBootS = F_BootSCartSlidWin3(inputXV,inputYV,SampS,ReTime,winSize,stepSize,winRange)
% this function is used for bootstrap the sliding window results on
% cartesian axis. the sliding window function is F_CartScaSlidWin_PolData2
% in this code, I use datasample to do a resample with replacement
% Created on May 23, 2024, Xuan
% Adjusted on Aug 21, 2024, Xuan
%       Changed the results output to make my code more clean
% Adjusted on Jul 11, 2025, Xuan
%       Change the mean calculation of SampX, make it as circular data
% Adjusted on Oct 20, 2025, Xuan
%       This version of mean calculation of SampX, make it as non circular data

% inputXV = rand(1,100)*100;
% inputYV = rand(1,100)*200;
% ReTime = 100;
% SampS = 50; % Sample size

% Reseeds the random number generator
rng("shuffle")
SampNAll = []; SampXAve = []; SampYAve = []; SampYStd = [];
for iReTime = 1:ReTime
    % randomly select SampS number of points from GroupS
    SampN = []; SampXV = []; SampYV = []; XAve = []; YAve = []; YStd = [];
    [SampXV,SampN] = datasample(inputXV,SampS,'Replace',true);
    SampYV = inputYV(SampN); % sample YV
    % iReTime
    % do the sliding window based on the function
    [XAve, YAve, YStd] = F_CartScaSlidWin_PolData1(winSize,stepSize,SampXV,SampYV,winRange);

    SampNAll = [SampNAll; SampN];
    SampXAve = [SampXAve; XAve];
    SampYAve = [SampYAve; YAve];
    SampYStd = [SampYStd; YStd];

end

for iSampY = 1:size(SampYAve,2)
    SampXAveAve(iSampY) = nan;
    SampYAveAve(iSampY) = nan;
    % nan_mean
    % SampYAveAve(iSampY) = circ_mean(SampYAve(~isnan(SampYAve(:,iSampY)),iSampY));
    % SampYAveAve(iSampY) = nanmean(SampYAve(~isnan(SampYAve(:,iSampY)),iSampY));
    SampXAveAve(iSampY) = wrapTo2Pi(circ_mean_nan(SampXAve(:,iSampY)));
    SampYAveAve(iSampY) = mean(SampYAve(:,iSampY),'omitmissing');
    SampYLCI95(iSampY) = prctile(SampYAve(:,iSampY), 2.5);
    SampYUCI95(iSampY) = prctile(SampYAve(:,iSampY), 97.5);
    SampYLCI90(iSampY) = prctile(SampYAve(:,iSampY), 5);
    SampYUCI90(iSampY) = prctile(SampYAve(:,iSampY), 95);
    SampYUCI95Ave(iSampY) = SampYUCI95(iSampY) - SampYAveAve(iSampY);
    SampYLCI95Ave(iSampY) = SampYAveAve(iSampY) - SampYLCI95(iSampY);
    SampYStdErr(iSampY) = std(SampYAve(:,iSampY),'omitmissing');
end

SacEndErrAngBootS.SampNAll = SampNAll;
SacEndErrAngBootS.SampXAve = SampXAve;
SacEndErrAngBootS.SampYAve = SampYAve;
SacEndErrAngBootS.SampYStd = SampYStd;
SacEndErrAngBootS.SampXAveAve = SampXAveAve;
SacEndErrAngBootS.SampYAveAve = SampYAveAve;
SacEndErrAngBootS.SampYCI95 = [SampYLCI95;SampYUCI95];
SacEndErrAngBootS.SampYCI90 = [SampYLCI90;SampYUCI90];
SacEndErrAngBootS.SampYUCI95Ave = SampYUCI95Ave;
SacEndErrAngBootS.SampYLCI95Ave = SampYLCI95Ave;
SacEndErrAngBootS.SampYStdErr = SampYStdErr;

end