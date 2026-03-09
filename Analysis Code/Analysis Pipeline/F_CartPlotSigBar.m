function hp = F_CartPlotSigBar(XV, pVals, Thres, YV, FigAxis)
% This function is used to plot the significant bar in cartesian
% need to hold on outside of this function
% XV is the x axis location series
% pVals is the p values that should have same size as XV
% Thres is the significant threshold, usually should be 0.05
% YV: where to plot the y location
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
if nargin < 5
    for i = 1:length(stIdx)
        hp{i} = plot(XV(stIdx(i):edIdx(i)), YV*ones(size(stIdx(i):edIdx(i))), ...
            '-', 'LineWidth', 5, 'Color', [0.8 0.8 0.8]);
    end
elseif nargin == 5
    for i = 1:length(stIdx)
        hp{i} = plot(FigAxis,XV(stIdx(i):edIdx(i)), YV*ones(size(stIdx(i):edIdx(i))), ...
            '-', 'LineWidth', 5, 'Color', [0.8 0.8 0.8]);
    end
end

end