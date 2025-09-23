% Data Processing
% This script is used for data processing
% Analysis based on prepro 4
% adjusted on Oct 12, exclude several figures and add some new figures
% Data Save in Result/ Oct12
% Adjusted on Oct 28, add sinwave fit
% Adjusted on Oct 31, adjust the way of doing averaging
% Adjusted on Nov 5, just realize that I confounded the left and right
% Adjusted on Jan 29, make it useful for single subject
% Adjusted on Feb 12, Add new Normalization ways, Change the iniT to 15,
% Change the resample method
% Adjusted on Feb 16, A new analysis way, start with saccade tilting
% Adjusted on Mar 15, New analysis implanted
% Adjusted on Apr 17, two tilted effect ploting and ellipse fitting
%                     Also check the initial eye location
% Adjusted on May 08, Focuses on the ending error analysis, especially how
%                     to quantify my results
% Adjusted on May 17, Keep focusing on ending error analysis. Results are
%                     fixation point center now
% Adjusted on July 22, Keep focusing on ending error analysis. Results are
%                     initial eye location center now
% Adjusted on Aug 20, Add new analysis respect to error to target at
%                       different time, also ploted the eye traces 2E
% Adjusted on Aug 27, Check the velocity with ending error
% Adjusted on Sep 23, for some figures that I might used in SFN poster
% Adjusted on Mar 26, I'm tired of always looking for the plots I need...
%                     here is a combination of all the required plots
% Adjusted on Jun 04, Redo the bootstrap ending error and
%                     KL Divergence for target dir
% Adjusted on Jun 09, tried different ways to do the RT regression
% Adjusted on Jun 09, Ending error distribution
% Adjusted on Jul 02, Ending error and pursuit velocity
% Adjusted on Aug 16, Pursuit vel and make it in combine left and right
%% Txt information
global colorRGB colorRGB1 colorRGB2
LegText = [{'Stationary'},{'15°/s'},{'30°/s'},{'45°/s'},{'CW 15°/s'},{'CW 30°/s'},{'CW 45°/s'}];
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

%% basic settings
if ifDoBasic
    % mkdir(ResultDir);

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

    %% PreProcessed of data
    Dataf1 = Dataf; % All trials only with labels
    Dataf2 = Dataf; % delete droped trials

    % % remove Dataf that TrialStatus ~=1
    % Dataf1([Dataf.TrialStatus]~=1) = [];
    %
    % % remove trials that peak velocity < 50 deg/sec
    % Dataf1([Dataf1.SacPvelGoc1]<50) = [];

    % remove RT < 80ms and larger than 400, duration >=150ms, start radius >=4, end radius <=4,
    % amplitude <3, peak velocity < 50
    iDrop1 = []; % for trials that already detected before
    iDrop2 = []; % for trials that are going to detected now/ doesnt satisfied the criteria
    iDrop3 = []; % for trials that are manually checked.. I need to find an easy way!!!
    for iTrial = 1:size(Dataf1,2)
        if Dataf1(iTrial).TrialStatus ~=1 && Dataf1(iTrial).TrialStatus ~=5
            iDrop1 = [iDrop1,iTrial];
            continue
        elseif isempty(Dataf1(iTrial).SacTimeGoc2)
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacTimeGoc2(end,1)<80
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacTimeGoc2(end,1)>400
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacTimeGoc2(end-1,1)>=150
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacLocGoc2{1}(4,1) >=4
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif Dataf1(iTrial).SacLocGoc2{1}(4,end) <=4
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif abs(Dataf1(iTrial).SacLocGoc2{1}(4,end)-Dataf1(iTrial).SacLocGoc2{1}(4,1)) <=3
            iDrop2 = [iDrop2,iTrial];
            continue
        elseif abs(Dataf1(iTrial).SacPvelGoc2(1)) <50
            iDrop2 = [iDrop2,iTrial];
            continue
        end
        % SacSeqTemp = Dataf(iTrial).SaccSeqInfo{3}(2,:)-Dataf(iTrial).TimeGocOn;
        % within 100ms before gocue
        % MicroSacLoc = find(SacSeqTemp>=-100 & SacSeqTemp<=0);
        % have to last at least 5ms
        % if ~isempty(MicroSacLoc) & Dataf(iTrial).SaccSeqInfo{3}(3,MicroSacLoc) >=5
        %     iDrop2 = [iDrop2,iTrial];
        % continue
        % end
    end

    for iDrop = 1:length(iDrop2)
        Dataf1(iDrop2(iDrop)).TrialStatus = -1; % doesn't apply criteria
    end

    %% behavior analysis
    iniT = 5; % select first 10ms for the first saccade
    [sbd,Dataf1,iDrop4] = BehaviorAna(Dataf1);

    % drop data
    iDropDataf = unique([iDrop1,iDrop2,iDrop4]);
    % iDropDataf2 = unique([iDrop2,iDrop3]);
    Dataf2(iDropDataf) = [];

    % label the idrop 4 trials
    for iDrop = 1:length(iDrop4)
        Dataf1(iDrop4(iDrop)).TrialStatus = -1; % doesn't apply criteria
    end

    % save the TarDir1 and Trial Status
    sbd.TarDir = [Dataf1.TarDir1];
    sbd.TrialStatus = [Dataf1.TrialStatus];
    % sbdfieldNames = fieldnames(sbd);
    % % Loop through each field and delete the element
    % for iField = 1:length(sbdfieldNames)
    %     field = sbdfieldNames{iField};
    %     sbd.(field)(iDrop4) = [];
    % end
end
iFigAcc = 0;
SecNum = 0;
Rlim1 = [-1,1];
Rlim2 = [-2,2];
Rlim3 = [0,2];
rScalar = ceil(deg2rad(30)*10)/10;

%% 1 Smooth Pursuit Velocity as a function of time seperated by ending error
TimeL = 500;
TimeA = 201;

SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = '/PostSaccSmpLVel_SacEndErr2E_Comb';

    lStyle = {'--','-.',':','-'};

    GrpIdx = cell(1,length(CondIComp));
    EndErrGrpAve = cell(1,length(CondIComp));
    SmPLVelAllGrp = cell(1,length(CondIComp));
    SmPLVelAllGrpAve = cell(1,length(CondIComp));
    SmPLVelAllGrpStd = cell(1,length(CondIComp));

    for iCond = CondIComp(1,:)
        nexttile
        % CCW
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        % CW
        datas2 = find([Dataf1.TarDir1] == CondIComp(2,iCond) & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EndErr = []; SmPLVelAll = [];

        % stationary
        if iCond == 1
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2(datas1);
            SmPLVelAll = sbd.LinVelSmPurs(datas1,:);
        else
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2([datas1,datas2]);
            SmPLVelAll = [sbd.LinVelSmPurs(datas1,:); -sbd.LinVelSmPurs(datas2,:)];
        end

        SmPTime = 1:size(SmPLVelAll,2);

        % seperate the EndErr into four group
        EndErrEdge = quantile(EndErr,0:0.25:1);

        GrpIdx{iCond} = cell(1,4);
        EndErrGrpAve{iCond} = nan(1,4);
        SmPLVelAllGrp{iCond} = cell(1,4);
        SmPLVelAllGrpAve{iCond} = nan(4,TimeL);
        SmPLVelAllGrpStd{iCond} = nan(4,TimeL);

        hold on
        hl = []; hp = [];
        for iGrp = 1:length(EndErrEdge)-1
            GrpIdx{iCond}{iGrp} = find(EndErr>=EndErrEdge(iGrp) & EndErr<=EndErrEdge(iGrp+1));
            EndErrGrpAve{iCond}(iGrp) = circ_mean_nan(EndErr(GrpIdx{iCond}{iGrp})');
            SmPLVelAllGrp{iCond}{iGrp} = SmPLVelAll(GrpIdx{iCond}{iGrp},:);
            SmPLVelAllGrpAve{iCond}(iGrp,:) = mean(SmPLVelAllGrp{iCond}{iGrp},'omitmissing');
            SmPLVelAllGrpStd{iCond}(iGrp,:) = std(SmPLVelAllGrp{iCond}{iGrp},'omitmissing');

            % plot the result
            % [hl{iGrp},hp{iGrp}] = boundedline(SmPTime,SmPLVelAllGrpAve{iCond}(iGrp,:),SmPLVelAllGrpStd{iCond}(iGrp,:));
            % set(hl{iGrp},'color','k','LineStyle',lStyle{iGrp},'LineWidth',1.5);
            % set(hp{iGrp},'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
            if iGrp == 1
                plot(SmPTime,SmPLVelAllGrpAve{iCond}(iGrp,:),'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',2)
            elseif iGrp == 4
                plot(SmPTime,SmPLVelAllGrpAve{iCond}(iGrp,:),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2)
            end
        end
        ylim([-10,50])

        if iCond == 1
            xlabel('Post Interceptive Saccade Time, ms')
            ylabel('Pursuit Linear Vel (from Ang), deg/s')
        end
        legend({['LQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(1)),'%.2f')],...
            ['HQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(4)),'%.2f')]},'Box','off','Location','southeast','FontSize',15);

        hold off

        set(gca,'FontSize',15)
        title(LegText{iCond},'FontWeight','normal')
    end
    sbd.ErrGrpIdx = GrpIdx;
    sbd.EndErrGrpAve = EndErrGrpAve;
    sbd.LinVelSmPursGrp = SmPLVelAllGrp;
    sbd.LinVelSmPursGrpAve = SmPLVelAllGrpAve;

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 2 Radius as a function of time seperated by ending error, align to sacc off
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = '/SacOff_Rho_SacEndErr2E_Comb';

    for iCond = CondIComp(1,:)
        nexttile
        % CCW
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        % CW
        datas2 = find([Dataf1.TarDir1] == CondIComp(2,iCond) & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EndErr = []; SmPLVelAll = [];

        % stationary
        if iCond == 1
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2(datas1);
            RhoSacOffAll = sbd.RhoSacOff(datas1,:);
            SacDurAll = sbd.SacDurGoc1(datas1);
            % AngVelSacOffAll = sbd.AngVelSacOff(datas1,:);
            % LinVelSacOffAll = sbd.LinVelSacOff(datas1,:);
            % RhoVelSacOffAll = sbd.RhoVelSacOff(datas1,:);
        else
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2([datas1,datas2]);
            RhoSacOffAll = [sbd.RhoSacOff(datas1,:); sbd.RhoSacOff(datas2,:)];
            SacDurAll = [sbd.SacDurGoc1(datas1), sbd.SacDurGoc1(datas2)];
            % AngVelSacOffAll = [sbd.AngVelSacOffAll(datas1,:); -sbd.AngVelSacOffAll(datas2,:)];
            % LinVelSacOffAll = [sbd.LinVelSacOffAll(datas1,:); sbd.LinVelSacOffAll(datas2,:)];
            % RhoVelSacOffAll = [sbd.RhoVelSacOffAll(datas1,:); sbd.RhoVelSacOffAll(datas2,:)];
        end

        VelTime = (1:size(RhoSacOffAll,2))-TimeA;

        % seperate the EndErr into four group
        EndErrEdge = quantile(EndErr,0:0.25:1);

        GrpIdx{iCond} = cell(1,4);
        EndErrGrpAve{iCond} = nan(1,4);
        SacDurGrpAve{iCond} = nan(1,4);
        SacDurGrpStd{iCond} = nan(1,4);
        RhoSacOffAllGrp{iCond} = cell(1,4);
        RhoSacOffAllGrpAve{iCond} = nan(4,TimeL);
        RhoSacOffAllGrpStd{iCond} = nan(4,TimeL);

        hold on
        hl = []; hp = [];
        for iGrp = 1:length(EndErrEdge)-1
            GrpIdx{iCond}{iGrp} = find(EndErr>=EndErrEdge(iGrp) & EndErr<=EndErrEdge(iGrp+1));
            EndErrGrpAve{iCond}(iGrp) = circ_mean_nan(EndErr(GrpIdx{iCond}{iGrp})');
            SacDurGrpAve{iCond}(iGrp) = mean(SacDurAll(GrpIdx{iCond}{iGrp}),'omitmissing');
            SacDurGrpStd{iCond}(iGrp) = std(SacDurAll(GrpIdx{iCond}{iGrp}),'omitmissing');
            RhoSacOffAllGrp{iCond}{iGrp} = RhoSacOffAll(GrpIdx{iCond}{iGrp},:);
            RhoSacOffAllGrpAve{iCond}(iGrp,:) = mean(RhoSacOffAllGrp{iCond}{iGrp},'omitmissing');
            RhoSacOffAllGrpStd{iCond}(iGrp,:) = std(RhoSacOffAllGrp{iCond}{iGrp},'omitmissing');

            % plot the result
            % [hl{iGrp},hp{iGrp}] = boundedline(SmPTime,SmPLVelAllGrpAve{iCond}(iGrp,:),SmPLVelAllGrpStd{iCond}(iGrp,:));
            % set(hl{iGrp},'color','k','LineStyle',lStyle{iGrp},'LineWidth',1.5);
            % set(hp{iGrp},'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
            if iGrp == 1
                % plot the individual trials
                for iTrial = GrpIdx{iCond}{iGrp}
                    plot(VelTime,RhoSacOffAll(iTrial,:),'color',[0.7,0.7,0.7],'LineStyle','-','LineWidth',0.5)
                    % xline(SacDurAll(iTrial),'color',[0.7,0.7,0.7],'LineStyle','-','LineWidth',1)
                end
                x1 = xline(-SacDurGrpAve{iCond}(iGrp),'color','k','LineStyle','-','LineWidth',2);
                [hl1,hp1] = boundedline(VelTime, RhoSacOffAllGrpAve{iCond}(iGrp,:), RhoSacOffAllGrpStd{iCond}(iGrp,:));
                set(hl1,'color','k','LineStyle','-','LineWidth',2)
                set(hp1,'FaceColor',[0.5,0.5,0.5],'FaceAlpha',0.4,'EdgeColor','none')
                % p1 = plot(VelTime,RhoSacOffAllGrpAve{iCond}(iGrp,:),'color','k','LineStyle','-','LineWidth',2);
            elseif iGrp == 4
                for iTrial = GrpIdx{iCond}{iGrp}
                    plot(VelTime,RhoSacOffAll(iTrial,:),'color',[colorRGB1(iCond,:),0.6],'LineStyle','-','LineWidth',0.5)
                    % xline(SacDurAll(iTrial),'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',1)
                end
                x2 = xline(-SacDurGrpAve{iCond}(iGrp),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
                [hl2,hp2] = boundedline(VelTime, RhoSacOffAllGrpAve{iCond}(iGrp,:), RhoSacOffAllGrpStd{iCond}(iGrp,:));
                set(hl2,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2)
                set(hp2,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
                % p2 = plot(VelTime,RhoSacOffAllGrpAve{iCond}(iGrp,:),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
            end
        end
        xline(0,'color','k','LineStyle','-','LineWidth',2)
        uistack(x1,'top');
        uistack(x2,'top');
        uistack(hp1,'top');
        uistack(hp2,'top');
        uistack(hl1,'top');
        uistack(hl2,'top');

        ylim([-2,12])
        xlim([-200,300])
        if iCond == 1
            xlabel('Time Align to Saccade Off, ms')
            ylabel('Eye Location in Radius, degree')
        end
        legend([hl1,hl2],{['LQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(1)),'%.2f')],...
            ['HQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(4)),'%.2f')]},...
            'Box','off','Location','southeast','FontSize',15,'AutoUpdate','off');

        hold off

        set(gca,'FontSize',15)
        title(LegText{iCond},'FontWeight','normal')
    end

    sbd.RhoSacOffAllGrp = RhoSacOffAllGrp;
    sbd.RhoSacOffAllGrpAve = RhoSacOffAllGrpAve;

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 3 Radius velocity as a function of time seperated by ending error, align to sacc off
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = '/SacOff_RhoVel_SacEndErr2E_Comb';

    for iCond = CondIComp(1,:)
        nexttile
        % CCW
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        % CW
        datas2 = find([Dataf1.TarDir1] == CondIComp(2,iCond) & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EndErr = []; SmPLVelAll = [];

        % stationary
        if iCond == 1
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2(datas1);
            % RhoSacOffAll = sbd.RhoSacOff(datas1,:);
            SacDurAll = sbd.SacDurGoc1(datas1);
            % AngVelSacOffAll = sbd.AngVelSacOff(datas1,:);
            % LinVelSacOffAll = sbd.LinVelSacOff(datas1,:);
            RhoVelSacOffAll = sbd.RhoVelSacOff(datas1,:);
        else
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2([datas1,datas2]);
            % RhoSacOffAll = [sbd.RhoSacOff(datas1,:); sbd.RhoSacOff(datas2,:)];
            SacDurAll = [sbd.SacDurGoc1(datas1), sbd.SacDurGoc1(datas2)];
            % AngVelSacOffAll = [sbd.AngVelSacOffAll(datas1,:); -sbd.AngVelSacOffAll(datas2,:)];
            % LinVelSacOffAll = [sbd.LinVelSacOffAll(datas1,:); sbd.LinVelSacOffAll(datas2,:)];
            RhoVelSacOffAll = [sbd.RhoVelSacOff(datas1,:); sbd.RhoVelSacOff(datas2,:)];
        end

        VelTime = (1:size(RhoVelSacOffAll,2))-TimeA;

        % seperate the EndErr into four group
        EndErrEdge = quantile(EndErr,0:0.25:1);

        GrpIdx{iCond} = cell(1,4);
        EndErrGrpAve{iCond} = nan(1,4);
        SacDurGrpAve{iCond} = nan(1,4);
        SacDurGrpStd{iCond} = nan(1,4);
        RhoVelSacOffAllGrp{iCond} = cell(1,4);
        RhoVelSacOffAllGrpAve{iCond} = nan(4,TimeL);
        RhoVelSacOffAllGrpStd{iCond} = nan(4,TimeL);

        hold on
        hl = []; hp = [];
        for iGrp = 1:length(EndErrEdge)-1
            GrpIdx{iCond}{iGrp} = find(EndErr>=EndErrEdge(iGrp) & EndErr<=EndErrEdge(iGrp+1));
            EndErrGrpAve{iCond}(iGrp) = circ_mean_nan(EndErr(GrpIdx{iCond}{iGrp})');
            SacDurGrpAve{iCond}(iGrp) = mean(SacDurAll(GrpIdx{iCond}{iGrp}),'omitmissing');
            SacDurGrpStd{iCond}(iGrp) = std(SacDurAll(GrpIdx{iCond}{iGrp}),'omitmissing');
            RhoVelSacOffAllGrp{iCond}{iGrp} = RhoVelSacOffAll(GrpIdx{iCond}{iGrp},:);
            RhoVelSacOffAllGrpAve{iCond}(iGrp,:) = mean(RhoVelSacOffAllGrp{iCond}{iGrp},'omitmissing');
            RhoVelSacOffAllGrpStd{iCond}(iGrp,:) = std(RhoVelSacOffAllGrp{iCond}{iGrp},'omitmissing');

            % plot the result
            % [hl{iGrp},hp{iGrp}] = boundedline(SmPTime,SmPLVelAllGrpAve{iCond}(iGrp,:),SmPLVelAllGrpStd{iCond}(iGrp,:));
            % set(hl{iGrp},'color','k','LineStyle',lStyle{iGrp},'LineWidth',1.5);
            % set(hp{iGrp},'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
            if iGrp == 1
                % plot the individual trials
                for iTrial = GrpIdx{iCond}{iGrp}
                    plot(VelTime,RhoVelSacOffAll(iTrial,:),'color',[0.7,0.7,0.7],'LineStyle','-','LineWidth',0.5)
                    % xline(SacDurAll(iTrial),'color',[0.7,0.7,0.7],'LineStyle','-','LineWidth',1)
                end
                x1 = xline(-SacDurGrpAve{iCond}(iGrp),'color','k','LineStyle','-','LineWidth',2);
                [hl1,hp1] = boundedline(VelTime, RhoVelSacOffAllGrpAve{iCond}(iGrp,:), RhoVelSacOffAllGrpStd{iCond}(iGrp,:));
                set(hl1,'color','k','LineStyle','-','LineWidth',2)
                set(hp1,'FaceColor',[0.5,0.5,0.5],'FaceAlpha',0.4,'EdgeColor','none')
                % p1 = plot(VelTime,RhoVelSacOffAllGrpAve{iCond}(iGrp,:),'color','k','LineStyle','-','LineWidth',2);

            elseif iGrp == 4
                for iTrial = GrpIdx{iCond}{iGrp}
                    plot(VelTime,RhoVelSacOffAll(iTrial,:),'color',[colorRGB1(iCond,:),0.6],'LineStyle','-','LineWidth',0.5)
                    % xline(SacDurAll(iTrial),'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',1)
                end
                x2 = xline(-SacDurGrpAve{iCond}(iGrp),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
                [hl2,hp2] = boundedline(VelTime, RhoVelSacOffAllGrpAve{iCond}(iGrp,:), RhoVelSacOffAllGrpStd{iCond}(iGrp,:));
                set(hl2,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2)
                set(hp2,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
                % p2 = plot(VelTime,RhoVelSacOffAllGrpAve{iCond}(iGrp,:),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
            end
        end
        xline(0,'color','k','LineStyle','-','LineWidth',2)
        uistack(x1,'top');
        uistack(x2,'top');
        uistack(hp1,'top');
        uistack(hp2,'top');
        uistack(hl1,'top');
        uistack(hl2,'top');

        ylim([-100,600])
        xlim([-200,300])
        if iCond == 1
            xlabel('Time Align to Saccade Off, ms')
            ylabel('Eye Velocity in Radius, degree/s')
        end
        legend([hl1,hl2],{['LQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(1)),'%.2f')],...
            ['HQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(4)),'%.2f')]},...
            'Box','off','Location','southeast','FontSize',15,'AutoUpdate','off');

        hold off

        set(gca,'FontSize',15)
        title(LegText{iCond},'FontWeight','normal')
    end
    sbd.RhoVelSacOffAllGrp = RhoVelSacOffAllGrp;
    sbd.RhoVelSacOffAllGrpAve = RhoVelSacOffAllGrpAve;

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end


%% 4 Angular velocity as a function of time seperated by ending error, align to sacc on
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = '/SacOff_AngVel_SacEndErr2E_Comb';

    lStyle = {'--','-.',':','-'};


    for iCond = CondIComp(1,:)
        nexttile
        % CCW
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        % CW
        datas2 = find([Dataf1.TarDir1] == CondIComp(2,iCond) & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EndErr = []; SmPLVelAll = [];

        % stationary
        if iCond == 1
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2(datas1);
            % RhoSacOffAll = sbd.RhoSacOff(datas1,:);
            SacDurAll = sbd.SacDurGoc1(datas1);
            AngVelSacOffAll = rad2deg(sbd.AngVelSacOff(datas1,:));
            % LinVelSacOffAll = sbd.LinVelSacOff(datas1,:);
            % AngVelSacOffAll = sbd.RhoVelSacOff(datas1,:);
        else
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2([datas1,datas2]);
            % RhoSacOffAll = [sbd.RhoSacOff(datas1,:); sbd.RhoSacOff(datas2,:)];
            SacDurAll = [sbd.SacDurGoc1(datas1), sbd.SacDurGoc1(datas2)];
            AngVelSacOffAll = rad2deg([sbd.AngVelSacOff(datas1,:); -sbd.AngVelSacOff(datas2,:)]);
            % LinVelSacOffAll = [sbd.LinVelSacOffAll(datas1,:); sbd.LinVelSacOffAll(datas2,:)];
            % AngVelSacOffAll = [sbd.RhoVelSacOff(datas1,:); sbd.RhoVelSacOff(datas2,:)];
        end

        VelTime = (1:size(AngVelSacOffAll,2))-TimeA;

        % seperate the EndErr into four group
        EndErrEdge = quantile(EndErr,0:0.25:1);

        GrpIdx{iCond} = cell(1,4);
        EndErrGrpAve{iCond} = nan(1,4);
        SacDurGrpAve{iCond} = nan(1,4);
        SacDurGrpStd{iCond} = nan(1,4);
        AngVelSacOffAllGrp{iCond} = cell(1,4);
        AngVelSacOffAllGrpAve{iCond} = nan(4,TimeL);
        AngVelSacOffAllGrpStd{iCond} = nan(4,TimeL);

        hold on
        hl = []; hp = [];
        for iGrp = 1:length(EndErrEdge)-1
            GrpIdx{iCond}{iGrp} = find(EndErr>=EndErrEdge(iGrp) & EndErr<=EndErrEdge(iGrp+1));
            EndErrGrpAve{iCond}(iGrp) = circ_mean_nan(EndErr(GrpIdx{iCond}{iGrp})');
            SacDurGrpAve{iCond}(iGrp) = mean(SacDurAll(GrpIdx{iCond}{iGrp}),'omitmissing');
            SacDurGrpStd{iCond}(iGrp) = std(SacDurAll(GrpIdx{iCond}{iGrp}),'omitmissing');
            AngVelSacOffAllGrp{iCond}{iGrp} = AngVelSacOffAll(GrpIdx{iCond}{iGrp},:);
            AngVelSacOffAllGrpAve{iCond}(iGrp,:) = mean(AngVelSacOffAllGrp{iCond}{iGrp},'omitmissing');
            AngVelSacOffAllGrpStd{iCond}(iGrp,:) = std(AngVelSacOffAllGrp{iCond}{iGrp},'omitmissing');

            % plot the result
            % [hl{iGrp},hp{iGrp}] = boundedline(SmPTime,SmPLVelAllGrpAve{iCond}(iGrp,:),SmPLVelAllGrpStd{iCond}(iGrp,:));
            % set(hl{iGrp},'color','k','LineStyle',lStyle{iGrp},'LineWidth',1.5);
            % set(hp{iGrp},'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
            if iGrp == 1
                % plot the individual trials
                for iTrial = GrpIdx{iCond}{iGrp}
                    plot(VelTime,AngVelSacOffAll(iTrial,:),'color',[0.7,0.7,0.7],'LineStyle','-','LineWidth',0.5)
                    % xline(SacDurAll(iTrial),'color',[0.7,0.7,0.7],'LineStyle','-','LineWidth',1)
                end
                x1 = xline(-SacDurGrpAve{iCond}(iGrp),'color','k','LineStyle','-','LineWidth',2);
                [hl1,hp1] = boundedline(VelTime, AngVelSacOffAllGrpAve{iCond}(iGrp,:), AngVelSacOffAllGrpStd{iCond}(iGrp,:));
                set(hl1,'color','k','LineStyle','-','LineWidth',2)
                set(hp1,'FaceColor',[0.5,0.5,0.5],'FaceAlpha',0.4,'EdgeColor','none')
                % p1 = plot(VelTime,AngVelSacOffAllGrpAve{iCond}(iGrp,:),'color','k','LineStyle','-','LineWidth',2);

            elseif iGrp == 4
                for iTrial = GrpIdx{iCond}{iGrp}
                    plot(VelTime,AngVelSacOffAll(iTrial,:),'color',[colorRGB1(iCond,:),0.6],'LineStyle','-','LineWidth',0.5)
                    % xline(SacDurAll(iTrial),'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',1)
                end
                x2 = xline(-SacDurGrpAve{iCond}(iGrp),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
                [hl2,hp2] = boundedline(VelTime, AngVelSacOffAllGrpAve{iCond}(iGrp,:), AngVelSacOffAllGrpStd{iCond}(iGrp,:));
                set(hl2,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2)
                set(hp2,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
                % p2 = plot(VelTime,AngVelSacOffAllGrpAve{iCond}(iGrp,:),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
            end
        end
        xline(0,'color','k','LineStyle','-','LineWidth',2)
        uistack(x1,'top');
        uistack(x2,'top');
        uistack(hp1,'top');
        uistack(hp2,'top');
        uistack(hl1,'top');
        uistack(hl2,'top');

        ylim([-500,600])
        xlim([-200,300])
        if iCond == 1
            xlabel('Time Align to Saccade Off, ms')
            ylabel('Eye Velocity in Angular, degree/s')
        end
        legend([hl1,hl2],{['LQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(1)),'%.2f')],...
            ['HQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(4)),'%.2f')]},...
            'Box','off','Location','southeast','FontSize',15,'AutoUpdate','off');

        hold off

        set(gca,'FontSize',15)
        title(LegText{iCond},'FontWeight','normal')
    end

    sbd.AngVelSacOffAllGrp = AngVelSacOffAllGrp;
    sbd.AngVelSacOffAllGrpAve = AngVelSacOffAllGrpAve;

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end

%% 5 Linear velocity as a function of time seperated by ending error, align to sacc on
SecNum = SecNum+1;
if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = '/SacOff_LinVel_SacEndErr2E_Comb';

    lStyle = {'--','-.',':','-'};


    for iCond = CondIComp(1,:)
        nexttile
        % CCW
        datas1 = find([Dataf1.TarDir1] == iCond & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        % CW
        datas2 = find([Dataf1.TarDir1] == CondIComp(2,iCond) & ([Dataf1.TrialStatus] == 1 | [Dataf1.TrialStatus] == 5));
        EndErr = []; SmPLVelAll = [];

        % stationary
        if iCond == 1
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2(datas1);
            % RhoSacOffAll = sbd.RhoSacOff(datas1,:);
            SacDurAll = sbd.SacDurGoc1(datas1);
            LinVelSacOffAll = sbd.LinVelSacOff(datas1,:);
            % LinVelSacOffAll = sbd.LinVelSacOff(datas1,:);
            % LinVelSacOffAll = sbd.RhoVelSacOff(datas1,:);
        else
            EndErr = sbd.SacEndErrAng2ESignDeStaCen2([datas1,datas2]);
            % RhoSacOffAll = [sbd.RhoSacOff(datas1,:); sbd.RhoSacOff(datas2,:)];
            SacDurAll = [sbd.SacDurGoc1(datas1), sbd.SacDurGoc1(datas2)];
            LinVelSacOffAll = [sbd.LinVelSacOff(datas1,:); -sbd.LinVelSacOff(datas2,:)];
            % LinVelSacOffAll = [sbd.LinVelSacOffAll(datas1,:); sbd.LinVelSacOffAll(datas2,:)];
            % LinVelSacOffAll = [sbd.RhoVelSacOff(datas1,:); sbd.RhoVelSacOff(datas2,:)];
        end

        VelTime = (1:size(LinVelSacOffAll,2))-TimeA;

        % seperate the EndErr into four group
        EndErrEdge = quantile(EndErr,0:0.25:1);

        GrpIdx{iCond} = cell(1,4);
        EndErrGrpAve{iCond} = nan(1,4);
        SacDurGrpAve{iCond} = nan(1,4);
        SacDurGrpStd{iCond} = nan(1,4);
        LinVelSacOffAllGrp{iCond} = cell(1,4);
        LinVelSacOffAllGrpAve{iCond} = nan(4,TimeL);
        LinVelSacOffAllGrpStd{iCond} = nan(4,TimeL);

        hold on
        hl = []; hp = [];
        for iGrp = 1:length(EndErrEdge)-1
            GrpIdx{iCond}{iGrp} = find(EndErr>=EndErrEdge(iGrp) & EndErr<=EndErrEdge(iGrp+1));
            EndErrGrpAve{iCond}(iGrp) = circ_mean_nan(EndErr(GrpIdx{iCond}{iGrp})');
            SacDurGrpAve{iCond}(iGrp) = mean(SacDurAll(GrpIdx{iCond}{iGrp}),'omitmissing');
            SacDurGrpStd{iCond}(iGrp) = std(SacDurAll(GrpIdx{iCond}{iGrp}),'omitmissing');
            LinVelSacOffAllGrp{iCond}{iGrp} = LinVelSacOffAll(GrpIdx{iCond}{iGrp},:);
            LinVelSacOffAllGrpAve{iCond}(iGrp,:) = mean(LinVelSacOffAllGrp{iCond}{iGrp},'omitmissing');
            LinVelSacOffAllGrpStd{iCond}(iGrp,:) = std(LinVelSacOffAllGrp{iCond}{iGrp},'omitmissing');

            % plot the result
            % [hl{iGrp},hp{iGrp}] = boundedline(SmPTime,SmPLVelAllGrpAve{iCond}(iGrp,:),SmPLVelAllGrpStd{iCond}(iGrp,:));
            % set(hl{iGrp},'color','k','LineStyle',lStyle{iGrp},'LineWidth',1.5);
            % set(hp{iGrp},'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
            if iGrp == 1
                % plot the individual trials
                for iTrial = GrpIdx{iCond}{iGrp}
                    plot(VelTime,LinVelSacOffAll(iTrial,:),'color',[0.7,0.7,0.7],'LineStyle','-','LineWidth',0.5)
                    % xline(SacDurAll(iTrial),'color',[0.7,0.7,0.7],'LineStyle','-','LineWidth',1)
                end
                x1 = xline(-SacDurGrpAve{iCond}(iGrp),'color','k','LineStyle','-','LineWidth',2);
                [hl1,hp1] = boundedline(VelTime, LinVelSacOffAllGrpAve{iCond}(iGrp,:), LinVelSacOffAllGrpStd{iCond}(iGrp,:));
                set(hl1,'color','k','LineStyle','-','LineWidth',2)
                set(hp1,'FaceColor',[0.5,0.5,0.5],'FaceAlpha',0.4,'EdgeColor','none')
                % p1 = plot(VelTime,LinVelSacOffAllGrpAve{iCond}(iGrp,:),'color','k','LineStyle','-','LineWidth',2);

            elseif iGrp == 4
                for iTrial = GrpIdx{iCond}{iGrp}
                    plot(VelTime,LinVelSacOffAll(iTrial,:),'color',[colorRGB1(iCond,:),0.6],'LineStyle','-','LineWidth',0.5)
                    % xline(SacDurAll(iTrial),'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',1)
                end
                x2 = xline(-SacDurGrpAve{iCond}(iGrp),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
                [hl2,hp2] = boundedline(VelTime, LinVelSacOffAllGrpAve{iCond}(iGrp,:), LinVelSacOffAllGrpStd{iCond}(iGrp,:));
                set(hl2,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2)
                set(hp2,'FaceColor',colorRGB1(iCond,:),'FaceAlpha',0.5,'EdgeColor','none')
                % p2 = plot(VelTime,LinVelSacOffAllGrpAve{iCond}(iGrp,:),'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
            end
        end
        xline(0,'color','k','LineStyle','-','LineWidth',2)
        uistack(x1,'top');
        uistack(x2,'top');
        uistack(hp1,'top');
        uistack(hp2,'top');
        uistack(hl1,'top');
        uistack(hl2,'top');

        ylim([-10,50])
        xlim([-200,300])
        if iCond == 1
            xlabel('Time Align to Saccade Off, ms')
            ylabel('Eye Angular Velocity * Radius, degree/s')
        end
        legend([hl1,hl2],{['LQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(1)),'%.2f')],...
            ['HQ: ',num2str(rad2deg(EndErrGrpAve{iCond}(4)),'%.2f')]},...
            'Box','off','Location','southeast','FontSize',15,'AutoUpdate','off');

        hold off

        set(gca,'FontSize',15)
        title(LegText{iCond},'FontWeight','normal')
    end

    sbd.LinVelSacOffAllGrp = LinVelSacOffAllGrp;
    sbd.LinVelSacOffAllGrpAve = LinVelSacOffAllGrpAve;

    saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
end