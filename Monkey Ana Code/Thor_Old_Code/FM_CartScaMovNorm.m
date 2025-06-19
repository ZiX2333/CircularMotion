function [XNorm, YNorm, XIndAll] = FM_CartScaMovNorm(winSize,stepSize,XV,XVbase,YV,YVbase,winRange)
% This function is used for the moving window averaging for scatter plot
% the input will be windowsize, stepsize (usually same as winSize especially for scatter plot)
% XV X value, YV Y value, YVbase caucluate the mean value vector
% winRange the start and end of the window
% The main goal of this code is to do the normalization 
% Created by Xuan, May 09 2024
% Adjusted on Jun 20 2024, remove the devided by std part, now only compare
% with the Ybase
% Adjusted on July 24 2024, output the order which is XIndAll
% *************************************************************************
% Adjusted on Feb 18 2025, This code is used for monkey data now
% Works for the radius inputs
% Adjusted the output oder cause the previous one just confusing

XNorm = nan(size(XV));
YNorm = nan(size(YV));
XIndAll = [];

% Define the start and end points of the moving window
for stWin = winRange(1):stepSize:winRange(2)
    edWin = stWin + winSize;

    % Find the indices of XV that fall within the current window
    XIndbase = XVbase >= stWin & XVbase < edWin;

    XWinbase = XVbase(XIndbase);
    YWinbase = YVbase(XIndbase);

    % Skip if no data points fall within the window range
    if isempty(XWinbase)
        continue;
    end

    % Calculate mean vector length for the window
    YAvebase1 = circ_mean_nan(YWinbase);

    % Start the normalization based on the YAvebase and YStdbase
    XInd = XV >= stWin & XV < edWin;
    % YNorm1 = (YWin-YAvebase1)./YStdbase1;
    XNorm(XInd) = XV(XInd);
    YNorm(XInd) = wrapToPi(YV(XInd)-YAvebase1);

    XIndAll = [XIndAll; find(XInd==1)];

end

end