% this script used to restore all the "trash" code.
% for keepping the main data analysis pipeline DataAna clean
% a catalog will be list here and continue updated
%
% 1. Eye traces align to target onset and rotate to 90 deg, Sep 14
% 2. Eye traces aligh to 100ms before target onset and rotate to 90 deg, Sep 14
% 3. Ending Error (radial distance without sign) with RT, Sep 14
% 4. Ending Error (signed by up and down) with RT, Sep 14
% 5. Ending Tangental Distance with RT, Sep 14
% 6. Color code the RT on the eye traces, Sep 14
% 7. Color code the Target ending location on the eye traces, Sep 14
% 8. Two ways to find the mean traces
% 9. KL divergence with weighted avergae... Mar 17, 24
% 10. Combine subjects analysis on the ending error bar figure which is not working Jun 20, 24
% 11. In Behavior Ana to check the catch up saccade in smooth pursuit Aug 14, 2024, Xuan
% 12. KL-Divergence on target location, Jun 11, 2025, Xuan
% 13. GMM and linear mixed model, Jun 11, 2025, Xuan
% 14. BootStrap p value at each X, wrong method, Jul 12, 2025, Xuan
% 15. BootStrap compare with null distribution, Jul 15, 2025, Xuan
% 16. plot the example bootstrap
% 17. BootStrap level comparison
% 18. Old F_CartScaMovNorm

%% align to saccade onset
figure(3)
for iCond = 0:2
    datas = find([Dataf1.TarDir] == iCond);
    subplot(1,3,iCond+1)
    for iTrial = datas
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLoc = Dataf1(iTrial).EyeLocRGoc;
        TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
        p1 = polarplot(EyeLoc(4,TimeS:TimeE)-Dataf1(iTrial).SacTarGoc1(2,3)+deg2rad(90),EyeLoc(3,TimeS:TimeE),'LineWidth',0.6,'Color',colorRGB(iCond+1,:));
        hold on
    end
    polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
sgtitle('Saccade Traces in 3 Conditions, Aligned to Saccade Onset','FontSize',15)

%% align to 100ms before saccade onset
i = 0;
for iCond = [1,2,4,6]-1
    i = i+1;
    datas = find([Dataf1.TarDir] == iCond);
    subplot(2,2,i)
    for iTrial = datas
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLoc = Dataf1(iTrial).EyeLocRGoc;
        TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
        % Polar Plot
        p1 = polarplot(EyeLoc(4,TimeS:TimeE)-Dataf1(iTrial).SacTarGoc1(1,3)+deg2rad(90),EyeLoc(3,TimeS:TimeE),'LineWidth',0.6,'Color',colorRGB(i,:));
        hold on
    end
    polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
sgtitle('Saccade Traces in 3 Conditions, Aligned to 100 ms before Saccade Onset','FontSize',15)

%% plot for the above calcu, ending error with time
% plot relation between ending error (Radius distance) and RT
figure(6)
RTlim1 = 120;
RTlim2 = 350;
Erlim1 = -5;
Erlim2 = 5;
i = 0;
i = 0;
for iCond = [1,2,4,6]-1
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)

    % plot the relation between RT and ending error
    hold on
    scatter(sbd.SacRTGoc1(datas),sbd.SacEndErrRho(datas),20,"filled",'o','CData',colorRGB(i,:));
    ylim([0,5])
    xlim([120,300])

    % % plot the relation between duration+ RT and ending error, color code
    % % by duration
    % scatter(sbd.SacRTGoc1(datas)+[Dataf1(datas).DurDelay]+[Dataf1(datas).DurFix],sbd.SacEndErrRho(datas),20,...
    %     [Dataf1(datas).DurDelay]+[Dataf1(datas).DurFix],"filled",'o');
    % colormap('turbo')
    % colorbar
    % ylim([-1,4])
    % % xlim([200,1400])
    % xlim([800,2100])

    % fit a linear model
    coefficients = polyfit(sbd.SacRTGoc1(datas), sbd.SacEndErrRho(datas), 1); % 1 indicates linear model
    SlopeK(i) = coefficients(1); % Slope
    InterceptB(i) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(sbd.SacRTGoc1(datas), sbd.SacEndErrRhoSign1(datas));
    r_value(i) = corr_matrix(1, 2); % r-value between x and y
    p_value(i) = p_matrix(1,2); 

    plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(i)+InterceptB(i),'--k','LineWidth',2);
    r_value_text = sprintf('r = %.4f', r_value(i));
    p_value_text = sprintf('p = %.4f', p_value(i));
    text(200+20, Erlim2-0.5, r_value_text, 'FontSize', 12);
    text(200+20, Erlim2-1, p_value_text, 'FontSize', 12);
    hold off

    % s1.CData = colorRGB(iCond+1,:);
    % scatter(sbd.SacRTGoc1(datas),[Dataf1(datas).DurDelay])
    if iCond == 0
        ylabel('Radial Distance to the Target, deg')
    end
    xlabel(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Radial Distance) and Reaction Time','FontSize',15)
% sgtitle('Relation Between Saccadic Ending Error (Radial Distance) and Reaction Time + Delay (from Fixation onset to Offset)','FontSize',15)

%% up and down
figure(4)
for iCond = 0:2
    datas = [Dataf1.TarDir] == iCond;
    subplot(1,3,iCond+1)
    scatter(sbd.SacRTGoc1(datas),sbd.SacEndErrRhoSign2(datas),20,"filled",'o','CData',colorRGB(iCond+1,:));
    % s1.CData = colorRGB(iCond+1,:);
    % scatter(sbd.SacRTGoc1(datas),[Dataf1(datas).DurDelay])
    % ylim([-3,5])
    xlim([100,300])
    if iCond == 0
        ylabel('Radial Distance to the Target, deg')
    end
    xlabel(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Radial Distance ud) and Reaction Time','FontSize',15)

% plot relation between ending error (angular error) and RT
figure(5)
for iCond = 0:2
    datas = [Dataf1.TarDir] == iCond;
    subplot(1,3,iCond+1)
    scatter(sbd.SacRTGoc1(datas),sbd.SacEndErrAng2Tar(datas),20,"filled",'o','CData',colorRGB(iCond+1,:));
    % s1.CData = colorRGB(iCond+1,:);
    % scatter(sbd.SacRTGoc1(datas),[Dataf1(datas).DurDelay])
    % ylim([-1,5])
    ytickValues = -2*pi :pi/2 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    % xlim([100,300])
    ylim([-pi,pi])
    if iCond == 0
        ylabel('Angular Distance to the Target, deg')
    end
    xlabel(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Angular Distance) and Reaction Time','FontSize',15)

%% Saccade ending tangent direction distance with RT
figure(15)
RTlim1 = 120;
RTlim2 = 300;
Erlim1 = -pi/4;
Erlim2 = pi/4;
i = 0;
for iCond = [1,2,4,6]-1
    i = i+1;
    datas = [Dataf1.TarDir] == iCond;
    subplot(2,2,i)
    
    % Relation with RT
    hold on

    % % Relation with RT
    scatter(sbd.SacRTGoc1(datas),sbd.SacEndErrAngTanSign(datas),20,colorRGB(i,:),'filled');

    % scatter(sbd.SacRTGoc1(datas)+[Dataf1(datas).DurDelay],sbd.SacEndErrAngTan(datas),20,...
    %     [Dataf1(datas).DurDelay],"filled",'o');
    % 
    % colormap('turbo')
    % colorbar

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);

    % fit a linear model
    coefficients = polyfit(sbd.SacRTGoc1(datas), sbd.SacEndErrAngTanSign(datas), 1); % 1 indicates linear model
    SlopeK(iCond+1) = coefficients(1); % Slope
    InterceptB(iCond+1) = coefficients(2); % Intercept

    [corr_matrix,p_matrix] = corrcoef(sbd.SacRTGoc1(datas), sbd.SacEndErrAngTanSign(datas));
    r_value(iCond+1) = corr_matrix(1, 2); % r-value between x and y
    p_value(iCond+1) = p_matrix(1,2); 
    p2 = plot(RTlim1:RTlim2,[RTlim1:RTlim2]*SlopeK(iCond+1)+InterceptB(iCond+1),'-k','LineWidth',1.5);
    r_value_text = sprintf('r = %.4f', r_value(iCond+1));
    p_value_text = sprintf('p = %.4f', p_value(iCond+1));
    text(RTlim1+20, Erlim2-0.1, r_value_text, 'FontSize', 12);
    text(RTlim1+20, Erlim2-0.2, p_value_text, 'FontSize', 12);
    hold off
    
    ylim([-pi/3,pi/3])
    % xlim([100,300])
    if iCond == 0
        ylabel('Angular Distance to the Target, deg')
    end
    xlabel(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
% sgtitle('Relation Between Saccadic Ending Direction and Reaction Time','FontSize',15)
sgtitle('Relation Between Saccadic Ending Direction and Reaction Time + Delay (from Target onset to Gocue)','FontSize',15)

%% Color code the RT on the eye traces
figure(4)

% % Normalize the Reaction time to [0,1]
% Norm_RT = (sbd.SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix] - min(sbd.SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix]))/...
%     (max(sbd.SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix])-min(sbd.SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix]));

MaxRTThrs = 300;
Norm_RT = (sbd.SacRTGoc1 - min(sbd.SacRTGoc1))/(MaxRTThrs-min(sbd.SacRTGoc1));
colorsRT = colormap(turbo);

for iCond = 0:2
    datas = find([Dataf1.TarDir] == iCond);
    
    subplot(1,3,iCond+1)
    for iTrial = datas
        if Norm_RT(iTrial) >=1
            continue
        end
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLoc = Dataf1(iTrial).EyeLocRGoc;
        TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;

        % Apply a colormap to the normalized values
        color_indices = round(Norm_RT(iTrial) * (size(colorsRT, 1) - 1)) + 1;
        MappedRT_Colors = colorsRT(color_indices,:);
        p1 = polarplot(EyeLoc(4,TimeS:TimeE)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90),EyeLoc(3,TimeS:TimeE),'LineWidth',0.6,'Color',MappedRT_Colors);
        hold on
    end
    polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    % legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
colorbar_ticks = linspace(min(sbd.SacRTGoc1), MaxRTThrs, 6); % Customize as needed
colorbar_labels = cellstr(num2str(colorbar_ticks.')); % Convert to cell array of strings
colorbar('Ticks', colorbar_ticks, 'TickLabels', colorbar_labels, 'TicksMode','auto','Position',[0.94,0.17,0.01,0.69]);

sgtitle('Saccade Traces in 3 Conditions, Aligned to Saccade Offset, Colored by RT','FontSize',15)

%% Color code the Target ending location on the eye traces
figure(4)

% % Normalize the Reaction time to [0,1]
% Norm_RT = (sbd.SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix] - min(sbd.SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix]))/...
%     (max(sbd.SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix])-min(sbd.SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix]));

for iTrial = 1:size(Dataf1,2)
    TarEndTheta(iTrial) = rad2deg(wrapToPi(Dataf1(iTrial).SacTarGoc1(3,3)));
end

MaxTarThrs = 180;
MinTarThrs = -180;
Norm_Tar = (TarEndTheta - MinTarThrs)/(MaxTarThrs-MinTarThrs);
colorsTar = colormap(turbo);

for iCond = 0:2
    datas = find([Dataf1.TarDir] == iCond);
    
    subplot(1,3,iCond+1)
    for iTrial = datas
        if Norm_Tar(iTrial) >=1
            continue
        end
        EyeLoc = [];
        TimeS = [];
        TimeE = [];
        EyeLoc = Dataf1(iTrial).EyeLocRGoc;
        TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
        TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;

        % Apply a colormap to the normalized values
        color_indices = round(Norm_Tar(iTrial) * (size(colorsTar, 1) - 1)) + 1;
        MappedTar_Colors = colorsTar(color_indices,:);
        p1 = polarplot(EyeLoc(4,TimeS:TimeE)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90),EyeLoc(3,TimeS:TimeE),'LineWidth',0.6,'Color',MappedTar_Colors);
        hold on
    end
    polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    % legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
colorbar_ticks = linspace(MinTarThrs, MaxTarThrs, 11); % Customize as needed
colorbar_labels = cellstr(num2str(colorbar_ticks.')); % Convert to cell array of strings
colorbar('Ticks', colorbar_ticks, 'TickLabels', colorbar_labels, 'TicksMode','auto','Position',[0.94,0.17,0.01,0.69]);

sgtitle('Saccade Traces in 3 Conditions, Aligned to Saccade Offset, Colored by Target Ending Location','FontSize',15)

%% Find the mean Traj Based on vanBeers 2007

iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/TarDistOnst';

% Duration for all trials


%% The simple way to calculate the average Work on this later
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

SaveName = [];
SaveName = '/TarDistOnst';

SegNum = 12; % seperate into 12 segments
AngLinspace = linspace(-pi,pi,SegNum+1);

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = [];
    AngIndices = [];
    EyeLocTht = [];
    EyeLocRad = [];

    datas = find([Dataf1.TarDir] == iCond);

    AngIndices = discretize(sbd.SacAllDir(datas), AngLinspace);

    for iTrial = datas
        EyeLocCart = [];
        EyeLocPolr = [];
        EyeLocCart = sbd.EyeLocMovXY{iTrial};
        EyeLocPolr = sbd.EyeLocMovPol{iTrial};
    end
end

%% Ways to Represent Saccade tilting 1
iCondI = 0;
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[-1919 228 1486 651]);

BoundR = [-pi/2,pi/2]; % Right side boundary

for iCond = CondI
    nexttile
    iCondI = iCondI+1;
    if iCondI == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas = [];
    datas = find([Dataf1.TarDir] == iCond);
    for iTrial = datas
        EyeLoc = [];
        TarLoc = [];
        TarLocNew = [];
        EyeLocNew = [];

        EyeLoc = [sbd.SacTraGoc1{iTrial}(1:2,:);sbd.SacTraGoc1{iTrial}(4,:);sbd.SacTraGoc1{iTrial}(3,:)];
        TarLoc = Dataf1(iTrial).SacTarGoc1(4,:); % Target at saccade off first
        [TarLoc(1,3),TarLoc(1,4)] = cart2pol(TarLoc(1,1),TarLoc(1,2));

        TarLocNew = zeros(size(TarLoc));
        EyeLocNew = zeros(size(EyeLoc));

        % Right to right side, left to left side
        if TarLoc(1,3) >= -pi/2 && TarLoc(1,3) <= pi/2
            TarLocNew(1,3) = wrapToPi(TarLoc(1,3)-TarLoc(1,3));
            TarLocNew(1,4) = TarLoc(1,4);
            EyeLocNew(3,:) = wrapToPi(EyeLoc(3,:) - TarLoc(1,3));
            EyeLocNew(4,:) = EyeLoc(4,:);
            [EyeLocNew(1,:),EyeLocNew(2,:)] = cart2pol(EyeLocNew(3,:),EyeLocNew(4,:));
        else
            TarLocNew(1,3) = TarLoc(1,3)-TarLoc(1,3)+pi;
            TarLocNew(1,4) = TarLoc(1,4);
            EyeLocNew(3,:) = wrapToPi(EyeLoc(3,:) - TarLoc(1,3)+pi);
            EyeLocNew(4,:) = EyeLoc(4,:);
            [EyeLocNew(1,:),EyeLocNew(2,:)] = cart2pol(EyeLocNew(3,:),EyeLocNew(4,:));
        end
        p1 = polarplot(EyeLocNew(3,:),EyeLocNew(4,:),'LineWidth',0.6,'Color',colorRGB(iCondI,:));
        hold on
    end
    title(LegText{iCond+1},'FontWeight','normal')
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end

for iDir = 1:2
    nexttile
    ImRegret = 0; % Why I set the condition like this?
    for iCond = CondIComp1(iDir,:)
        % calculate the mean and 95% confidence limit
        % CCW and CW have slightly different calculation ways
        ImRegret = ImRegret+1;
        iCondI = iCondIAll(iDir,ImRegret);
        
        p2 = polarplot(vfPDFSamples,klDivg(iCondI,:),'LineWidth',1,'Color',colorRGB(iCondI,:));
        title(LegText{iCond+1},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-0.2,0.3])
        hold on
        if iDir == 1 && iCondI~=1 %% CCW
            SampSel1 = vfPDFSamples >= 2/3*pi & vfPDFSamples <= 5/3*pi;
            SampSel2 = ~SampSel1;
            % left
            KlDAveAng(iCondI,1) = circ_mean(vfPDFSamples(SampSel1 & klDivg(iCondI,:)>0)',klDivg(iCondI,SampSel1 & klDivg(iCondI,:)>0)');
            KlDStdAng(iCondI,1) = circ_std(vfPDFSamples(SampSel1 & klDivg(iCondI,:)>0)',klDivg(iCondI,SampSel1 & klDivg(iCondI,:)>0)');
            % right
            KlDAveAng(iCondI,2) = circ_mean(vfPDFSamples(SampSel2 & klDivg(iCondI,:)>0)',klDivg(iCondI,SampSel2 & klDivg(iCondI,:)>0)');
            KlDStdAng(iCondI,2) = circ_std(vfPDFSamples(SampSel2 & klDivg(iCondI,:)>0)',klDivg(iCondI,SampSel2 & klDivg(iCondI,:)>0)');
        elseif iDir == 2 && iCondI~=1 %% CCW
            SampSel1 = vfPDFSamples >= 1/3*pi & vfPDFSamples <= 4/3*pi;
            SampSel2 = ~SampSel1;
            % left
            KlDAveAng(iCondI,1) = circ_mean(vfPDFSamples(SampSel1 & klDivg(iCondI,:)>0)',klDivg(iCondI,SampSel1 & klDivg(iCondI,:)>0)');
            KlDStdAng(iCondI,1) = circ_std(vfPDFSamples(SampSel1 & klDivg(iCondI,:)>0)',klDivg(iCondI,SampSel1 & klDivg(iCondI,:)>0)');
            % right
            KlDAveAng(iCondI,2) = circ_mean(vfPDFSamples(SampSel2 & klDivg(iCondI,:)>0)',klDivg(iCondI,SampSel2 & klDivg(iCondI,:)>0)');
            KlDStdAng(iCondI,2) = circ_std(vfPDFSamples(SampSel2 & klDivg(iCondI,:)>0)',klDivg(iCondI,SampSel2 & klDivg(iCondI,:)>0)');
        end

        p3 = polarplot([0,KlDAveAng(iCondI,1)],rlim,'LineWidth',1,'Color',colorRGB(iCondI,:));
        p3_1  = polarplot([0,KlDAveAng(iCondI,1)+KlDStdAng(iCondI,1)],rlim,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        p3_2  = polarplot([0,KlDAveAng(iCondI,1)-KlDStdAng(iCondI,1) ],rlim,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        p4 = polarplot([0,KlDAveAng(iCondI,2)],rlim,'LineWidth',1,'Color',colorRGB(iCondI,:));
        p4_1  = polarplot([0,KlDAveAng(iCondI,2)+KlDStdAng(iCondI,2)],rlim,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');
        p4_2  = polarplot([0,KlDAveAng(iCondI,2)-KlDStdAng(iCondI,2)],rlim,'LineWidth',1,'Color',colorRGB(iCondI,:),'LineStyle','--');

        
    end
    hold off
end


%% 10 Plot All subj's Bar figure in polar first, then I cannot add error bar
Rlim1 = [-0.2,0.2];
for iDir = 1:2
    subplot(2,1,iDir)
    UvfLeadXAll = []; LvfLeadXAll = []; UvfLaggXAll = []; LvfLaggXAll = [];
    UvfLeadY2ShuffAll = []; LvfLeadY2ShuffAll = []; UvfLaggY2ShuffAll = []; LvfLaggY2ShuffAll = [];
    for iSubj = 1:SubjSize
        SacEndErrSig = DataAll1(iSubj).SacEndErrSig;
        UvfLeadX = nan(1,4); LvfLeadX = nan(1,4); UvfLaggX = nan(1,4); LvfLaggX = nan(1,4);
        UvfLeadY2Shuff = nan(1,4); LvfLeadY2Shuff = nan(1,4); UvfLaggY2Shuff = nan(1,4); LvfLaggY2Shuff = nan(1,4);
        iCondi = 0;
        for iCond = CondIComp(iDir,1:end)
            SampXAve = []; SampYAve = []; SampY2ShuffAve = [];
            iCondi = iCondi+1;
            if isempty(SacEndErrSig(iCond).SampXAve)
                continue
            end

            SampXAve = wrapToPi(mod(SacEndErrSig(iCond).SampXAve+pi/2,2*pi));
            SampYAve = SacEndErrSig(iCond).SampYAve;
            SampY2ShuffAve = SacEndErrSig(iCond).SampY2ShuffAve;

            % for location
            % upper quadrants leading
            if ~isempty(SampXAve((SampXAve >= 0) & (SampY2ShuffAve>=0))')
                UvfLeadX(iCondi) = circ_mean(SampXAve((SampXAve >= 0) & (SampY2ShuffAve>=0))');
            end
            % upper quadrants lagging
            if ~isempty(SampXAve((SampXAve >= 0) & (SampY2ShuffAve<=0))')
                UvfLaggX(iCondi) = circ_mean(SampXAve((SampXAve >= 0) & (SampY2ShuffAve<=0))');
            end
            % Lower quadrants leading
            if ~isempty(SampXAve((SampXAve <= 0) & (SampY2ShuffAve>=0))')
                LvfLeadX(iCondi) = circ_mean(SampXAve((SampXAve <= 0) & (SampY2ShuffAve>=0))');
            end
            % Lower quadrants lagging
            if ~isempty(SampXAve((SampXAve <= 0) & (SampY2ShuffAve<=0))')
                LvfLaggX(iCondi) = circ_mean(SampXAve((SampXAve <= 0) & (SampY2ShuffAve<=0))');
            end

            % for leadding and lagging mag
            % upper quadrants leading
            if ~isempty(SampY2ShuffAve((SampY2ShuffAve >= 0) & (SampXAve>=0))')
                UvfLeadY2Shuff(iCondi) = circ_mean(SampY2ShuffAve((SampY2ShuffAve >= 0) & (SampXAve>=0))');
            end
            % upper quadrants lagging
            if ~isempty(SampY2ShuffAve((SampY2ShuffAve <= 0) & (SampXAve>=0))')
                UvfLaggY2Shuff(iCondi) = circ_mean(SampY2ShuffAve((SampY2ShuffAve <= 0) & (SampXAve>=0))');
            end
            % Lower quadrants leading
            if ~isempty(SampY2ShuffAve((SampY2ShuffAve >= 0) & (SampXAve<=0))')
                LvfLeadY2Shuff(iCondi) = circ_mean(SampY2ShuffAve((SampY2ShuffAve >= 0) & (SampXAve<=0))');
            end
            % Lower quadrants lagging
            if ~isempty(SampY2ShuffAve((SampY2ShuffAve <= 0) & (SampXAve<=0))')
                LvfLaggY2Shuff(iCondi) = circ_mean(SampY2ShuffAve((SampY2ShuffAve <= 0) & (SampXAve<=0))');
            end
        end
        
        % for x, location
        UvfLeadXAll = [UvfLeadXAll;UvfLeadX];
        UvfLaggXAll = [UvfLaggXAll;UvfLaggX];
        LvfLeadXAll = [LvfLeadXAll;LvfLeadX];
        LvfLaggXAll = [LvfLaggXAll;LvfLaggX];

        % for y, mag
        UvfLeadY2ShuffAll = [UvfLeadY2ShuffAll;UvfLeadY2Shuff];
        UvfLaggY2ShuffAll = [UvfLaggY2ShuffAll;UvfLaggY2Shuff];
        LvfLeadY2ShuffAll = [LvfLeadY2ShuffAll;LvfLeadY2Shuff];
        LvfLaggY2ShuffAll = [LvfLaggY2ShuffAll;LvfLaggY2Shuff];
    end
    b = bar(UvfLeadXAll);
    for k = 1:size(UvfLeadXAll,2)
        b(k).FaceColor = colorRGB(CondIComp(iDir,k),:);
    end
    hold on
    b = bar(LvfLeadXAll);
    for k = 1:size(LvfLeadXAll,2)
        b(k).FaceColor = colorRGB(CondIComp(iDir,k),:);
    end
end

%% 11 check the catchup saccade during smooth pursuit
for iTrial = 1:size(DatafN,2)
    if isempty(DatafN(iTrial).SacLocGoc2)
        continue
    end
    % if the trial end before 50ms
    if sbd.SacETmGoc1(iTrial)+50 >= size(DatafN(iTrial).EyeLocRAcc,2)
        continue
    end
    SmPVSec = []; SmPSecCheck = []; SmPASec = [];
    % found the smp section first
    % I hate acceleration method
    try
        SmPVSec = DatafN(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+50:sbd.SacETmGoc1(iTrial)+120);
        % I may need Acc to find the saccade during smooth pursuit. I didnt
        % * 1000 in ReadEyeLoc.m
        SmPASec = DatafN(iTrial).EyeLocRAcc(6,sbd.SacETmGoc1(iTrial)+50:sbd.SacETmGoc1(iTrial)+120)*1000;
    catch % if the trial end before 120ms
        SmPVSec = DatafN(iTrial).EyeLocRVel(6,sbd.SacETmGoc1(iTrial)+50:end);
        SmPASec = DatafN(iTrial).EyeLocRAcc(6,sbd.SacETmGoc1(iTrial)+50:end)*1000;
    end
    % Mark the onset and offset based on the SmPASec
    SmPSecCheckS = zeros(size(SmPASec)); SmPSecCheckE = zeros(size(SmPASec));
    SmPSecCheckS(SmPASec>=AccThres) = 1; SmPSecCheckE(SmPASec<=-AccThres) = 1;
    % Start Time
    TimeS = find(diff([0, SmPSecCheckS]) == 1);
    % End Time
    TimeE = find(diff([SmPSecCheckE, 0]) == -1);
    % refill the start time and end time if the section contaion half sac
    if ~isempty(TimeE)&& ~isempty(TimeS)&&TimeE(1)<TimeS(1)|| isempty(TimeS) && ~isempty(TimeE)
        TimeS = [1, TimeS]; end
    if ~isempty(TimeE)&& ~isempty(TimeS)&&TimeS(end)>TimeE(end)|| isempty(TimeE) && ~isempty(TimeS)
        TimeE = [TimeE length(SmPASec)]; end
    SmPSecCheck = ones(size(SmPASec));
    for iCheck = 1:length(TimeS)
        SmPSecCheck(TimeS(iCheck):TimeE(iCheck)) = 0;
    end
    SmPSecCheck = logical(SmPSecCheck);
    sbd.SmPVelGoc1(iTrial) = mean(SmPVSec(SmPSecCheck),"omitmissing");  
end

%% 12 KL-Divergence on target location
vfEstimateTarg = [];
for iCond = CondI
    datas1 = [];
    datas1 = find([DatafN.TarDir1] == iCond & ([DatafN.TrialStatus] == 1 | [DatafN.TrialStatus] == 5));
    TargEndTta = zeros(size(datas1));
    TargEndTta = wrapTo2Pi(sbd.TarEnd2E(3,datas1));
    vfPDFSamples = 0:StepSZ:2*pi;
    vfEstimateTarg(iCond,:) = circ_ksdensity(TargEndTta, vfPDFSamples, [0, 2*pi], fSigma);
end
sbd.vfEstimateTarg = vfEstimateTarg;

% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[-1919 228 1486 651]);

    SaveName = [];
    SaveName = '/TargDir2EKL';
    TitleName = [];
    % TitleName = 'SacDirKDE kernel: 0.3 rad, step: 5 deg';
    TitleName = 'SacDirKLdiver kernel: 0.3 rad, step: 5 deg';

    klDivgTarg = [];
    vfPDFSamples = sbd.vfPDFSamples;

    for iCond = CondI
        nexttile
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile; % This creates the (2,1) tile
        end
        vfEstimate2 = []; vfEstimate2 = sbd.vfEstimateTarg(iCond,:);
        vfEstimate1 = []; vfEstimate1 = sbd.vfEstimateTarg(1,:);
        klDivgTarg(iCond,:) = circ_kldivergence(vfEstimate2,vfEstimate1,vfPDFSamples);
        p2 = polarplot(vfPDFSamples,klDivgTarg(iCond,:),'LineWidth',2,'Color',colorRGB(iCond,:));
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
        rlim([-0.15,0.3])
        hold on
    end
    sbd.klDivgTarg = klDivgTarg;
    % sgtitle([TitleName, ' Subj ', userID],'FontSize',15)
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 13 GMM and linear mixed model
% GMM and fit linear mixed effects model
gm = fitgmdist([XVAll;YVAll]', 1);
D = mahal(gm,[XVAll;YVAll]');  % Squared Mahalanobis distance
% 95% ellipse threshold for 2D
thresh = chi2inv(0.95, 2);
inliers = D < thresh;
tblGMM = table(XVAll(inliers)', YVAll(inliers)', SubjID(inliers)');
tblGMMPred = table(XDots, repmat(2, size(XDots)));
tblGMMPred.Properties.VariableNames = {'Var1', 'Var3'};
lmeGMM = fitlme(tblGMM, 'Var2 ~ Var1 + (Var1|Var3)');
[YPred2, ~] = predict(lmeGMM, tblGMMPred);
hline2 = plot(XDots, YPred2,'k--','linewidth',2);
r21 = 1 - (lmeGMM.SSE / lmeGMM.SST);
pval2 = lmeGMM.Coefficients.pValue(2);
legendStr2 = sprintf('GmmLME: R^2 = %.2f, p = %.2g', r21, pval2);
% plot the 95% ellipse
error_ellipseJPM([XVAll;YVAll]', 0.95, 'k');

%% 14 P value bootstrap wrong method
% function pVals = F_BootSpVEachX(BootSPara1,BootSPara2, BootSSz)
% This code is used to calculate the BootS p Value
% The result output will be the two-sided p-value at each x, therefore each
% group should have same length of X
% BootSPara are results from F_BootSCartSlidWin Functions, 
% Para1 for the group 1; Para2 for the group 2
% BootSSz are the BootS repeatted times
% Created on Jul 11, 2025, Xuan

% assign diff values
SampYAve1 = BootSPara1.SampYAve; % BootSSz * numY, BootsStrap all repeats for group 1
SampYAve2 = BootSPara2.SampYAve; % BootSSz * numY, BootsStrap all repeats for group 2
YAveOrig1 = BootSPara1.YAveOrig; % BootSSz * 1, Ave of all repeats for group 1
YAveOrig2 = BootSPara2.YAveOrig; % BootSSz * 1, Ave of all repeats for group 2

obsAveDiff = YAveOrig1 - YAveOrig2; % BootSSz * 1
BootSDiff = SampYAve1 - SampYAve2; % BootSSz * numY

% count how many bootstrap diffs are at least as large in magnitude as the observed
% this is same as {d >= o} AND {d <= -o}
extremeCount = sum( abs(BootSDiff) >= abs(obsAveDiff) , 1); % 1 * numY
pVals = extremeCount./ (BootSSz+1); % 1 * numY

% end

%% 15. BootStrap compare with null distribution, Jul 15, 2025, Xuan
% function pVals = F_BootSStat_pV2(BootSPara, ShuffPara, ReTime)
% This code is used to calculate the BootS p Value
% It is the comparesion between the dataset with it own shuffle
% The result output will be the two-sided p-value at each x, therefore each
% group should have same length of X
% BootSPara are results from F_BootSCartSlidWin Functions, 
% BootSPara for the BootStrap result; ShuffPara for the shuffled result
% ReTime are the BootS repeatted times
% Created on Jul 12, 2025, Xuan

% assign the values
SampYAveAve = BootSPara.SampYAveAve;
ShufYAve = ShuffPara.ShuffYAve;
ShufYAveAve = ShuffPara.ShuffYAveAve;

% center the null
obsAveDiff = SampYAveAve - ShufYAveAve;
bootsDiff = ShufYAve - ShufYAveAve(ones(ReTime,1),:);

% count how many bootstrap diffs are at least as large in magnitude as the observed
% this is same as {d >= o} AND {d <= -o}
extremeCount = sum( abs(bootsDiff) >= abs(obsAveDiff) , 1); % 1 * numY
pVals = extremeCount./ (ReTime+1); % 1 * numY
% end


%% 16 plot the example bootstrap
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);

    winSize = pi/4;
    stepSize = winSize/15;
    winRange = [0,2*pi];

    if exist('SacEndErrAngBootS','var') 
        clearvars SacEndErrAngBootS; end
    ReTime = 1000;

    iCond = 3; % CCW of 45 deg
    datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
    XV = []; YV = [];
    XV = mod(wrapTo2Pi(sbd.TarEnd2E(3,datas1))-pi/2,pi*2);
    YV = sbd.SacEndErrAng2ESignDeSta(datas1);
    % plot the bootstrap sliding window
    SampS = length(XV);
    SacEndErrAngBootS = F_BootSCartSlidWin2(XV',YV',SampS,ReTime,winSize,stepSize,winRange);
    
    colorRGB2(iCond,:) = [0,0,0];
    % the first figure
    nexttile
    hold on
    scatter(XV,YV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
    SampN = SacEndErrAngBootS.SampNAll(1,:);
    scatter(XV(SampN),YV(SampN),60,'Marker','diamond','MarkerEdgeColor',colorRGB2(iCond,:),'LineWidth',1);
    SampN = SacEndErrAngBootS.SampNAll(3,:);
    scatter(XV(SampN),YV(SampN),60,'Marker','*','MarkerEdgeColor',colorRGB2(iCond,:),'LineWidth',1);
    
    xline(pi/2,'LineWidth',1.5,'LineStyle','--');
    xline(pi,'LineWidth',1.5,'LineStyle','--');
    xline(3*pi/2,'LineWidth',1.5,'LineStyle','--');

    xticks(deg2rad([0,90,180,270,360]))
    xticklabels([90,180,270,0,90])
    xlim(deg2rad([-5,365]))
    ylim(deg2rad([-30,90]))
    yticks(deg2rad(-30:30:90))
    yticklabels(-30:30:90)

    xlabel('Targ Direction at Sacc End')
    ylabel('De-Sta-Trend Sacc-Targ End Direction Difference')

    set(gca,'FontSize',15)
    hold off

    % the second figure
    nexttile
    hold on
    scatter(XV,YV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
    
    SampN = SacEndErrAngBootS.SampNAll(1,:);
    scatter(XV(SampN),YV(SampN),60,'Marker','diamond','MarkerEdgeColor',colorRGB2(iCond,:),'LineWidth',1);
    SampN = SacEndErrAngBootS.SampNAll(3,:);
    scatter(XV(SampN),YV(SampN),60,'Marker','*','MarkerEdgeColor',colorRGB2(iCond,:),'LineWidth',1);
    
    SampXAve = SacEndErrAngBootS.SampXAve(1,:); SampYAve = SacEndErrAngBootS.SampYAve(1,:);
    [SampXAve, I] = sort(SampXAve);
    SampYAve = SampYAve(I);
    plot(SampXAve,SampYAve,'color',colorRGB2(iCond,:),'LineStyle',':','LineWidth',1);

    SampXAve = SacEndErrAngBootS.SampXAve(3,:); SampYAve = SacEndErrAngBootS.SampYAve(3,:);
    [SampXAve, I] = sort(SampXAve);
    SampYAve = SampYAve(I);
    plot(SampXAve,SampYAve,'color',colorRGB2(iCond,:),'LineStyle','-.','LineWidth',1);
    
    xline(pi/2,'LineWidth',1.5,'LineStyle','--');
    xline(pi,'LineWidth',1.5,'LineStyle','--');
    xline(3*pi/2,'LineWidth',1.5,'LineStyle','--');

    xticks(deg2rad([0,90,180,270,360]))
    xticklabels([90,180,270,0,90])
    xlim(deg2rad([-5,365]))
    ylim(deg2rad([-30,90]))
    yticks(deg2rad(-30:30:90))
    yticklabels(-30:30:90)
    
    set(gca,'FontSize',15)

    hold off

    % the final figure
    nexttile
    hold on
    scatter(XV,YV,'MarkerFaceColor',colorRGB(iCond,:),'MarkerEdgeColor','none');
    % assign data
    SampXAveAve = []; SampYAveAve = []; SampYLCI95Ave = []; SampYUCI95Ave = [];
    SampXAveAve = SacEndErrAngBootS.SampXAveAve; SampYAveAve = SacEndErrAngBootS.SampYAveAve;
    SampYLCI95Ave = SacEndErrAngBootS.SampYLCI95Ave; SampYUCI95Ave = SacEndErrAngBootS.SampYUCI95Ave;
    [SampXAveAve, I] = sort(SampXAveAve);
    SampYAveAve = SampYAveAve(I);
    SampYLCI95Ave = SampYLCI95Ave(I);
    SampYUCI95Ave = SampYUCI95Ave(I);

    % use boundedline to plot which can also skip the nan point
    [hl1,hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
    set(hl1,'color','k','LineStyle','-','LineWidth',1.5);
    set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

    xline(pi/2,'LineWidth',1.5,'LineStyle','--');
    xline(pi,'LineWidth',1.5,'LineStyle','--');
    xline(3*pi/2,'LineWidth',1.5,'LineStyle','--');

    xticks(deg2rad([0,90,180,270,360]))
    xticklabels([90,180,270,0,90])
    xlim(deg2rad([-5,365]))
    ylim(deg2rad([-30,90]))
    yticks(deg2rad(-30:30:90))
    yticklabels(-30:30:90)

    hold off

    set(gca,'FontSize',15)

    nexttile
    nexttile
    nexttile
    nexttile
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 17 Bootstrap comparision at groupped level.
%function pVals = F_BootSStat_GroupAve_pV5(ObsV, NullV, ObsVAve, NullVAve, ReTime)
% This code is used to calculate the BootS p Value
% It is used for subject level bootstrap of the group-mean difference
% before using this code, I should already have each subjects' boots and
% null traces, and the average of them
% then I get the bootstrap distribution of the group-mean difference by
% resampling subjects with replacements

% ObsV: each subject's observation vectors
% NullV: each subjects' null vectors
% ObsVAve: averaged subject's observation vectors
% NullVAve: averaged subject's null vectors
% ReTime are the BootS repeatted times

% Created on Jul 12, 2025, Xuan
rng("shuffle")
% plot the observed sliding window first..
obsDiff = ObsVAve - NullVAve; %observation to null diff

% Pool the data together
bootsDiff = zeros(ReTime, numel(obsDiff));
SampS = size(ObsV,1);
for iReTime = 1:ReTime
    idx = randi(SampS,1,SampS);
    gobs = circ_mean_nan(ObsV(idx,:));  % 1×numX
    gnull = circ_mean_nan(NullV(idx,:));
    bootsDiff(iReTime,:) = gobs - gnull;
end
obsDiffAll = obsDiff(ones(ReTime,1),:);

% count how many bootstrap diffs are at least as large in magnitude as the observed
% this is same as {d >= o} AND {d <= -o}
extremeCount = sum( abs(bootsDiff) >= abs(obsDiffAll) , 1); % 1 * numY
pVals = extremeCount./ (ReTime+1); % 1 * numY


%% 18 old F_CartScaMovNorm
% function [XNorm, YNorm, XIndAll] = F_CartScaMovNorm(winSize,stepSize,XV,XVbase,YV,YVbase,winRange)
% This function is used for the moving window averaging for scatter plot
% the input will be windowsize, stepsize (usually same as winSize especially for scatter plot)
% XV X value, YV Y value, YVbase caucluate the mean value vector
% winRange the start and end of the window
% The main goal of this code is to do the normalization 
% Created by Xuan, May 09 2024
% Adjusted on Jun 20 2024, remove the devided by std part, now only compare
% with the Ybase
% Adjusted on July 24 2024, output the order which is XIndAll
% Adjusted on Mar 05 2025, Changed to a new way so that the output will be more clear

% Initialize vectors to hold the moving average results
XNorm = nan(size(XV));
YNorm = nan(size(YV));
XIndAll = [];

% Define the start and end points of the moving window
for stWin = winRange(1):stepSize:winRange(2)
    edWin = stWin + winSize;

    % Find the indices of XV that fall within the current window
    XIndbase = XVbase >= stWin & XVbase < edWin;

    XWinbase = XVbase(XIndbase);
    YWinbase = YVbase(XIndbase);

    % Skip if no data points fall within the window range
    if isempty(XWinbase)
        continue;
    end

    % Calculate mean vector length for the window
    YAvebase1 = circ_mean_nan(YWinbase);

    % Start the normalization based on the YAvebase and YStdbase
    XInd = XV >= stWin & XV < edWin;
    % YNorm1 = (YWin-YAvebase1)./YStdbase1;
    XNorm(XInd) = XV(XInd);
    YNorm(XInd) = wrapToPi(YV(XInd)-YAvebase1);

    XIndAll = [XIndAll; find(XInd==1)];

end
% end

%% 18. plot all the subjects data together with mean value across and sigbar, CCW and flipped CW 0mean, 
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_Comb_XY_DeSta_BootS_Shuff_SigBar';
    SampXAveAveAllAve = []; SampYAveAveAllAve = []; SampYAveAveAllStd = []; SampYAveAveAllSE = [];
    SampXAveAveAllCondi = cell(1,4); 
    SampYAveAveAllCondi = cell(1,4);
    ShuffYAveAveAllCondi = cell(1,4);
    pVals = cell(1,4);
    ReTime = 1000;
    for iCond = CondIComp(1,2:end)
        nexttile;
        hold on
        SampYAveAveAll = []; SampXAveAveAll = []; ShuffYAveAveAll = [];

        for iSubj = 1:SubjSize
            SacEndErrAngBootS = DataAll1(iSubj).sbd.SacEndErrAngBootS_DeSta_Cen;
            SacEndErrAngShuff = DataAll1(iSubj).sbd.SacEndErrAngShuff_DeSta_Cen;

            % load the bootstrap result
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
            % load the shuff result for the future comparision
            ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;
            % combine the result
            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
            SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
            ShuffYAveAveAll = [ShuffYAveAveAll; ShuffYAveAve];

            % sort the result
            [SampXAveAve, I] = sort(SampXAveAve);
            SampYAveAve = SampYAveAve(I);
            ShuffYAveAve = ShuffYAveAve(I);

            % plot the mean value for each subj
            plot(SampXAveAve,SampYAveAve,'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',2)

            % for the flipped result
            iCondi = CondIComp(2,iCond);
            SampXAveAve = fliplr(2*pi - SacEndErrAngBootS(iCondi).SampXAveAve);
            SampYAveAve = fliplr(SacEndErrAngBootS(iCondi).SampYAveAve);
            ShuffYAveAve = fliplr(SacEndErrAngShuff(iCondi).ShuffYAveAve);
            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
            SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
            ShuffYAveAveAll = [ShuffYAveAveAll; ShuffYAveAve];
            [SampXAveAve, I] = sort(SampXAveAve);
            SampYAveAve = SampYAveAve(I);
            ShuffYAveAve = ShuffYAveAve(I);
            plot(SampXAveAve,SampYAveAve,'color',colorRGB1(iCond,:),'LineStyle','--','LineWidth',2)

        end
        SampXAveAveAllCondi{iCond} = SampXAveAveAll;
        SampYAveAveAllCondi{iCond} = SampYAveAveAll;
        ShuffYAveAveAllCondi{iCond} = ShuffYAveAveAll;
        % plot all subject's data
        SampXAveAveAllAve(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll));
        SampYAveAveAllAve(iCond,:) = circ_mean_nan(SampYAveAveAll);
        SampYAveAveAllStd(iCond,:) = circ_std_nan(SampYAveAveAll);
        ShuffYAveAveAllAve(iCond,:) = circ_mean_nan(ShuffYAveAveAll);
        SampYAveAveAllSE(iCond,:) = SampYAveAveAllStd(iCond,:)/sqrt(SubjSize);
        
        yline(0,'k--','LineWidth',1)

        % sort the result
        [~, I] = sort(SampXAveAveAllAve(iCond,:));
        % use boundedline to plot which can also skip the nan point
        [hl,hp] = boundedline(SampXAveAveAllAve(iCond,I),SampYAveAveAllAve(iCond,I),SampYAveAveAllSE(iCond,I));
        set(hl,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3);
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        % plot the significance bar
        % pVals{iCond} = F_BootSStat_GroupAve_pV5(SampYAveAveAll, ShuffYAveAveAll, ...
        %     SampYAveAveAllAve(iCond,:), ShuffYAveAveAllAve(iCond,:), ReTime);
        pVals{iCond} = F_BootSStat_GroupAve_pV5(SampYAveAveAll, ShuffYAveAveAll);
        % do the FDR correction
        pVals{iCond} = mafdr(pVals{iCond},'BHFDR', true);
        % pVals{iCond} = mafdr(pVals{iCond});
        F_CartPlotSigBar(SampXAveAveAllAve(iCond,I), pVals{iCond}(I), 0.05, deg2rad(40));
        
        xticks(deg2rad([0,90,180,270,360]))
        xticklabels([90,180,270,0,90])
        xlim(deg2rad([-5,365]))
        ylim(deg2rad([-30,50]))
        yticks(deg2rad(-30:15:30))
        yticklabels(-30:15:30)

        if iCond == 2
            xlabel('Target Direction at Sacc End, deg')
            ylabel('Sacc End Direction Difference - Sta, deg')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',17)
    end
%     GroupStatR.pVals_CombCondi = pVals;
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 19 plot the ending error distribution, ksdensity for each subject and then ave across
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = 'SacEndErr_KSDst_AllSubj';
    XGrid = linspace(-40,40,100);
    for iCond = CondIComp(1,1:end)
        nexttile;
        hold on
        density_matrix = nan(SubjSize,length(XGrid));
        dataSize = nan(SubjSize,1);
        for iSubj = 1:SubjSize
            datas1 = [];
            datas1 = find(([DataAll1(iSubj).sbd.TarDir] == iCond | [DataAll1(iSubj).sbd.TarDir] == CondIComp(2,iCond))...
                & ([DataAll1(iSubj).sbd.TrialStatus] == 1 |[DataAll1(iSubj).sbd.TrialStatus] == 5));
            XV = rad2deg(DataAll1(iSubj).sbd.SacEndErrAng2ESignDeStaCen2(datas1));
            % do the ksdensity
            f = ksdensity(XV,XGrid);
            density_matrix(iSubj, :) = f;
            dataSize(iSubj) = length(datas1);
            plot(XGrid,f,'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',1.5)
        end
        dataSizeProb = dataSize./sum(dataSize);
        density_matrix_Weighted = density_matrix.*dataSizeProb;
        Alldensity = sum(density_matrix_Weighted, 1);
        % plot the all density
        hl = plot(XGrid,Alldensity);
        set(hl,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);

        % plot the mean_density_mean
        xline(0,'k--','LineWidth',1.5)
        
        xlim([-40,40])
        xticks(-40:20:40)
        ylim([0,0.15])
        xline(0,'k--','LineWidth',1.5)
        hold off

        if iCond == 1
            xlabel('Saccade Ending Error, deg')
            ylabel('Density')
        end

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',16)
        hold off

    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end


%% Calculate the pre-Saccade pursuit vel in Behavior Ana
% calculate pre-saccade pursuit vel, ignore 0 delay trials
if ~isnan(DatafN(iTrial).TimeGocOn)
    if sbd.SacSTmGoc1(iTrial)-preSacPurLen >= DatafN(iTrial).TimeGocOn
        sbd.SmPLVelAllGoc0(iTrial,:) = DatafN(iTrial).EyeLocRVel(6,sbd.SacSTmGoc1(iTrial)-preSacPurLen:sbd.SacSTmGoc1(iTrial)-1);
        sbd.SmPLAccAllGoc0(iTrial,:) = DatafN(iTrial).EyeLocRAcc(6,sbd.SacSTmGoc1(iTrial)-preSacPurLen:sbd.SacSTmGoc1(iTrial)-1)*1000;
    else
        sbd.SmPLVelAllGoc0(iTrial,preSacPurLen-sbd.SacRTGoc1(iTrial)+1:end) = ...
            DatafN(iTrial).EyeLocRVel(6,sbd.SacSTmGoc1(iTrial)-sbd.SacRTGoc1(iTrial):sbd.SacSTmGoc1(iTrial)-1);
        sbd.SmPLAccAllGoc0(iTrial,preSacPurLen-sbd.SacRTGoc1(iTrial)+1:end) = ...
            DatafN(iTrial).EyeLocRAcc(6,sbd.SacSTmGoc1(iTrial)-sbd.SacRTGoc1(iTrial):sbd.SacSTmGoc1(iTrial)-1)*1000;
    end
end



