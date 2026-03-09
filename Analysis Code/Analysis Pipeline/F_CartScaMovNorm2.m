function [XNorm, YNorm, XIndAll] = F_CartScaMovNorm2(winSize,stepSize,XV,XVbase,YV,YVbase,winRange)
% This function is used for the moving window averaging for scatter plot
% the input will be windowsize, stepsize (usually same as winSize especially for scatter plot)
% XV X value, YV Y value, YVbase caucluate the mean value vector
% winRange the start and end of the window
% The main goal of this code is to do the normalization 
% Created by Xuan, May 09 2024
% Adjusted on Jun 20 2024, remove the devided by std part, now only compare
% with the Ybase
% Adjusted on July 24 2024, output the order which is XIndAll

% Initialize vectors to hold the moving average results
XAvebase = [];
YAvebase = [];
YStdbase = [];

XNorm = [];
YNorm = [];
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

    XAvebase1 = [];
    YAvebase1 = [];
    % Calculate mean direction for the window
    XAvebase1 = mean(XWinbase);

    % Calculate mean vector length for the window
    YAvebase1 = mean(YWinbase);
    YStdbase1 = std(YWinbase);

    % Store the results
    XAvebase = [XAvebase XAvebase1];
    YAvebase = [YAvebase YAvebase1];
    YStdbase = [YStdbase YStdbase1];

    % Start the normalization based on the YAvebase and YStdbase
    XInd = XV >= stWin & XV < edWin;
    XWin = XV(XInd);
    YWin = YV(XInd);

    % YNorm1 = (YWin-YAvebase1)./YStdbase1;
    YNorm1 = YWin-YAvebase1;

    XNorm = [XNorm, XWin];
    YNorm = [YNorm, YNorm1];
    XIndAll = [XIndAll, find(XInd==1)];

end

end