function [RhoVAve,RhoVStd] = F_CartAveStd2(RhoV,iCond,Xlim,Ylim,typeR,pStd)
% This function is used to plot polar mean and std
% in one dimension, which means that only one circle(s)
% if typeR is 1, means R represent normal value, use mean
% if typeR is 2, means R represent angular, use circ_mean
% if pStd is 1, plot std; if pStd is 0, not plot

global LegText colorRGB colorRGB2 rScalar

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

[xAve,yAve] = pol2cart(t,rAve+rScalar);
[xStdUp,yStdUp] = pol2cart(t,rAve+rScalar);
[xStdLr,yStdLr] = pol2cart(t,rAve+rScalar);



p1 = plot(xAve,yAve,'Color',[colorRGB2(iCond,:),0.7],'LineWidth',1.5);
if pStd
    hold on
    p2 = plot(xStdUp,yStdUp,'Color',[colorRGB(iCond,:),0.6],'LineWidth',1.2,'LineStyle','--');
    p3 = plot(xStdLr,yStdLr,'Color',[colorRGB(iCond,:),0.6],'LineWidth',1.2,'LineStyle','--');
    hold off
end

legend(p1,[num2str(RhoVAve,'%.3f'),char(177),num2str(RhoVStd,'%.3f')],'Box','off')

title(LegText{iCond},'FontWeight','normal')
set(gca,'FontSize',14)
xlim(Xlim)
ylim(Ylim)
end
