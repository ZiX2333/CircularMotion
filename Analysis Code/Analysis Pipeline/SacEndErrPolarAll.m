for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = [];

    datas1 = find([Dataf1.TarDir] == iCond & [Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5);
    EyeTta = zeros(size(datas1));

    RadioAxisI = RadioAxis(datas1);

    iTriali = 0;
    for iTrial = datas1
        iTriali = iTriali+1;
        % EyeLocPol = [];
        % EyeLocPol = sbd.EyeLocMovPol{iTrial};
        EyeTta(iTriali) = wrapTo2Pi(ThetaAxis(iTrial));
    end

    % Initialize vectors to hold the moving average results
    AveDir = [];
    AveRad = [];
    StdRad = [];

    % Define the start and end points of the moving window
    for startAngle = 0:stepSize:2*pi
        endAngle = startAngle + winRange;

        % Find the indices of theta that fall within the current window
        if endAngle > 2*pi
            winIndices = EyeTta >= startAngle & EyeTta <= 2*pi |...
                EyeTta < wrapTo2Pi (endAngle) & EyeTta >= 0;
        else
            winIndices = EyeTta >= startAngle & EyeTta < endAngle;
        end
        winTheta = EyeTta(winIndices);
        winRadi = RadioAxisI(winIndices);

        % Skip if no data points fall within the window range
        if isempty(winTheta)
            continue;
        end

        AveDir1 = [];
        AveRad1 = [];
        % Calculate mean direction for the window
        AveDir1 = circ_mean(winTheta');

        % Calculate mean vector length for the window
        AveRad1 = mean(winRadi);
        StdRad1 = std(winRadi);

        % Store the results
        AveDir = [AveDir AveDir1];
        AveRad = [AveRad AveRad1];
        StdRad = [StdRad StdRad1];
    end

    EyeEndTtaAve{iCondI} = AveDir;
    SacEndErrAve{iCondI} = AveRad;
    SacEndErrStd{iCondI} = StdRad;

    p1 = polarscatter(EyeTta,RadioAxisI,'MarkerFaceColor',colorRGB(iCondI,:),'MarkerEdgeColor','none',...
        'MarkerFaceAlpha',0.5);
    % p1 = polarscatter(EyeEndTta,SacEndErr,'MarkerEdgeColor',colorRGB(iCondI,:),'LineWidth',1);
    hold on
    p2 = polarplot(AveDir,AveRad,'LineWidth',1.5,'Color',colorRGB2(iCondI,:),'LineStyle','-');
    p2_1 = polarplot(AveDir,AveRad+StdRad,'LineWidth',1,'Color',colorRGB2(iCondI,:),'LineStyle','--');
    p2_2 = polarplot(AveDir,AveRad-StdRad,'LineWidth',1,'Color',colorRGB2(iCondI,:),'LineStyle','--');
    p3 = polarplot(0:stepSize/10:2*pi,zeros(size(0:stepSize/10:2*pi)),'LineWidth',1,'Color','k','LineStyle','--');
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([-2,2])
    hold off
end