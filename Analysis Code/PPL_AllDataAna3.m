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
% Adjusted on Aug 14 2024
%   Check the RT and Ending error with Sac Axis

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

%% 1 find the significant part and plot all the subjects end err and RT together
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = 'SacEndErr_Eye_2E_XY_Norm_BootS_Marked_Comp2Shuff_RT_AllSubj';
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
        SacEndErrAngBootS = DataAll1(iSubj).sbdBootS.SacEndErrAngBootS_SacAxis;
        SacEndErrAngShuff = DataAll1(iSubj).sbdBootS.SacEndErrAngShuff_SacAxis;

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
        SacEndErrAngBootS = DataAll1(iSubj).sbdBootS.SacEndErrAngBootS_SacAxis;
        SacEndErrAngShuff = DataAll1(iSubj).sbdBootS.SacEndErrAngShuff_SacAxis;

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
        xlabel('Eye Direction at Sacc End')
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
        RTBootS = DataAll1(iSubj).sbdBootS.RTBootS_SacAxis;

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
        RTBootS = DataAll1(iSubj).sbdBootS.RTBootS_SacAxis;

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

%% 2 plot the mean of both traces and comp
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = 'SacEndErr_Eye_2E_XY_Norm_BootS_Marked_Comp2Shuff_RT_Mean_AllSubj';
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
        SacEndErrAngBootS = DataAll1(iSubj).sbdBootS.SacEndErrAngBootS_SacAxis;
        SacEndErrAngShuff = DataAll1(iSubj).sbdBootS.SacEndErrAngShuff_SacAxis;

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
        SacEndErrAngBootS = DataAll1(iSubj).sbdBootS.SacEndErrAngBootS_SacAxis;
        SacEndErrAngShuff = DataAll1(iSubj).sbdBootS.SacEndErrAngShuff_SacAxis;

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
    SampXAveAveAllAve(iCond,:) = wrapTo2Pi(circ_mean(SampXAveAveAll));
    SampYAveAveAllAve(iCond,:) = circ_mean(SampYAveAveAll);
    SampYAveAveAllStd(iCond,:) = circ_std(SampYAveAveAll);
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
        xlabel('Eye Direction at Sacc End')
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
        RTBootS = DataAll1(iSubj).sbdBootS.RTBootS_SacAxis;

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
        RTBootS = DataAll1(iSubj).sbdBootS.RTBootS_SacAxis;

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
    SampXAveAveAllAve(iCond,:) = wrapTo2Pi(nanmean(SampXAveAveAll));
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





