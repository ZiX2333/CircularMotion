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
% Adjusted on Jan 02
%   Plot TMrk polar plot ending error, for -80ms
% Adjusted on Feb 19 2025
%   Plot the Target location at gocue as a function of RT

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

% -100, -80, -60, -40, -20, 0, Sacc Off
iTime = 1;

%% 1 find the significant part and plot all the subjects data together, RT
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[31,228,1486,712]);
    SaveName = [];
    SaveName = 'TargLocGoC_RTNoNormed_AllSubj';

    winSize = pi/4;
    stepSize = winSize/10;
    % winRange = [-winSize+stepSize, 2*pi-stepSize];
    winRange = [0, 2*pi];

    for iCond = CondI
        nexttile;
        if iCond == 5
            set(gca, 'Visible', 'off'); % This hides the (2,1) tile
            nexttile;
        end
        hold on
        XV = []; YV = [];
        for iSubj = 1:SubjSize
            Dataf1 = []; sbd = [];
            Dataf1 = DataAll1(iSubj).Dataf1;
            sbd = DataAll1(iSubj).sbd;
            datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
            TargLocGoc = []; 
            for iTrial = 1:length(datas1)
                TargLocGoc(iTrial,:) = Dataf1(datas1(iTrial)).SacTarGoc1Atcp(1,:);
            end
            XV = mod(wrapTo2Pi(TargLocGoc(:,3))-pi/2,2*pi);
            YV = sbd.SacRTGoc1(datas1)';
            [XAve(iSubj,:), YAve(iSubj,:), YStd(iSubj,:)] = F_CartScaSlidWin_PolData1(winSize,stepSize,XV,YV,winRange);

            % use boundedline to plot which can also skip the nan point
            [hl{iCond},hp] = boundedline(XAve(iSubj,:),YAve(iSubj,:),YStd(iSubj,:));
            set(hl{iCond},'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',2);
            set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.2,'EdgeColor','none')

        end
        XAveAve = []; YAveAve = []; YAveStd = []; YAveSE = [];
        XAveAve = mean(XAve,'omitmissing');
        YAveAve = mean(YAve,'omitmissing');
        YAveStd = std(YAve,'omitmissing');
        YAveSE = YAveStd/sqrt(SubjSize);

        % use boundedline to plot which can also skip the nan point
        [hl{iCond},hp] = boundedline(XAveAve,YAveAve,YAveSE);
        set(hl{iCond},'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
        set(hp,'FaceColor',colorRGB(iCond,:),'FaceAlpha',0.3,'EdgeColor','none')

        xticks([0,pi/2,pi,3*pi/2,2*pi+0.01]);
        % xticklabels({'pi/2','pi','3*pi/2',0,'pi/2'})
        xticklabels({'90','180','270','0','90'});
        ylim([0,500]);
        if iCond == 1
            xlabel('Target Direction at Go Cue, deg')
            ylabel('RT, ms')
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



