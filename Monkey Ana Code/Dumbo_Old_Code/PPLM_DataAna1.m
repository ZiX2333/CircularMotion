% Data Processing
% This script is used for data processing
% Analysis based on prepro 1
% Created on Jan 24 2025, Xuan
% Test on the saccadic eye traces polar plot, Jan 24 2025, Xuan

%% TXT information and basic setup
global LegText colorRGB colorRGB1 colorRGB2
LegText = [{'Stationary'},{'CCW 15°/s'},{'CCW 30°/s'},{'CCW 45°/s'},{'CW 15°/s'},{'CW 30°/s'},{'CW 45°/s'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';

% CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
CondIComp = [1,2,3,4; 1,5,6,7]; % When I want to compare with stationary
CondICompName = {'CCW','CW'};
CondName = '_1';

ifDoBasic = 1;

%% Basic settings
if ifDoBasic == 1
    %% set up basic parameter
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
        194, 123, 55;... % yellow 238, 169, 60
        85, 161, 92;... % green),2)
        213, 95, 43;...
        194, 123, 55;... % yellow 238, 169, 60
        85, 161, 92;... % green),2)
        213, 95, 43]/255; %pink/orange

    %% PreProcessed of Data
    Datax1 = Datax;
    
    % Drop criteria: there will be two drops, one check the time and ending
    % location parameters, one check the behavior ana output

    iDrop1 = []; % for the first drop
    iDrop2 = []; % for the second drop
    % remove RT < 80ms, duration >=150ms, start radius >=5, end radius <=5,
    % amplitude <=2
    for iTrial = 1:size(Datax,1)
        if Datax.trialGrp(iTrial) == 0 % not going to analysis step
            continue
        end
        if isempty(Datax1.SacLocGoc2{iTrial})
            iDrop1 = [iDrop1,iTrial];
            continue
        end
        EyeLoc = [];
        EyeLoc = Datax.SacLocGoc2{iTrial}{1}(1:4,:);
        if max(EyeLoc(4,:)) > 20 % probably blink
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif EyeLoc(4,1) >=5 % start too far
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif EyeLoc(4,end) <=5 % end too far
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif EyeLoc(4,end) - EyeLoc(4,1) <=2 % amp too short
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif Datax.SacTimeGoc2{iTrial}(end,1) < 80 % RT too short
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif Datax.SacTimeGoc2{iTrial}(end-1,1) >150 %saccade too long
            iDrop1 = [iDrop1,iTrial];
            continue
        end
    end

    % behavior analysis
    sbd = [];
    [sbd,iDrop2] = BehaviorAnaM(Datax);

    % drop data
    iDropAll = unique([iDrop1,iDrop2]);
    Datax1.trialErr(iDropAll) = -1; % -1 means doesn't apply criteria

    iFigAcc = 0;
end

%% Plot the row eye traces first... just to check
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = '/RawEyeTrc2C_Datax';
for iCond = CondI
    nexttile
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = find(Datax.trialGrp == iCond & Datax.trialErr == 1);
    for iTriali = 1:length(datas1)
        iTrial = datas1(iTriali);
        EyeLoc = [];
        if isempty(Datax1.SacLocGoc2{iTrial})
            continue
        end
        EyeLoc = Datax1.SacLocGoc2{iTrial}{1}(1:4,:);
        TargTime = Datax1.T1TimeReal{iTrial}';
        SaccOffT = Datax1.SacTimeGoc2{iTrial}(2,1);
        TargTimeRela = TargTime - SaccOffT;
        TargLocXY = []; TargLocTR = [];
        TargLocXY = Datax1.T1LocReal{iTrial}(:,1:2)';
        TargLocTR = Datax1.T1LocReal{iTrial}(:,3:4)';
        % Remove target location that is too large
        TargTSaccE = TargTimeRela == max(TargTimeRela(TargTimeRela<=0));
        polarplot(EyeLoc(3,:),EyeLoc(4,:),'LineWidth',0.6,'Color',colorRGB(iCond,:));
        hold on
        
        polarplot(TargLocTR(1,TargTSaccE),TargLocTR(2,TargTSaccE),'k.', 'MarkerSize', 7,'LineWidth',1.5)
        % add lines
        polarplot([EyeLoc(3,end),TargLocTR(1,TargTSaccE)],[EyeLoc(4,end),TargLocTR(2,TargTSaccE)],...
                'LineWidth',1,'Color','k','LineStyle','-');
    end
    rlim([0,12])
    title(LegText{iCond},'FontWeight','normal');
    set(gca,'FontSize',15)
    hold off
end

%% plot the row eye traces using sbd detection
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = '/RawEyeTrc2C_sbd';
for iCond = CondI
    nexttile
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);
    for iTriali = 1:length(datas1)
        iTrial = datas1(iTriali);
        EyeLoc = [];
        EyeLoc = sbd.SacTraGoc1{iTrial}(:,1:4);
        TargLocTREnd = sbd.TargLocCheckPAtcp{iTrial}(end,3:4);
        % Remove target location that is too large
        polarplot(EyeLoc(:,3),EyeLoc(:,4),'LineWidth',0.6,'Color',colorRGB(iCond,:));
        hold on
        polarplot(TargLocTREnd(1),TargLocTREnd(2),'k.', 'MarkerSize', 7,'LineWidth',1.5)
        % add lines
        polarplot([EyeLoc(end,3),TargLocTREnd(1)],[EyeLoc(end,4),TargLocTREnd(2)],...
                'LineWidth',1,'Color','k','LineStyle','-'); 
    end
    rlim([0,12])
    title(LegText{iCond},'FontWeight','normal');
    set(gca,'FontSize',15)
    hold off
end

%% plot the row eye traces using eye center
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = '/RawEyeTrc2C_sbd';
for iCond = CondI
    nexttile
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);
    for iTriali = 1:length(datas1)
        iTrial = datas1(iTriali);
        EyeLoc = [];
        EyeLoc = sbd.SacTraGoc2E1{iTrial}(:,1:4);
        TargLocTREnd = sbd.TargLocCheckPAtcp2E{iTrial}(end,3:4);
        % Remove target location that is too large
        polarplot(EyeLoc(:,3),EyeLoc(:,4),'LineWidth',0.6,'Color',colorRGB(iCond,:));
        hold on
        polarplot(TargLocTREnd(1),TargLocTREnd(2),'k.', 'MarkerSize', 7,'LineWidth',1.5)
        % add lines
        polarplot([EyeLoc(end,3),TargLocTREnd(1)],[EyeLoc(end,4),TargLocTREnd(2)],...
                'LineWidth',1,'Color','k','LineStyle','-'); 
    end
    rlim([0,12])
    title(LegText{iCond},'FontWeight','normal');
    set(gca,'FontSize',15)
    hold off
end

%% plot the ending error as a function of target location in cartesian
iFigAcc = iFigAcc+1;
figure(iFigAcc)
set(gcf,'Position',[31,228,1486,712]);
SaveName = [];
SaveName = '/SacEndErr_Tar_2E_XY_NoNorm';
for iCond = CondI
    nexttile
    if iCond == 5
        set(gca, 'Visible', 'off'); % This hides the (2,1) tile
        nexttile; % This creates the (2,1) tile
    end
    datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);

    XV = []; YV = [];  
    XAve = []; YAve = []; YStd = [];
    XV = mod(rad2deg(wrapTo2Pi(sbd.TargLocSacEndAtcpTR2E(datas1,1)))-90,360);
    YV = rad2deg(sbd.SacEndErrAng2ESign(datas1));
    % I need to plot on the xy coordinates
    FM_CartScat(XV, YV, iCond, [-10,370], [-50,50]);

    % plot the sliding window
    XV = wrapTo2Pi(deg2rad(XV));
    YV = sbd.SacEndErrAng2ESign(datas1);
    winSize = pi/4;
    stepSize = winSize/10;
    % winRange = [-winSize+stepSize, 2*pi-stepSize];
    winRange = [0,2*pi];
    [XAve, YAve, YStd] = FM_CartScaSlidWin_PolData2(winSize,stepSize,XV,YV,winRange);
    % use boundedline to plot which can also skip the nan point
    XAve = rad2deg(XAve);
    YAve = rad2deg(YAve);
    YStd = rad2deg(YStd);
    [hl,hp] = boundedline(XAve,YAve,YStd);
    set(hl,'color','k','LineStyle','-','LineWidth',1.5);
    set(hp,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')

    xticks([0,90,180,270,360]);
    xticklabels([90,180,270,0,90])
    yticks([-50,-25,0,25,50])

    if iCond == 1
        xlabel('Targ Direction at Sacc End, deg')
        ylabel('Sacc Targ Direction Difference, deg')
    end
    hold on
    xline(180,'LineWidth',1.5,'LineStyle','--');
    xline(90,'LineWidth',1.5,'LineStyle','--');
    xline(270,'LineWidth',1.5,'LineStyle','--')

    title(LegText{iCond},'FontWeight','normal')
    set(gca,'FontSize',15)

end



