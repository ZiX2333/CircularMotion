function F_PolarScat(ThetaV, RhoV, iCond, Rlim)
% plot each condition's polar scatter, so there will be 7 figures
% Theta V and Rho V are input
global LegText colorRGB
polarscatter(ThetaV,RhoV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none',...
    'MarkerFaceAlpha',0.6);

title(LegText{iCond},'FontWeight','normal')
set(gca,'FontSize',14)
rlim(Rlim)
end
