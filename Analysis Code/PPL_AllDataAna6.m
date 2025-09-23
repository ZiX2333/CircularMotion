% Data Processing
% This script is used for data processing for all subject's data
% Created on Jun 19
%   Main use for ending error relevant analysis
% Adjusted on July 23 2024
%   Add the KL divergence cross subject analysis
% Adjusted on Aug 05 2024
%   Add the comparision
% Adjusted on Sep 12 2024
%   Plot the ending error in polar plot
% Adjusted on Sep 16
%   Plot the ending error in polar plot with eye axis
% Adjusted on Sep 18
%   Plot the polar plot of the RT

%% Basic info
LegText = [{'Stationary'},{'CCW 15'},{'CCW 30'},{'CCW 45'},{'CW 15'},{'CW 30'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';

% CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
CondIComp = [1,2,3,4; 1,5,6,7]; % When I want to compare with stationary
CondICompName = {'CCW','CW'};
CondName = '_1';

colorRGB = [0 0.4470 0.7410;... % blue
    0.9290 0.6940 0.1250;... %yellow
    0.4660 0.6740 0.1880;... % green;
    0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250;... %yellow
    0.4660 0.6740 0.1880;... % green;
    0.8500 0.3250 0.0980];% orange
% light one
colorRGB1 = [202, 218, 237;...
    248, 222, 126;... % 246, 219, 117
    206, 232, 195;...
    246, 210, 168;...
    248, 222, 126;... % 246, 219, 117
    206, 232, 195;...
    246, 210, 168]/255;
% dark one
colorRGB2 = [72, 128, 184;... %blue
    206, 137, 56;... % yellow 238, 169, 60 194, 123, 55
    85, 161, 92;... % green),2)
    213, 95, 43;...
    206, 137, 56;... % yellow 238, 169, 60
    85, 161, 92;... % green),2)
    213, 95, 43]/255; %pink/orange

ifDoBasic = 1;
SubjSize = length(DataAll1);
iFigAcc = 0;
SecNum = 0;

%% 1 find the significant part and plot all the subjects data together
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2C_XY_Norm_BootS_Shuff_Marked_Comp_2Shuff_AllSubj';
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        hold on
        SampYAveAveAll = []; SampXAveAveAll = [];
        for iSubj = 1:SubjSize
            SacEndErrAngBootS = []; SacEndErrAngShuff = [];
            SacEndErrAngBootS = DataAll1(iSubj).sbdBoots.SacEndErrAngBootS_TarAxis;
            SacEndErrAngShuff = DataAll1(iSubj).sbdBoots.SacEndErrAngShuff_TarAxis;

            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
            SampYLCI95 = SacEndErrAngBootS(iCond).SampYCI95(1,:);
            SampYUCI95 = SacEndErrAngBootS(iCond).SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;
            % load the shuff result for the future comparision
            ShuffYAveAve = [];
            ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;

            SampYAveAve = SampYAveAve-ShuffYAveAve;

            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','none','LineWidth',2);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')

        end
        for iSubj = 1:SubjSize
            SacEndErrAngBootS = []; SacEndErrAngShuff = [];
            SacEndErrAngBootS = DataAll1(iSubj).sbdBoots.SacEndErrAngBootS_TarAxis;
            SacEndErrAngShuff = DataAll1(iSubj).sbdBoots.SacEndErrAngShuff_TarAxis;

            SampXAveAve = []; SampYAveAve = []; Samp2Shuff95 = []; ShuffYAveAve = [];
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
            % Load the comparision result
            Samp2Shuff95 = SacEndErrAngShuff(iCond).Samp2Shuff95;
            % load the shuff result for the future comparision
            ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;

            SampYAveAve = SampYAveAve-ShuffYAveAve;

            plot(SampXAveAve,SampYAveAve,'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2)

            % mark the above part
            MarkC = [205, 45, 48]/255;
            % Find starts and ends of blocks of 95% CI
            starts = find(diff([0, Samp2Shuff95]) == 1);
            ends = find(diff([Samp2Shuff95, 0]) == -1);
            % also include the data between starts and starts-1
            for iChunk = 1:length(starts)
                %plot 95% first
                starts(iChunk) = max(1,starts(iChunk));
                ends(iChunk) = min(length(SampXAveAve),ends(iChunk));
                plot(SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
                    '-','Color',colorRGB2(iCond,:),'LineWidth',4);
            end
        end

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45});
        if iCond == 1
            xlabel('Target Direction at Sacc End')
            ylabel('Normed Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 2 find the significant part and plot all the subjects data together with mean value across
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    % SaveName = [];
    % SaveName = 'SacEndErr_Tar_2C_XY_Norm_BootS_Shuff_Marked_Comp_2Shuff_AllSubj_Ave';
    SampXAveAveAllAve = [];
    SampYAveAveAllAve = []; SampYAveAveAllStd = []; SampYAveAveAllSE = [];
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        hold on
        SampYAveAveAll = []; SampXAveAveAll = [];
        for iSubj = 1:SubjSize
            SacEndErrAngBootS = []; SacEndErrAngShuff = [];
            SacEndErrAngBootS = DataAll1(iSubj).sbdBoots.SacEndErrAngBootS_TarAxis;
            SacEndErrAngShuff = DataAll1(iSubj).sbdBoots.SacEndErrAngShuff_TarAxis;

            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
            SampYLCI95 = SacEndErrAngBootS(iCond).SampYCI95(1,:);
            SampYUCI95 = SacEndErrAngBootS(iCond).SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;
            % load the shuff result for the future comparision
            ShuffYAveAve = [];
            ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;

            SampYAveAve = SampYAveAve-ShuffYAveAve;

            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','none','LineWidth',2);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.1,'EdgeColor','none')

        end
        for iSubj = 1:SubjSize
            SacEndErrAngBootS = []; SacEndErrAngShuff = [];
            SacEndErrAngBootS = DataAll1(iSubj).sbdBoots.SacEndErrAngBootS_TarAxis;
            SacEndErrAngShuff = DataAll1(iSubj).sbdBoots.SacEndErrAngShuff_TarAxis;

            SampXAveAve = []; SampYAveAve = []; Samp2Shuff95 = []; ShuffYAveAve = [];
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
            % Load the comparision result
            Samp2Shuff95 = SacEndErrAngShuff(iCond).Samp2Shuff95;
            % load the shuff result for the future comparision
            ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;

            SampYAveAve = SampYAveAve-ShuffYAveAve;

            plot(SampXAveAve,SampYAveAve,'color',[colorRGB1(iCond,:),0.8],'LineStyle','-','LineWidth',2)

            % mark the above part
            MarkC = [205, 45, 48]/255;
            % Find starts and ends of blocks of 95% CI
            starts = find(diff([0, Samp2Shuff95]) == 1);
            ends = find(diff([Samp2Shuff95, 0]) == -1);
            % also include the data between starts and starts-1
            for iChunk = 1:length(starts)
                %plot 95% first
                starts(iChunk) = max(1,starts(iChunk));
                ends(iChunk) = min(length(SampXAveAve),ends(iChunk));
                plot(SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
                    '-','Color',[colorRGB1(iCond,:),0.8],'LineWidth',4);
            end
            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
            SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
        end

        % plot all subject's data
        SampXAveAveAllAve(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll));
        SampYAveAveAllAve(iCond,:) = circ_mean_nan(SampYAveAveAll);
        SampYAveAveAllStd(iCond,:) = circ_std_nan(SampYAveAveAll);
        SampYAveAveAllSE(iCond,:) = SampYAveAveAllStd(iCond,:)/sqrt(SubjSize);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(SampXAveAveAllAve(iCond,:),SampYAveAveAllAve(iCond,:),SampYAveAveAllSE(iCond,:));
        set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3);
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45});
        if iCond == 1
            xlabel('Target Direction at Sacc End')
            ylabel('Normed Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',17)

    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 3 plot all the mean value together for all subjects and compare between moving direction in polar plot
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2E_Polar_Norm_BootS_Shuff_Marked_Comp_AllSubj';

    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        for iCond = CondIComp(iDir,2:end)
            % plot the result saved above
            % use boundedline to plot which can also skip the nan point
            % need to flip the stationary in CW condition
            CurX = [];
            CurX = mod(SampXAveAveAllAve(iCond,:)+pi/2,2*pi); RearD1 = []; RearD2 = [];
            RearD1 = SampYAveAveAllAve(iCond,1);
            RearD2 = SampYAveAveAllSE(iCond,1);
            polarplot([CurX,CurX(1)],[SampYAveAveAllAve(iCond,:),RearD1],'color',colorRGB(iCond,:),'LineStyle','-','LineWidth',2);
            hold on
            polarplot([CurX,CurX(1)],[SampYAveAveAllAve(iCond,:)-SampYAveAveAllSE(iCond,:),RearD1-RearD2],...
                'color',[colorRGB1(iCond,:),0.3],'LineStyle','-','LineWidth',2);
            polarplot([CurX,CurX(1)],[SampYAveAveAllAve(iCond,:)+SampYAveAveAllSE(iCond,:),RearD1+RearD2],...
                'color',[colorRGB1(iCond,:),0.3],'LineStyle','-','LineWidth',2);
        end
        
        polarplot(0:0.01:2*pi,zeros(size(0:0.01:2*pi)),'LineStyle',':','Color','k','LineWidth',1.5)
        
        hold off

        rlim([-pi/12,pi/12]);
        rticks([-pi/18,0,pi/18])
        rticklabels({'-10°','0°','10°'})

        title(CondICompName{iDir},'FontWeight','normal')
        set(gca,'FontSize',16)
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% Plot the first and second differentiation
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    % SaveName = [];
    % SaveName = 'SacEndErr_Tar_2C_XY_Norm_BootS_Shuff_Marked_Comp_2Shuff_AllSubj_Ave';
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        CurX = [];
        CurX = SampXAveAveAllAve(iCond,:);
        CurY = SampYAveAveAllAve(iCond,:);
        hold on
        plot(CurX,CurY,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
        % plot the first differentiation/ derivation
        CurY1 = smooth(diff(CurY));
        % plot(CurX(2:end),CurY1,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
        CurY2 = smooth(diff(CurY1))*10;
        plot(CurX(3:end),CurY2,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);



        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([-pi/18,pi/18]);
        yticks([-pi/18,0,pi/18]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-10,0,10});
        if iCond == 1
            xlabel('Target Direction at Sacc End')
            ylabel('Normed Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        yline(0,'LineWidth',1.5,'LineStyle','-')
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',17)
    end


%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 4 For Sacc Axis find the significant part and plot all the subjects data together with mean value across
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Sac_2E_XY_Norm_BootS_Shuff_Marked_Comp_2Shuff_AllSubj_Ave';
    SampXAveAveAllAve_1 = [];
    SampYAveAveAllAve_1 = []; SampYAveAveAllStd_1 = []; SampYAveAveAllSE_1 = [];
    hl = []; hp = [];
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        hold on
        SampYAveAveAll = []; SampXAveAveAll = [];
        for iSubj = 1:SubjSize
            SacEndErrAngBootS_SacAxis = []; SacEndErrAngShuff_SacAxis = [];
            SacEndErrAngBootS_SacAxis = DataAll1(iSubj).sbdBoots.SacEndErrAngBootS_SacAxis;
            SacEndErrAngShuff_SacAxis = DataAll1(iSubj).sbdBoots.SacEndErrAngShuff_SacAxis;

            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = SacEndErrAngBootS_SacAxis(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS_SacAxis(iCond).SampYAveAve;
            SampYLCI95 = SacEndErrAngBootS_SacAxis(iCond).SampYCI95(1,:);
            SampYUCI95 = SacEndErrAngBootS_SacAxis(iCond).SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;
            % load the shuff result for the future comparision
            ShuffYAveAve = [];
            ShuffYAveAve = SacEndErrAngShuff_SacAxis(iCond).ShuffYAveAve;

            SampYAveAve = SampYAveAve-ShuffYAveAve;

            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','none','LineWidth',2);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.1,'EdgeColor','none')

        end
        for iSubj = 1:SubjSize
            SacEndErrAngBootS_SacAxis = []; SacEndErrAngShuff_SacAxis = [];
            SacEndErrAngBootS_SacAxis = DataAll1(iSubj).sbdBoots.SacEndErrAngBootS_SacAxis;
            SacEndErrAngShuff_SacAxis = DataAll1(iSubj).sbdBoots.SacEndErrAngShuff_SacAxis;

            SampXAveAve = []; SampYAveAve = []; Samp2Shuff95 = []; ShuffYAveAve = [];
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = SacEndErrAngBootS_SacAxis(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS_SacAxis(iCond).SampYAveAve;
            % Load the comparision result
            Samp2Shuff95 = SacEndErrAngShuff_SacAxis(iCond).Samp2Shuff95;
            % load the shuff result for the future comparision
            ShuffYAveAve = SacEndErrAngShuff_SacAxis(iCond).ShuffYAveAve;

            SampYAveAve = SampYAveAve-ShuffYAveAve;

            plot(SampXAveAve,SampYAveAve,'color',[colorRGB1(iCond,:),0.8],'LineStyle','-','LineWidth',2)

            % mark the above part
            MarkC = [205, 45, 48]/255;
            % Find starts and ends of blocks of 95% CI
            starts = find(diff([0, Samp2Shuff95]) == 1);
            ends = find(diff([Samp2Shuff95, 0]) == -1);
            % also include the data between starts and starts-1
            for iChunk = 1:length(starts)
                %plot 95% first
                starts(iChunk) = max(1,starts(iChunk));
                ends(iChunk) = min(length(SampXAveAve),ends(iChunk));
                plot(SampXAveAve(starts(iChunk):ends(iChunk)),SampYAveAve(starts(iChunk):ends(iChunk)),...
                    '-','Color',[colorRGB1(iCond,:),0.8],'LineWidth',4);
            end
            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
            SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
        end

        % plot all subject's data
        % use sliding window to averaging across in case any boundary effect
        % winSize = deg2rad(10); stepSize = winSize/2; winRange = [0,2*pi];
        SampXAveAveAllAve_1(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll));
        SampYAveAveAllAve_1(iCond,:) = circ_mean_nan(SampYAveAveAll);
        SampYAveAveAllStd_1(iCond,:) = circ_std_nan(SampYAveAveAll);
        % [SampXAveAveAllAve_1(iCond,:),SampYAveAveAllAve_1(iCond,:),SampYAveAveAllStd_1(iCond,:)] =...
        %     F_CartScaSlidWin_PolData2(winSize,stepSize,SampXAveAveAll,SampYAveAveAll,winRange);
        SampYAveAveAllSE_1(iCond,:) = SampYAveAveAllStd_1(iCond,:)/sqrt(SubjSize);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(SampXAveAveAllAve_1(iCond,:),SampYAveAveAllAve_1(iCond,:),SampYAveAveAllSE_1(iCond,:));
        set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3);
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([-pi/4,pi/4]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45});
        if iCond == 1
            xlabel('Saccade Direction at Sacc End')
            ylabel('De-Sta_Trend Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',17)

    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 5 Sacc Axis plot all the mean value together for all subjects and compare between moving direction in polar plot
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2E_Polar_Norm_BootS_Shuff_Marked_Comp_AllSubj';

    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        for iCond = CondIComp(iDir,2:end)
            % plot the result saved above
            % use boundedline to plot which can also skip the nan point
            % need to flip the stationary in CW condition
            CurX = [];
            CurX = mod(SampXAveAveAllAve_1(iCond,:)+pi/2,2*pi); RearD1 = []; RearD2 = [];
            RearD1 = SampYAveAveAllAve_1(iCond,1);
            RearD2 = SampYAveAveAllSE_1(iCond,1);
            polarplot([CurX,CurX(1)],[SampYAveAveAllAve_1(iCond,:),RearD1],'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
            hold on
            polarplot([CurX,CurX(1)],[SampYAveAveAllAve_1(iCond,:)-SampYAveAveAllSE_1(iCond,:),RearD1-RearD2],...
                'color',[colorRGB1(iCond,:),0.3],'LineStyle','-','LineWidth',2);
            polarplot([CurX,CurX(1)],[SampYAveAveAllAve_1(iCond,:)+SampYAveAveAllSE_1(iCond,:),RearD1+RearD2],...
                'color',[colorRGB1(iCond,:),0.3],'LineStyle','-','LineWidth',2);
        end
        
        polarplot(0:0.01:2*pi,zeros(size(0:0.01:2*pi)),'LineStyle',':','Color','k','LineWidth',1.5)
        
        hold off

        rlim([-pi/12,pi/12]);
        rticks([-pi/18,0,pi/18])
        rticklabels({'-10°','0°','10°'})

        title(CondICompName{iDir},'FontWeight','normal')
        set(gca,'FontSize',16)
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 6 Polar plot of RT
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_XY_Norm_BootS_Marked_Comp2Shuff_RT_Mean_AllSubj';
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        % get the RT per condition
        SampYAveAveAll = []; SampXAveAveAll = [];
        for iSubj = 1:SubjSize
            RTBootS = []; RTShuff = [];
            RTBootS = DataAll1(iSubj).sbdBoots.RTBootS_TarAxis;
            % load the bootstrap result Actually why bootstrapping??
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = RTBootS(iCond).SampXAveAve;
            SampYAveAve = RTBootS(iCond).SampYAveAve;
            SampYLCI95 = RTBootS(iCond).SampYCI95(1,:);
            SampYUCI95 = RTBootS(iCond).SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;
            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
            SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
        end
        % calculate the averaging
        SampXAveAveAllAve(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll));
        SampXAveAveAllAve(iCond,:) = mod(SampXAveAveAllAve(iCond,:)+pi/2,2*pi);
        SampYAveAveAllAve(iCond,:) = mean(SampYAveAveAll,'omitmissing');
        SampYAveAveAllStd(iCond,:) = std(SampYAveAveAll,'omitmissing');
        SampYAveAveAllSE(iCond,:) = SampYAveAveAllStd(iCond,:)/sqrt(SubjSize);
        % plot in polar plot
        polarplot([SampXAveAveAllAve(iCond,:),SampXAveAveAllAve(iCond,1)],[SampYAveAveAllAve(iCond,:),SampYAveAveAllAve(iCond,1)],...
            'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
        rlim([200,300])

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% 7 Polar plot of RT but compare with the difference with Stationary
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_XY_Norm_BootS_Marked_Comp2Shuff_RT_Mean_AllSubj';
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        % get the RT diff per condition
        % calculate the averaging
        SampYAveAveAll = []; SampXAveAveAll = [];
        for iSubj = 1:SubjSize
            SampYAveAve = RTBootS(iCond).SampYAveAve - RTBootS(1).SampYAveAve;
            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
        end
        SampYAveAveAllAve(iCond,:) = mean(SampYAveAveAll,'omitmissing');
        SampYAveAveAllStd(iCond,:) = std(SampYAveAveAll,'omitmissing');
        SampYAveAveAllSE(iCond,:) = SampYAveAveAllStd(iCond,:)/sqrt(SubjSize);
        % plot in polar plot
        polarplot([SampXAveAveAllAve(iCond,:),SampXAveAveAllAve(iCond,1)],[SampYAveAveAllAve(iCond,:),SampYAveAveAllAve(iCond,1)],...
            'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
        rlim([-50,100])

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% 8 Polar plot of SmP Linear Vel
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_XY_Norm_BootS_Marked_Comp2Shuff_RT_Mean_AllSubj';
    SampXAveAveAllAve = [];SampYAveAveAllAve = [];SampYAveAveAllAve
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        % get the RT per condition
        SampYAveAveAll = []; SampXAveAveAll = [];
        for iSubj = 1:SubjSize
            SmPVBootS = [];
            SmPVBootS = DataAll1(iSubj).sbdBoots.SmPVBootS_SacAxis;
            % load the bootstrap result Actually why bootstrapping??
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = SmPVBootS(iCond).SampXAveAve;
            SampYAveAve = SmPVBootS(iCond).SampYAveAve;
            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
            SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
        end
        % calculate the averaging
        SampXAveAveAllAve(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll));
        SampXAveAveAllAve(iCond,:) = mod(SampXAveAveAllAve(iCond,:)+pi/2,2*pi);
        SampYAveAveAllAve(iCond,:) = mean(SampYAveAveAll,'omitmissing');
        SampYAveAveAllStd(iCond,:) = std(SampYAveAveAll,'omitmissing');
        SampYAveAveAllSE(iCond,:) = SampYAveAveAllStd(iCond,:)/sqrt(SubjSize);
        % plot in polar plot
        polarplot([SampXAveAveAllAve(iCond,:),SampXAveAveAllAve(iCond,1)],[SampYAveAveAllAve(iCond,:),SampYAveAveAllAve(iCond,1)],...
            'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
        rlim([10,40])

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
% end

%% 9 plot the linear regression of all the subjects' RT result no ZS
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_RT';
    MarkType = {'o','+','*','.','x','|','square','diamond','^','pentagram','hexagram'};
    RTAllCondi = cell(size(CondI)); EndErrAllCondi = cell(size(CondI));
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        XVAll = []; YVAll = []; XLim = [80,650]; YLim = [-pi/2,pi/2];
        hold on
        for iSubj = 1:SubjSize
            CurXVAll = []; CurXV = [];  EndErr = []; CurYV = [];
            datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
                [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
            CurXVAll = DataAll1(iSubj).sbd.SacRTGoc1;
            CurXV = CurXVAll(datas1);
            EndErr = DataAll1(iSubj).sbd.SacEndErrAng2ESign2Normed_SacNoOrder{iCond};
            % CurYV = EndErr - circ_mean_nan(EndErr');
            CurYV = EndErr;
            
            scatter(CurXV,CurYV,'Marker',MarkType{iSubj},'MarkerEdgeColor',colorRGB(iCond,:),'LineWidth',1);

            XVAll = [XVAll,CurXV];
            YVAll = [YVAll,CurYV];
        end
        RTAllCondi{iCond} = XVAll;
        EndErrAllCondi{iCond} = YVAll;
        title(LegText{iCond},'FontWeight','normal')
        ylim(YLim);
        yticks([-pi/2,-pi/3,-pi/6,0,pi/6,pi/3,pi/2]);
        yticklabels({-90,-60,-30,0,30,60,90});
        xlim(XLim)

        F_FitLinearR(XVAll,YVAll,XLim,YLim)
        if iCond == 1
            xlabel('RT, ms'); ylabel('Ending Error, deg')
        end
        hold off
        set(gca,'FontSize',14)
    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 10 plot all three conditions no ZS RT together
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_RT_Comp';
    RTAllCondi = cell(size(CondI)); EndErrAllCondi = cell(size(CondI));
    XLim = [80,650]; YLim = [-pi/2,pi/2];
    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        XLimTxt = XLim - 100;
        hold on
        for iCond = CondIComp(iDir,1:end)
            XVAll = []; YVAll = []; 
            for iSubj = 1:SubjSize
                CurXVAll = []; CurXV = [];  EndErr = []; CurYV = [];
                datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
                    [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
                CurXVAll = DataAll1(iSubj).sbd.SacRTGoc1;
                CurXV = CurXVAll(datas1);
                if iDir == 2 && iCond == 1
                    EndErr = -DataAll1(iSubj).sbd.SacEndErrAng2ESign2Normed_SacNoOrder{iCond};
                else
                    EndErr = DataAll1(iSubj).sbd.SacEndErrAng2ESign2Normed_SacNoOrder{iCond};
                end
                % CurYV = EndErr - circ_mean_nan(EndErr');
                CurYV = EndErr;

                scatter(CurXV,CurYV,'Marker',MarkType{iSubj},'MarkerEdgeColor',colorRGB(iCond,:),...
                    'LineWidth',2,'MarkerEdgeAlpha',0.7);

                XVAll = [XVAll,CurXV];
                YVAll = [YVAll,CurYV];
            end
            RTAllCondi{iCond} = XVAll;
            EndErrAllCondi{iCond} = YVAll;
        end
        for iCond = CondIComp(iDir,1:end)
            XLimTxt = XLimTxt + 100;
            ylim(YLim);
            yticks([-pi/2,-pi/3,-pi/6,0,pi/6,pi/3,pi/2]);
            yticklabels({-90,-60,-30,0,30,60,90});
            xlim(XLim)
            F_FitLinearR(RTAllCondi{iCond},EndErrAllCondi{iCond},XLimTxt,YLim)
            if iCond == 1
                xlabel('RT, ms'); ylabel('Ending Error, deg')
            end
        end
        hold off
        set(gca,'FontSize',14)
    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end


%% 11 plot the linear regression of all the subjects' RT result ZS
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_RTZs';
    MarkType = {'o','+','*','.','x','|','square','diamond','^','pentagram','hexagram'};
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        XVAll = []; YVAll = []; XLim = [0,1]; YLim = [-pi/2,pi/2];
        hold on
        for iSubj = 1:SubjSize
            CurXVAll = []; CurXV = [];  EndErr = []; CurYV = [];
            datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
                [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
            CurXVAll = DataAll1(iSubj).sbd.SacRTGoc1Zs;
            CurXV = CurXVAll(datas1);
            EndErr = DataAll1(iSubj).sbd.SacEndErrAng2ESign2Normed_SacNoOrder{iCond};
            CurYV = EndErr - circ_mean_nan(EndErr');
            CurYV = EndErr;
            
            scatter(CurXV,CurYV,'Marker',MarkType{iSubj},'MarkerEdgeColor',colorRGB(iCond,:),'LineWidth',1);

            XVAll = [XVAll,CurXV];
            YVAll = [YVAll,CurYV];
        end
        title(LegText{iCond},'FontWeight','normal')
        ylim(YLim);
        yticks([-pi/2,-pi/3,-pi/6,0,pi/6,pi/3,pi/2]);
        yticklabels({-90,-60,-30,0,30,60,90});
        xlim(XLim)

        F_FitLinearR(XVAll,YVAll,XLim,YLim)
        hold off
        if iCond == 1
            xlabel('Standardized RT, ms'); ylabel('Ending Error, deg');
        end
        hold off
        set(gca,'FontSize',14)
    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 12 plot all three conditions no ZS RT together
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_RTZs_Comp';

    XLim = [0,1]; YLim = [-pi/2,pi/2];
    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        RTAllCondi = cell(size(CondI)); EndErrAllCondi = cell(size(CondI));
        XLim = [0,1]; YLim = [-pi/2,pi/2];
        XLimTxt = XLim - 1/6;
        hold on
        for iCond = CondIComp(iDir,1:end)
            XVAll = []; YVAll = []; 
            for iSubj = 1:SubjSize
                CurXVAll = []; CurXV = [];  EndErr = []; CurYV = [];
                datas1 = find([DataAll1(iSubj).Dataf1.TarDir1] == iCond & ([DataAll1(iSubj).Dataf1.TrialStatus] == 1 |...
                    [DataAll1(iSubj).Dataf1.TrialStatus] == 5));
                CurXVAll = DataAll1(iSubj).sbd.SacRTGoc1Zs;
                CurXV = CurXVAll(datas1);
                EndErr = DataAll1(iSubj).sbd.SacEndErrAng2ESign2Normed_SacNoOrder{iCond};
                % CurYV = EndErr - circ_mean_nan(EndErr');
                CurYV = EndErr;

                scatter(CurXV,CurYV,'Marker',MarkType{iSubj},'MarkerEdgeColor',colorRGB(iCond,:),...
                    'LineWidth',2,'MarkerEdgeAlpha',0.7);

                XVAll = [XVAll,CurXV];
                YVAll = [YVAll,CurYV];
            end
            RTAllCondi{iCond} = XVAll;
            EndErrAllCondi{iCond} = YVAll;
        end
        for iCond = CondIComp(iDir,1:end)
            XLimTxt = XLimTxt + 1/6;
            ylim(YLim);
            yticks([-pi/2,-pi/3,-pi/6,0,pi/6,pi/3,pi/2]);
            yticklabels({-90,-60,-30,0,30,60,90});
            xlim(XLim)
            F_FitLinearR(RTAllCondi{iCond},EndErrAllCondi{iCond},XLimTxt,YLim)
            if iCond == 1
                xlabel('Standardized RT, ms'); ylabel('Ending Error, deg')
            end
        end
        hold off
        
        set(gca,'FontSize',14)
    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end