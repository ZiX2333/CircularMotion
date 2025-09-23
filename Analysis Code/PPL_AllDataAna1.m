% Data Processing
% This script is used for data processing for all subject's data
% Created on Jun 19
%   Main use for ending error relevant analysis
% Adjusted on July 23 2024
%   Add the KL divergence cross subject analysis
% Adjusted on Aug 05 2024
%   Add the comparision
% Adjusted on Sep 23 2024
%   Add the KL Divergence's std error, and then plot them together
%   For KL Divergence, I need to load AllSubj_050824_PreProcessed5.mat
%   Then Compared across conditions

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
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
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
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 find the significant part and plot all the subjects data together with mean value across
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
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
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 3 plot all the mean value together for all subjects and compare between moving direction
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = '/SacEndErr_Tar_2E_XY_Norm_BootS_Shuff_Marked_Comp_AllSubj';

    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        hold on
        for iCond = CondIComp(iDir,:)
            % plot the result saved above
            % use boundedline to plot which can also skip the nan point
            % need to flip the stationary in CW condition
            if iDir == 2 && iCond == 1
                [hl{iCond},hp] = boundedline(SampXAveAveAllAve(iCond,:),-SampYAveAveAllAve(iCond,:),SampYAveAveAllSE(iCond,:));
                set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
                set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
            else
                [hl{iCond},hp] = boundedline(SampXAveAveAllAve(iCond,:),SampYAveAveAllAve(iCond,:),SampYAveAveAllSE(iCond,:));
                set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
                set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')
            end
        end
        xticks([0,pi/2,pi,3*pi/2,2*pi]);
        xlim([0,2*pi]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({90,180,270,0,90});
        ylim([-pi/9,pi/9]);
        % yticks([-pi/9,0,pi/9]);
        % % yticklabels({'-pi/9',0,'pi/9'});
        % yticklabels({-20,0,20});
        ylim([-pi/6,pi/6]);
        yticks([-pi/6,-pi/12,0,pi/12,pi/6]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-30,-15,0,15,30});
        if iDir == 1
            xlabel('Target Direction at Sacc End')
            ylabel('Normed Sacc-End Direction Difference')
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


%% 4 plot all subject's KL-divergence together
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacDir2EKL_AllSubj';
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        % pre-assign the name
        klDivg = [];
        vfPDFSamples = [];
        for iSubj = 1:SubjSize
            klDivg(iSubj,:) = DataAll1(iSubj).sbd.klDivg(iCond,:);
            vfPDFSamples(iSubj,:) = DataAll1(iSubj).sbd.vfPDFSamples;
            polarplot(vfPDFSamples(iSubj,:),klDivg(iSubj,:),'LineWidth',1,'Color',colorRGB(iCond,:));
            hold on
        end
        rlim([-0.15,0.3])
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% 5 plot all subject's KL-divergence together with the mean one
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacDir2EKL_AllSubj';
    klDivgAll = nan([length(CondI),length(DataAll1(1).sbd.klDivg(1,:))]);
    klDivgAllSE = nan(size(klDivgAll));
    vfPDFSamplesAll = nan(size(klDivgAll));
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        % pre-assign the name
        klDivg = [];
        vfPDFSamples = [];
        for iSubj = 1:SubjSize
            klDivg(iSubj,:) = DataAll1(iSubj).sbd.klDivg(iCond,:);
            vfPDFSamples(iSubj,:) = DataAll1(iSubj).sbd.vfPDFSamples;
            polarplot(vfPDFSamples(iSubj,:),klDivg(iSubj,:),'LineWidth',1,'Color',colorRGB1(iCond,:));
            hold on
        end
        polarplot(0:0.01:2*pi,zeros(size(0:0.01:2*pi)),'LineStyle',':','Color','k','LineWidth',1.5)
        klDivgAll(iCond,:) = mean(klDivg);
        klDivgAllSE(iCond,:) = std(klDivg)/SubjSize;
        vfPDFSamplesAll(iCond,:) = mean(vfPDFSamples);
        polarplot(vfPDFSamplesAll(iCond,:),klDivgAll(iCond,:)-klDivgAllSE(iCond,:),'LineWidth',1,'Color',[colorRGB(iCond,:),0.3]);
        polarplot(vfPDFSamplesAll(iCond,:),klDivgAll(iCond,:)+klDivgAllSE(iCond,:),'LineWidth',1,'Color',[colorRGB(iCond,:),0.3]);
        polarplot(vfPDFSamplesAll(iCond,:),klDivgAll(iCond,:),'LineWidth',2,'Color',colorRGB2(iCond,:));
        hold on
        rlim([-0.15,0.3])
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 6 Compare the KL divergence across condition
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacDir2EKL_AllSubj_Comp';

    for iDir = 1:2
        subplot(1,2,iDir)
        hl = [];
        for iCond = CondIComp(iDir,2:end)
            % plot the result saved above
            % use boundedline to plot which can also skip the nan point
            % need to flip the stationary in CW condition
            polarplot(vfPDFSamplesAll(iCond,:),klDivgAll(iCond,:)-klDivgAllSE(iCond,:),'LineWidth',1,'Color',[colorRGB(iCond,:),0.3]);
            hold on
            polarplot(vfPDFSamplesAll(iCond,:),klDivgAll(iCond,:)+klDivgAllSE(iCond,:),'LineWidth',1,'Color',[colorRGB(iCond,:),0.3]);
            polarplot(vfPDFSamplesAll(iCond,:),klDivgAll(iCond,:),'LineWidth',2,'Color',colorRGB2(iCond,:));
        end
        
        polarplot(0:0.01:2*pi,zeros(size(0:0.01:2*pi)),'LineStyle',':','Color','k','LineWidth',1.5)
        
        hold off
        rlim([-0.1,0.15])

        title(CondICompName{iDir},'FontWeight','normal')
        set(gca,'FontSize',16)
    end
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end



%% 7 find the significant part and plot all the subjects end err and RT together
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_XY_Norm_BootS_Marked_Comp2Shuff_RT_AllSubj';
    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        %% plot the left axis first
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
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','none','LineWidth',2,'Marker','none');
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

            plot(SampXAveAve,SampYAveAve,'color',colorRGB(iCond,:),'LineStyle','--','LineWidth',2,'Marker','none')

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
                    '--','Color',colorRGB2(iCond,:),'LineWidth',4,'Marker','none');
            end
        end

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([-pi/3,pi/6]);
        yticks([-pi/3,-pi/4,-pi/6,-pi/12,0,pi/12,pi/6]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-60,-45,-30,-15,0,15,30});
        if iCond == 1
            xlabel('Target Direction at Sacc End')
            ylabel('Normed Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off

        %% plot the right axis them
        yyaxis right
        hold on
        SampYAveAveAll = []; SampXAveAveAll = [];
        for iSubj = 1:SubjSize
            RTBootS = []; RTShuff = [];
            RTBootS = DataAll1(iSubj).sbdBoots.RTBootS_TarAxis;

            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = RTBootS(iCond).SampXAveAve;
            SampYAveAve = RTBootS(iCond).SampYAveAve;
            SampYLCI95 = RTBootS(iCond).SampYCI95(1,:);
            SampYUCI95 = RTBootS(iCond).SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;

            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','none','LineWidth',2);
            set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.1,'EdgeColor','none')

        end
        for iSubj = 1:SubjSize
            RTBootS = []; RTShuff = [];
            RTBootS = DataAll1(iSubj).sbdBoots.RTBootS_TarAxis;

            SampXAveAve = []; SampYAveAve = [];
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = RTBootS(iCond).SampXAveAve;
            SampYAveAve = RTBootS(iCond).SampYAveAve;
            % Load the comparision result
            SampYAveAve = SampYAveAve;
            plot(SampXAveAve,SampYAveAve,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2,'Marker','none')
        end

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([150,600]);
        if iCond == 1
            ylabel('Reaction time, ms')
        end
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
end

%% 8 plot the mean of both traces and comp
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
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
        %% plot the left axis first
        SampXAveAveAllAve = []; SampYAveAveAllAve = []; SampYAveAveAllStd = []; SampYAveAveAllSE = [];
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
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','none','LineWidth',2,'Marker','none');
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

            plot(SampXAveAve,SampYAveAve,'color',[colorRGB1(iCond,:),0.8],'LineStyle','--','LineWidth',2,'Marker','none')

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
                    '--','Color',[colorRGB1(iCond,:),0.8],'LineWidth',4,'Marker','none');
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
        set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','--','LineWidth',3,'Marker','none');
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([-pi/3,pi/6]);
        yticks([-pi/3,-pi/4,-pi/6,-pi/12,0,pi/12,pi/6]);
        % yticklabels({'-pi/9',0,'pi/9'});
        yticklabels({-60,-45,-30,-15,0,15,30});
        if iCond == 1
            xlabel('Target Direction at Sacc End')
            ylabel('Normed Sacc-End Direction Difference')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off

        %% plot the right axis them
        SampXAveAveAllAve = []; SampYAveAveAllAve = []; SampYAveAveAllStd = []; SampYAveAveAllSE = [];
        yyaxis right
        hold on
        SampYAveAveAll = []; SampXAveAveAll = [];
        for iSubj = 1:SubjSize
            RTBootS = []; RTShuff = [];
            RTBootS = DataAll1(iSubj).sbdBoots.RTBootS_TarAxis;

            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = []; SampYLCI95 = []; SampYUCI95 = []; SampYUCI95Ave = []; SampYLCI95Ave = [];
            SampXAveAve = RTBootS(iCond).SampXAveAve;
            SampYAveAve = RTBootS(iCond).SampYAveAve;
            SampYLCI95 = RTBootS(iCond).SampYCI95(1,:);
            SampYUCI95 = RTBootS(iCond).SampYCI95(2,:);
            SampYUCI95Ave = SampYUCI95 - SampYAveAve;
            SampYLCI95Ave = SampYAveAve - SampYLCI95;

            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(SampXAveAve,SampYAveAve,[SampYLCI95Ave;SampYUCI95Ave]');
            set(hl{iCond},'color',colorRGB(iCond,:),'LineStyle','none','LineWidth',2);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.1,'EdgeColor','none')

        end
        for iSubj = 1:SubjSize
            RTBootS = []; RTShuff = [];
            RTBootS = DataAll1(iSubj).sbdBoots.RTBootS_TarAxis;

            SampXAveAve = []; SampYAveAve = [];
            % load the bootstrap result
            SampXAveAve = []; SampYAveAve = [];
            SampXAveAve = RTBootS(iCond).SampXAveAve;
            SampYAveAve = RTBootS(iCond).SampYAveAve;
            % Load the comparision result
            SampYAveAve = SampYAveAve;
            plot(SampXAveAve,SampYAveAve,'color',[colorRGB1(iCond,:),0.8],'LineStyle','-','LineWidth',2,'Marker','none')

            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
            SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
        end

        % plot all subject's data
        SampXAveAveAllAve(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll));
        SampYAveAveAllAve(iCond,:) = nanmean(SampYAveAveAll);
        SampYAveAveAllStd(iCond,:) = nanstd(SampYAveAveAll);
        SampYAveAveAllSE(iCond,:) = SampYAveAveAllStd(iCond,:)/sqrt(SubjSize);
        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(SampXAveAveAllAve(iCond,:),SampYAveAveAllAve(iCond,:),SampYAveAveAllSE(iCond,:));
        set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3,'Marker','none');
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        ylim([150,400]);
        if iCond == 1
            ylabel('Reaction time, ms')
        end
        hold off

        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',14)
    end
    saveas(gcf,[ResultDir,SaveName,CondName,'.fig'])
end

