function [RhoVAve,RhoVStd] = F_PolarAveStd1(RhoV,iCond,Rlim,typeR,pStd)
% This function is used to plot polar mean and std
% in one dimension, which means that only one circle(s)
% if typeR is 1, means R represent normal value, use mean
% if typeR is 2, means R represent angular, use circ_mean
% if pStd is 1, plot std; if pStd is 0, not plot

global LegText colorRGB2

% ThetaVAve = cir_mean(ThetaV);
% ThetaVStd = cir_std(ThetaV);

switch typeR
    case 1
        RhoVAve = mean(RhoV(~isnan(RhoV)));
        RhoVStd = std(RhoV(~isnan(RhoV)));

    case 2
        RhoVAve = circ_mean(RhoV(~isnan(RhoV)));
        RhoVStd = circ_std(RhoV(~isnan(RhoV)));
end

t = 0:pi/50:2*pi;
rAve = RhoVAve * ones(size(t));
rStdUp = (RhoVAve+RhoVStd) * ones(size(t));
rStdLr = (RhoVAve-RhoVStd) * ones(size(t));

p1 = polarplot(t,rAve,'Color',[colorRGB2(iCond,:)],'LineWidth',1.5);
if pStd
    hold on
    p2 = polarplot(t,rStdUp,'Color',[colorRGB2(iCond,:),0.4],'LineWidth',1.2,'LineStyle','--');
    p3 = polarplot(t,rStdLr,'Color',[colorRGB2(iCond,:),0.4],'LineWidth',1.2,'LineStyle','--');
    % hold off
end

legend(p1,[num2str(RhoVAve,'%.3f'),char(177),num2str(RhoVStd,'%.3f')],'Box','off','Location','south','AutoUpdate','off')

title(LegText{iCond},'FontWeight','normal')
set(gca,'FontSize',14)
rlim(Rlim)
end
