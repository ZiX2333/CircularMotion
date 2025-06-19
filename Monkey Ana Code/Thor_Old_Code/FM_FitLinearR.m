function [StatResult] = FM_FitLinearR(XV,YV)
% This function is used to fit a linear regression line on the current plot
% And output the statistic value 
% Created by Xuan, July 10 2024
%   fit a linear model
% Adjusted by Xuan, Aug 14 2024
%   change the length of ploting the fitting curve, only plot align the range
%   of the data. which means I remove the XLim and YLim
% Adjusted by Xuan, Aug 14 2024
%   Change to poly fit omit nan
% Adjusted by Xuan, Feb 18 2024
%   Made the plot code outside 

idx = union(find(isnan(XV)),find(isnan(YV)));
XV(idx) = [];
YV(idx) = [];
coefficients = polyfit(XV, YV, 1); % 1 indicates linear model
SlopeK = coefficients(1); % Slope
InterceptB = coefficients(2); % Intercept

[corr_matrix,p_matrix] = corrcoef(XV, YV);
r_value = corr_matrix(1,2); % r-value between x and y
p_value = p_matrix(1,2);

StatResult.coefficients = coefficients;
StatResult.corr_matrix = corr_matrix;
StatResult.p_matrix = p_matrix;
StatResult.SlopeK = SlopeK;
StatResult.InterceptB = InterceptB;
StatResult.r_value = r_value;
StatResult.p_value = p_value;

end