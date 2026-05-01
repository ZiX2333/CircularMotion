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

