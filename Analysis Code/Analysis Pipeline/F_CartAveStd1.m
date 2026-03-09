function [XVAve,XVStd] = F_CartAveStd1(YV,iCond,Xlim,Ylim,typeR,pStd)
% This function is used to plot cart mean and std on cart axis
% in one dimension, which means that only one circle(s)
% if typeR is 1, means R represent normal value, use mean
% if typeR is 2, means R represent angular, use circ_mean
% if pStd is 1, plot std; if pStd is 0, not plot

global LegText colorRGB1

% ThetaVAve = cir_mean(ThetaV);
% ThetaVStd = cir_std(ThetaV);

switch typeR
    case 1
        XVAve = mean(YV(~isnan(YV)));
        XVStd = std(YV(~isnan(YV)));

    case 2
        XVAve = circ_mean(YV(~isnan(YV)));
        XVStd = circ_std(YV(~isnan(YV)));
end

x = Xlim(1):(Xlim(2)-Xlim(1))/20:Xlim(2);
yAve = XVAve * ones(size(x));
yStdUp = (XVAve+XVStd) * ones(size(x));
yStdLr = (XVAve-XVStd) * ones(size(x));

p1 = plot(x,yAve,'Color',[colorRGB1(iCond,:),0.6],'LineWidth',1.5);
if pStd
    hold on
    p2 = plot(x,yStdUp,'Color',[colorRGB1(iCond,:),0.6],'LineWidth',1.2,'LineStyle','--');
    p3 = plot(x,yStdLr,'Color',[colorRGB1(iCond,:),0.6],'LineWidth',1.2,'LineStyle','--');
    % hold off
end

legend(p1,[num2str(XVAve,'%.3f'),char(177),num2str(XVStd,'%.3f')],'Box','off')

title(LegText{iCond},'FontWeight','normal')
set(gca,'FontSize',14)
xlim(Xlim)
ylim(Ylim)
end
