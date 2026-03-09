function [XAve, YMed, YQuaL, YQuaU] = F_CartScaSlidWin_PolData3(winSize,stepSize,XV,YV,winRange)
% This function is used for the moving window averaging for scatter plot
% the input will be windowsize, stepsize (usually same as winSize especially for scatter plot)
% XV X value, YV Y value, YVbase caucluate the mean value vector
% winRange the start and end of the window
% But this code is used to calculate sliding window result (especialluy the
% YV is radius data)
% Now updated this code to avoid X's boundary effect (When X is also polar data)
% Created by Xuan, May 20 2024
% Adjusted by Xuan, Time forget 2024
% Adjusted by Xuan, July 30 2024
    % I change the statistic calcu for Y from mean(std) to median(quadrant)
    % SInce some Y value may be affected too much by the outlier

% Initialize vectors to hold the moving average results
XAve = [];
YMed = [];
YQuaL = []; % for the 25%
YQuaU = []; % for the 75%

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
    YMed1 = nan;
    YQua1 = nan;
    YQua2 = nan;

    % Skip if no data points fall within the window range
    if isempty(XWin)
        % store the empty result and continue
        XAve = [XAve XAve1];
        YMed = [YMed YMed1];
        YQuaL = [YQuaL YQua1];
        YQuaU = [YQuaU YQua2];
        continue;
    end
    
    % Calculate mean direction for the window
    XAve1 = wrapTo2Pi(circ_mean_nan(XWin));

    % Calculate mean vector length for the window
    YMed1 = median(YWin);
    YQua1 = prctile(YWin,25);
    YQua2 = prctile(YWin,75);

    % Store the results
    XAve = [XAve XAve1];
    YMed = [YMed YMed1];
    YQuaL = [YQuaL YQua1];
    YQuaU = [YQuaU YQua2];

end

% sort the results due to the possible boundary effect in XV
[XAve, I] = sort(XAve);
YMed = YMed(I);
YQuaL = YQuaL(I);
YQuaU = YQuaU(I);

end