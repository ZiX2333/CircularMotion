function [StatResult,p] = F_FitLinearR1(XV,YV,XLim,YLim)
% This function is used to fit a linear regression line on the current plot
% And output the statistic value 
% Created by Xuan, July 10 2024
%   fit a linear model
% Adjusted by Xuan, Aug 14 2024
%   change the length of ploting the fitting curve, only plot align the range
%   of the data. which means I remove the XLim and YLim
% Adjusted by Xuan, Aug 14 2024
%   Change to poly fit omit nan

idx = union(find(isnan(XV)),find(isnan(YV)));
XV(idx) = [];
YV(idx) = [];
coefficients = polyfit(XV, YV, 1); % 1 indicates linear model
SlopeK = coefficients(1); % Slope
InterceptB = coefficients(2); % Intercept

[corr_matrix,p_matrix] = corrcoef(XV, YV);
r_value = corr_matrix(1,2); % r-value between x and y
p_value = p_matrix(1,2);

XVLim = [min(XV),max(XV)]; YVLim = [min(YV),max(YV)];

p = plot([XVLim(1),XVLim(2)],[XVLim(1),XVLim(2)]*SlopeK+InterceptB,'--','LineWidth',1.5,'Color',[0.25,0.25,0.25]);
% value_text = sprintf('r = %.4f\np = %.4f', r_value,p_value);
% text(XLim(1)+(XLim(2)-XLim(1))/20, YLim(2)-(YLim(2)-YLim(1))/10, value_text, 'FontSize', 14);
% text(Xlim(1)+(Xlim(2)-Xlim(1))/20, Ylim(2)-0.4, p_value_text, 'FontSize', 12);

StatResult.coefficients = coefficients;
StatResult.corr_matrix = corr_matrix;
StatResult.p_matrix = p_matrix;
StatResult.SlopeK = SlopeK;
StatResult.InterceptB = InterceptB;
StatResult.r_value = r_value;
StatResult.p_value = p_value;

end