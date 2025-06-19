function FM_CartScat(XV, YV, iCond, Xlim, Ylim,ifTitle)
% plot each condition's polar scatter, so there will be 7 figures
% Theta V and Rho V are input
global LegText colorRGB
scatter(XV,YV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');

if nargin <6
        title(LegText{iCond},'FontWeight','normal')
end
set(gca,'FontSize',14)
xlim(Xlim)
ylim(Ylim)
end
