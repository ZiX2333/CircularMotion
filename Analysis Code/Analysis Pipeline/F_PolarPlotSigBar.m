function hp = F_PolarPlotSigBar(TV, pVals, Thres, RV, ColorRGB,FigAxis)
% This function is used to plot the significant bar in Polar
% need to hold on outside of this function
% TV is the theta axis location series
% pVals is the p values that should have same size as XV
% Thres is the significant threshold, usually should be 0.05
% RV: where to plot the R location, should be a range
% FigAxis: the figure axis handle
% output the handle of the plots

% plot the pVals in logic vector
pLog = pVals <= Thres;
stEdge = diff([0 pLog]);
edEdge = diff([pLog 0]);
stIdx = find(stEdge == 1);
edIdx = find(edEdge == -1);
hp = cell(1,length(stIdx));
% plot the lines
if nargin < 6
    for i = 1:length(stIdx)
        hp{i} = polarplot(TV(stIdx(i):edIdx(i)), RV*ones(size(stIdx(i):edIdx(i))), ...
            'Color',ColorRGB,'LineWidth',5);
    end
elseif nargin == 6
    for i = 1:length(stIdx)
        hp{i} = polarplot(FigAxis, TV(stIdx(i):edIdx(i)), RV*ones(size(stIdx(i):edIdx(i))), ...
            'Color',ColorRGB,'LineWidth',5);
    end
end

end