function [XAve, YAve, YStd] = F_CartScaSlidWin_PolData4(winSize,stepSize,XV,YV,winRange)
% This function is used for the moving window averaging for scatter plot
% the input will be windowsize, stepsize (usually same as winSize especially for scatter plot)
% XV X value, YV Y value, YVbase caucluate the mean value vector
% winRange the start and end of the window
% But this code is used to calculate sliding window result (especialluy the
% YV is radius data)
% Now updated this code to avoid X's boundary effect (When X is also polar data)
% Created by Xuan, May 20 2024
% Adjusted by Xuan, Time forget 2024
% Adjusted by Xuan, July 24 2024
    % Change the Y ave calculation from circ-mean to mean. This code is for
    % non circular Y data
% Adjusted by Xuan, Nov 19 2024
    % When X is also non radius data

% Initialize vectors to hold the moving average results
XAve = [];
YAve = [];
YStd = [];

% Define the start and end points of the moving window
for stWin = winRange(1):stepSize:winRange(2)
    edWin = stWin + winSize;

    % Find the indices of XV that fall within the current window
    % Also avoid the boundary effect
    if edWin > winRange(2)
        XInd =  XV >= stWin & XV <= winRange(2) |...
            XV < wrapTo2Pi (edWin) & XV >= winRange(1);
    else
        XInd = XV >= stWin & XV < edWin;
    end

    XWin = XV(XInd);
    YWin = YV(XInd);
    
    XAve1 = nan;
    YAve1 = nan;
    YStd1 = nan;

    % Skip if no data points fall within the window range
    if isempty(XWin)
        % store the empty result and continue
        XAve = [XAve XAve1];
        YAve = [YAve YAve1];
        YStd = [YStd YStd1];
        continue;
    end
    
    % Calculate mean direction for the window
    XAve1 = wrapTo2Pi(circ_mean_nan(XWin));

    % Calculate mean vector length for the window
    YAve1 = mean(YWin,'omitmissing');
    YStd1 = std(YWin,'omitmissing');

    % Store the results
    XAve = [XAve XAve1];
    YAve = [YAve YAve1];
    YStd = [YStd YStd1];

end

% sort the results due to the possible boundary effect in XV
[XAve, I] = sort(XAve);
YAve = YAve(I);
YStd = YStd(I);

end