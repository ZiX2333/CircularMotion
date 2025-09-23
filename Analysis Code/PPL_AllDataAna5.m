% Data Processing
% This script is used for data processing for all subject's data
% Created on Jun 19
%   Main use for ending error relevant analysis
% Adjusted on July 23 2024
%   Add the KL divergence cross subject analysis
% Adjusted on Aug 05 2024
%   Add the comparision
% Adjusted on Aug 09 2024
%   Compare difference between ending error Sac Axis and ending error Tar
%   Axis (both at saccade end)
%   plot the ave result for Sac Axis
%   Change the Data Structure in DataAll1
% Adjusted on Aug 12 2024
%   Change the way I did the averaging.. I changed to a way that is better
%   for wrap around the boundary
% Adjusted on Aug 21, 2024
%   Plotting all the TMrk Results, and the phase diff
% Adjusted on Aug 28, 2024
%   Do the same thing as Ana4 but don't remove the general offset, also
%   remove the Phase diff, reason check F_PhiMeasure.m

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

%% 1 find the significant part and plot all the subjects data together with mean value across
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacTMrkErr_Tar_2E_XY_Detrend_BootS_AllSubj_Ave';
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
        for iTime = 1:7 % 100, 80, 60, 40, 20, On, Off
            SampYAveAveAll = []; SampXAveAveAll = [];
            for iSubj = 1:SubjSize
                SacEndErrAngBootS_TarAxis = []; SacEndErrAngShuff_TarAxis = [];
                SacEndErrAngBootS_TarAxis = DataAll1(iSubj).sbdBoots.SacTMrkErrAngBootS_TarAxis{iTime,iCond};
                SacEndErrAngShuff_TarAxis = DataAll1(iSubj).sbdBoots.SacTMrkErrAngShuff_TarAxis{iTime,iCond};

                SampXAveAve = []; SampYAveAve = []; Samp2Shuff95 = []; ShuffYAveAve = [];
                % load the bootstrap result
                SampXAveAve = []; SampYAveAve = [];
                SampXAveAve = SacEndErrAngBootS_TarAxis.SampXAveAve;
                SampYAveAve = SacEndErrAngBootS_TarAxis.SampYAveAve;
                % Load the comparision result
                Samp2Shuff95 = SacEndErrAngShuff_TarAxis.Samp2Shuff95;
                % load the shuff result for the future comparision
                ShuffYAveAve = SacEndErrAngShuff_TarAxis.ShuffYAveAve;

                SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
                SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
            end

            % plot all subject's data
            % use sliding window to averaging across in case any boundary effect
            % winSize = deg2rad(10); stepSize = winSize/2; winRange = [0,2*pi];
            SampXAveAveAllAve_1{iTime}(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll));
            SampYAveAveAllAve_1{iTime}(iCond,:) = circ_mean_nan(SampYAveAveAll);
            SampYAveAveAllStd_1{iTime}(iCond,:) = circ_std_nan(SampYAveAveAll);
            % [SampXAveAveAllAve_1(iCond,:),SampYAveAveAllAve_1(iCond,:),SampYAveAveAllStd_1(iCond,:)] =...
            %     F_CartScaSlidWin_PolData2(winSize,stepSize,SampXAveAveAll,SampYAveAveAll,winRange);
            SampYAveAveAllSE_1{iTime}(iCond,:) = SampYAveAveAllStd_1{iTime}(iCond,:)/sqrt(SubjSize);
            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(SampXAveAveAllAve_1{iTime}(iCond,:),SampYAveAveAllAve_1{iTime}(iCond,:),SampYAveAveAllSE_1{iTime}(iCond,:));
            set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3);
            set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')
        end

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([-pi/4,pi/3]);
        yticks([-pi/4,-pi/6,-pi/12,0,pi/12,pi/6,pi/4,pi/3]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-45,-30,-15,0,15,30,45,60});
        if iCond == 1
            xlabel('Targ Dir at 0:20:100ms Sacc On, Sac Off')
            ylabel('De-Sta_Trend Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',17)

    end
    % saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 plot all the subjects results and the mean value ontop
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_XY_Detrend_BootS_Marked_AllSubj_20ms';
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        hold on
        iTime = 5;
        for iSubj = 1:SubjSize
            SacEndErrAngBootS_TarAxis = []; SacEndErrAngShuff_TarAxis = [];
            SacEndErrAngBootS_TarAxis = DataAll1(iSubj).sbdBoots.SacTMrkErrAngBootS_TarAxis{iTime,iCond};
            SacEndErrAngShuff_TarAxis = DataAll1(iSubj).sbdBoots.SacTMrkErrAngShuff_TarAxis{iTime,iCond};

            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = SacEndErrAngBootS_TarAxis.SampXAveAve;
            SampYAveAve = SacEndErrAngBootS_TarAxis.SampYAveAve;
            SampYLCI95 = SacEndErrAngBootS_TarAxis.SampYCI95(1,:);
            SampYUCI95 = SacEndErrAngBootS_TarAxis.SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;
            % load the shuff result for the future comparision
            ShuffYAveAve = [];
            ShuffYAveAve = SacEndErrAngShuff_TarAxis.ShuffYAveAve;

            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','none','LineWidth',2);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.1,'EdgeColor','none')

        end
        for iSubj = 1:SubjSize
            SacEndErrAngBootS_TarAxis = []; SacEndErrAngShuff_TarAxis = [];
            SacEndErrAngBootS_TarAxis = DataAll1(iSubj).sbdBoots.SacTMrkErrAngBootS_TarAxis{iTime,iCond};
            SacEndErrAngShuff_TarAxis = DataAll1(iSubj).sbdBoots.SacTMrkErrAngShuff_TarAxis{iTime,iCond};

            SampXAveAve = []; SampYAveAve = []; Samp2Shuff95 = []; ShuffYAveAve = [];
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = SacEndErrAngBootS_TarAxis.SampXAveAve;
            SampYAveAve = SacEndErrAngBootS_TarAxis.SampYAveAve;
            % Load the comparision result
            Samp2Shuff95 = SacEndErrAngShuff_TarAxis.Samp2Shuff95;
            % load the shuff result for the future comparision
            ShuffYAveAve = SacEndErrAngShuff_TarAxis.ShuffYAveAve;

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
        end

        % plot the mean
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(SampXAveAveAllAve_1{iTime}(iCond,:),SampYAveAveAllAve_1{iTime}(iCond,:),SampYAveAveAllSE_1{iTime}(iCond,:));
        set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3);
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([-pi/6,pi/3]);
        yticks([-pi/6,-pi/12,0,pi/12,pi/6,pi/4,pi/3]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-30,-15,0,15,30,45,60});
        if iCond == 1
            xlabel('Target Direction at 20ms to Sacc On')
            ylabel('Normed Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',17)

    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% 3 plot all the mean value together for all subjects and compare between moving direction
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_XY_Detrend_BootS_Marked_Comp_AllSubj_20ms';

    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        hold on
        iTime = 5;
        for iCond = CondIComp(iDir,:)
            % plot the result saved above
            % use boundedline to plot which can also skip the nan point
            % need to flip the stationary in CW condition
            if iDir == 2 && iCond == 1
                [hl{iCond},hp] = boundedline(SampXAveAveAllAve_1{iTime}(iCond,:),-SampYAveAveAllAve_1{iTime}(iCond,:),SampYAveAveAllSE_1{iTime}(iCond,:));
                set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
                set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
            else
                [hl{iCond},hp] = boundedline(SampXAveAveAllAve_1{iTime}(iCond,:),SampYAveAveAllAve_1{iTime}(iCond,:),SampYAveAveAllSE_1{iTime}(iCond,:));
                set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
                set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
            end
        end
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        xlim([0,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        ylim([-pi/6,pi/3]);
        yticks([-pi/6,-pi/12,0,pi/12,pi/6,pi/4,pi/3]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-30,-15,0,15,30,45,60});
        if iDir == 1
            xlabel('Targ Direction at 20ms to Sacc On')
            ylabel('De-Sta_Trend Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');

        hold off

        legend([hl{CondIComp(iDir,1)},hl{CondIComp(iDir,2)},hl{CondIComp(iDir,3)},hl{CondIComp(iDir,4)}],...
            {LegText{CondIComp(iDir,1)},LegText{CondIComp(iDir,2)},LegText{CondIComp(iDir,3)},LegText{CondIComp(iDir,4)}},...
            'FontSize',14,'Box','off','AutoUpdate','off')
        title(CondICompName{iDir},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

