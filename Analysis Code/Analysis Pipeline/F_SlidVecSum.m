function [AveXY,VecSum] = F_SlidVecSum(ThetaV,XY,UV,winRange,stepSize)
% This function is used for sliding vector summation
% It will Provides a series of vector based on the sliding window and step
% ThetaV has to be ranged from 0 to 2pi
VecSum = []; AveXY = [];
% Define the start and end points of the moving window
for startAngle = 0:stepSize:2*pi
    endAngle = startAngle + winRange;

    % Find the indices of theta that fall within the current window
    if endAngle > 2*pi
        winIndices = ThetaV >= startAngle & ThetaV <= 2*pi |...
            ThetaV < wrapTo2Pi (endAngle) & ThetaV >= 0;
    else
        winIndices = ThetaV >= startAngle & ThetaV < endAngle;
    end
    winTheta = ThetaV(winIndices);
    winXY = XY(winIndices,:);
    winUV = UV(winIndices,:);

    % Skip if no data points fall within the window range
    if isempty(winTheta)
        continue;
    end

    AveXY1 = []; % averaged initial location
    VecSum1 = [];

    % Calculate mean direction for the window
    if size(winXY,1) > 1
        AveXY1 = mean(winXY);
        VecSum1 = sum(winUV);
    elseif size(winXY,1) == 1
        AveXY1 = winXY;
        VecSum1 = winUV;
    end

    % Store the results
    AveXY = [AveXY;AveXY1];
    VecSum = [VecSum;VecSum1];
end
end