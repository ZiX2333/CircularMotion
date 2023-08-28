% Data Processing
% This script is used for data processing

%% Load Data
load('zx01_110823_PreProcessed3.mat')

%% basic settings
colorRGB = [0 0.4470 0.7410;... % blue
    % 0.9290 0.6940 0.1250; %yellow
    0.4660 0.6740 0.1880;... % green;
    0.8500 0.3250 0.0980;];% orange
% light one
colorRGB1 = [202, 218, 237;...
    % 248, 222, 126;... % 246, 219, 117
    206, 232, 195;...
    246, 210, 168]/255; 
% dark one
colorRGB2 = [72, 128, 184;... %blue
    % 194, 123, 55;... % yellow 238, 169, 60
    85, 161, 92;... % green),2)
    213, 95, 43]; %pink/orange

% Legend setting
LegText = [{'Stationary'},{'CounterClockwise'},{'Clockwise'}];

FixW = [-100,900];
TarW = [-400,600];
GocW = [-500,500];
SacW = [-500,500];

GocC = find(GocW(1):GocW(2) == 0);

%% PreProcessed of data
Dataf1 = Dataf;

% % remove Dataf that TrialStatus ~=1
% Dataf1([Dataf.TrialStatus]~=1) = [];
% 
% % remove trials that peak velocity < 50 deg/sec
% Dataf1([Dataf1.SacPvelGoc1]<50) = [];

% remove RT < 100ms, duration >=70ms, start radius >=3, end radius <=4,
% peak velocity < 50, have microsaccade 100ms before gocue (after already excluded)
iDrop = [];
for iTrial = 1:size(Dataf1,2)
    if Dataf1(iTrial).TrialStatus ~=1
        iDrop = [iDrop,iTrial];
        continue
    elseif Dataf1(iTrial).SacTimeGoc1(end)<100
        iDrop = [iDrop,iTrial];
        continue
    elseif Dataf1(iTrial).SacTimeGoc1(end-1)>=70
        iDrop = [iDrop,iTrial];
        continue
    elseif Dataf1(iTrial).SacLocGoc1(3,1) >=3
        iDrop = [iDrop,iTrial];
        continue
    elseif Dataf1(iTrial).SacLocGoc1(3,2) <=4
        iDrop = [iDrop,iTrial];
        continue
    elseif Dataf1(iTrial).SacPvelGoc1 <50
        iDrop = [iDrop,iTrial];
        continue
    end
    SacSeqTemp = Dataf(iTrial).SaccSeqInfo{3}(2,:)-Dataf(iTrial).TimeGocOn;
    % within 100ms before gocue
    MicroSacLoc = find(SacSeqTemp>=-100 & SacSeqTemp<=0);
    % have to last at least 5ms
    if ~isempty(MicroSacLoc) && Dataf(iTrial).SaccSeqInfo{3}(3,MicroSacLoc) >=5
        iDrop = [iDrop,iTrial];
        continue
    end

end
Dataf1(iDrop) = [];

%% Behavior Analysis
SacAmpGoc1 = zeros(size(Dataf1));
SacEndGoc1 = zeros(size(Dataf1));
SacDurGoc1 = zeros(size(Dataf1));
SacRTGoc1 = zeros(size(Dataf1));
SacSTmGoc1 = zeros(size(Dataf1));
SacETmGoc1 = zeros(size(Dataf1));
SacPvelGoc1 = zeros(size(Dataf1));

for iTrial = 1:size(Dataf1,2)
    % X, Y, Rho, Theta, Disp, Acc Disp
    SacAmpGoc1(iTrial) = Dataf1(iTrial).SacLocGoc1(3,2) - Dataf1(iTrial).SacLocGoc1(3,1);
    SacEndGoc1(iTrial) = Dataf1(iTrial).SacLocGoc1(3,2);
    % STime, ETime, Dur, RT
    SacSTmGoc1(iTrial) = Dataf1(iTrial).SacTimeGoc1(1);
    SacETmGoc1(iTrial) = Dataf1(iTrial).SacTimeGoc1(2);
    SacDurGoc1(iTrial) = Dataf1(iTrial).SacTimeGoc1(3);
    SacRTGoc1(iTrial) = Dataf1(iTrial).SacTimeGoc1(4);
    SacPvelGoc1(iTrial) = Dataf1(iTrial).SacPvelGoc1;
end

%% Saccade Main Sequence
figure(1)
t = tiledlayout(3,1);
s1 = []; s2 = []; s3 = [];
for iCond = 0:2 % 0: Stationary, 1 Counterclock wise, 2: clockwise
    h = [];
    datas = [];
    if iCond == 0
        datas = [Dataf1.TarDir] == iCond;
        [s1{iCond+1},s2{iCond+1},s3{iCond+1},h] = sac_mainSeq(SacAmpGoc1(datas),SacPvelGoc1(datas),...
            SacDurGoc1(datas),SacRTGoc1(datas),colorRGB(iCond+1,:),t,[]);
        haxes = t.Children;
        
    else
        datas = [Dataf1.TarDir] == iCond;
        [s1{iCond+1},s2{iCond+1},s3{iCond+1},h] = sac_mainSeq(SacAmpGoc1(datas),SacPvelGoc1(datas),...
            SacDurGoc1(datas),SacRTGoc1(datas),colorRGB(iCond+1,:),t,haxes);
    end
end

legend(haxes(1),LegText,"Box","off","FontSize",15,'Location','northeast');

%% find the nearest frame to the event time
% always find the first frame before the time
for iTrial = 1:size(Dataf1,2)
    % align to 100ms before Saccade onset
    Dataf1(iTrial).TarPathX(3,:) = Dataf1(iTrial).TarPathX(2,:) - (SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf1(iTrial).TarPathX(4,:) = Dataf1(iTrial).TarPathX(2,:) - SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf1(iTrial).TarPathX(5,:) = Dataf1(iTrial).TarPathX(2,:) - SacETmGoc1(iTrial);

    % align to 100ms before Saccade onset
    Dataf1(iTrial).TarPathY(3,:) = Dataf1(iTrial).TarPathX(2,:) - (SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf1(iTrial).TarPathY(4,:) = Dataf1(iTrial).TarPathX(2,:) - SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf1(iTrial).TarPathY(5,:) = Dataf1(iTrial).TarPathX(2,:) - SacETmGoc1(iTrial);

    % align to 100ms before Saccade onset
    Dataf1(iTrial).TarPathAng(3,:) = Dataf1(iTrial).TarPathX(2,:) - (SacSTmGoc1(iTrial)-100);
    % align to saccade onset
    Dataf1(iTrial).TarPathAng(4,:) = Dataf1(iTrial).TarPathX(2,:) - SacSTmGoc1(iTrial);
    % align to saccade offset
    Dataf1(iTrial).TarPathAng(5,:) = Dataf1(iTrial).TarPathX(2,:) - SacETmGoc1(iTrial);

    % find the target location, always find the first frame before the time
    % each row: 100ms before saccade onset, saccade onset, saccade offset
    for iRow = 3:5
        iCom = find(Dataf1(iTrial).TarPathX(iRow,:) == ...
                max(Dataf1(iTrial).TarPathX(iRow,Dataf1(iTrial).TarPathX(iRow,:)<=0)));
            % X Y location need to transefer to visual degree
            Dataf1(iTrial).SacTarGoc1(iRow-2,:) = ...
                [(Dataf1(iTrial).TarPathX(1,iCom) - Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1),...
                (Dataf1(iTrial).TarPathY(1,iCom) - Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2),...
                Dataf1(iTrial).TarPathAng(1,iCom)];
    end
end

%% align to 100ms before saccade onset
figure(2)
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
        % Polar Plot
        p1 = polarplot(EyeLoc(4,TimeS:TimeE)-Dataf1(iTrial).SacTarGoc1(1,3)+deg2rad(90),EyeLoc(3,TimeS:TimeE),'LineWidth',0.6,'Color',colorRGB(iCond+1,:));
        hold on
    end
    polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
sgtitle('Saccade Traces in 3 Conditions, Aligned to 100 ms before Saccade Onset','FontSize',15)

% align to saccade onset
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

%% align to saccade offset
figure(4)
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
        % p1 = polarplot(EyeLoc(4,TimeS:TimeE)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90),EyeLoc(3,TimeS:TimeE),'LineWidth',0.6,'Color',colorRGB(iCond+1,:));
        p1 = polarplot(EyeLoc(4,:)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90),EyeLoc(3,:),'LineWidth',0.6,'Color',colorRGB(iCond+1,:));
        hold on
    end
    polarplot(0:0.1:2*pi,8*ones(size(0:0.1:2*pi)),'--k','LineWidth',1)
    legend(p1,LegText{iCond+1},'Location', 'Southoutside','Box', 'off','FontSize',14)
    set(gca,'FontSize',14)
    rlim([0, 10])
    hold off
end
sgtitle('Saccade Traces in 3 Conditions, Aligned to Saccade Offset','FontSize',15)

%% Calculate saccade ending error (by radius distance and angular) with target loc at sac offset
% centered on target

SacEndErrX = zeros(size(Dataf1));
SacEndErrY = zeros(size(Dataf1));
SacEndErrAngTan = zeros(size(Dataf1)); % centered on Target
SacEndErrRho = zeros(size(Dataf1)); % centered on Target
SacEndErrRhoSign1 = zeros(size(Dataf1)); % left and right sign
SacEndErrRhoSign2 = zeros(size(Dataf1)); % up and down sign (overshoot or undershoot)


for iTrial = 1:size(Dataf1,2)
    SacEndLoc = [];
    TimeS = [];
    TimeE = [];
    % X, Y, Rho, Theta, Disp, AccDisp
    SacEndLoc = Dataf1(iTrial).SacLocGoc1(:,2);
    SacEndErrX(iTrial) = SacEndLoc(1) - Dataf1(iTrial).SacTarGoc1(3,1);
    SacEndErrY(iTrial) = SacEndLoc(2) - Dataf1(iTrial).SacTarGoc1(3,2);
    [SacEndErrAngTan(iTrial),SacEndErrRho(iTrial)] = cart2pol(SacEndErrX(iTrial),SacEndErrY(iTrial));
    
    % the SacEndErrRho is the distance, doesn't have location information
    % if I want to know whether the target is at the right or left location
    % of the target, I'm going to add a sign on it:left negative, right
    % Positive
    % left:
    % addjust to lag behind is negative, go to future is positive
    if wrapToPi(Dataf1(iTrial).SacLocGoc1(4,2)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) > deg2rad(90) && Dataf1(iTrial).TarDir ~= 2
        SacEndErrRhoSign1(iTrial) = +SacEndErrRho(iTrial);
    elseif wrapToPi(Dataf1(iTrial).SacLocGoc1(4,2)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) <= deg2rad(90) && Dataf1(iTrial).TarDir ~= 2
        SacEndErrRhoSign1(iTrial) = -SacEndErrRho(iTrial);
    elseif wrapToPi(Dataf1(iTrial).SacLocGoc1(4,2)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) >= deg2rad(90) && Dataf1(iTrial).TarDir == 2
        SacEndErrRhoSign1(iTrial) = -SacEndErrRho(iTrial);
    elseif wrapToPi(Dataf1(iTrial).SacLocGoc1(4,2)-Dataf1(iTrial).SacTarGoc1(3,3)+deg2rad(90)) < deg2rad(90) && Dataf1(iTrial).TarDir == 2
        SacEndErrRhoSign1(iTrial) = SacEndErrRho(iTrial);
    end

    % the SacEndErrRho is the distance, doesn't have undershoot or
    % overshoot info
    % if I need to calculate the overshoot or undershoot info, I need to
    % include amplitude information
    if Dataf1(iTrial).SacLocGoc1(3,2) > Dataf1(iTrial).TarEcc % overshoot
        SacEndErrRhoSign2(iTrial) = SacEndErrRho(iTrial);
    else
        SacEndErrRhoSign2(iTrial) = -SacEndErrRho(iTrial);
    end

end

%% plot for the above calcu, ending error with time
% plot relation between ending error (Radius distance) and RT
figure(2)
for iCond = 0:2
    datas = [Dataf1.TarDir] == iCond;
    subplot(1,3,iCond+1)

    % plot the relation between RT and ending error
    scatter(SacRTGoc1(datas),SacEndErrRho(datas),20,"filled",'o','CData',colorRGB(iCond+1,:));
    % % ylim([-1,5])
    xlim([100,500])

    % % plot the relation between duration+ RT and ending error, color code
    % % by duration
    % scatter(SacRTGoc1(datas)+[Dataf1(datas).DurDelay]+[Dataf1(datas).DurFix],SacEndErrRho(datas),20,...
    %     [Dataf1(datas).DurDelay]+[Dataf1(datas).DurFix],"filled",'o');
    % colormap('turbo')
    % colorbar
    % ylim([-1,4])
    % % xlim([200,1400])
    % xlim([800,2100])

    % s1.CData = colorRGB(iCond+1,:);
    % scatter(SacRTGoc1(datas),[Dataf1(datas).DurDelay])
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

%% plot relation between ending error (Radius add relative location, left and right) and RT
figure(4)
for iCond = 0:2
    datas = [Dataf1.TarDir] == iCond;
    subplot(1,3,iCond+1)

    % plot the relation between RT and ending error
    scatter(SacRTGoc1(datas),SacEndErrRhoSign1(datas),20,"filled",'o','CData',colorRGB(iCond+1,:));
    ylim([-4,5])
    xlim([100,500])

    % % plot the relation between delay + RT and ending error, color code
    % scatter(SacRTGoc1(datas)+[Dataf1(datas).DurDelay]+[Dataf1(datas).DurFix],SacEndErrRhoSign1(datas),20,...
    %     SacRTGoc1(datas),"filled",'o');
    % colormap('turbo')
    % colorbar
    % ylim([-3,5])
    % % xlim([200,1400])
    % xlim([800,2100])
    
    if iCond == 0
        ylabel('Radial Distance to the Target, deg')
    end
    xlabel(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Radial Distance lr) and Reaction Time','FontSize',15)
% sgtitle('Relation Between Saccadic Ending Error (Radial Distance lr) and Reaction Time + Delay (from Fixation onset to Offset)','FontSize',15)

%% up and down
figure(3)
for iCond = 0:2
    datas = [Dataf1.TarDir] == iCond;
    subplot(1,3,iCond+1)
    scatter(SacRTGoc1(datas),SacEndErrRhoSign2(datas),20,"filled",'o','CData',colorRGB(iCond+1,:));
    % s1.CData = colorRGB(iCond+1,:);
    % scatter(SacRTGoc1(datas),[Dataf1(datas).DurDelay])
    ylim([-5,5])
    xlim([100,500])
    if iCond == 0
        ylabel('Radial Distance to the Target, deg')
    end
    xlabel(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
% set(gcf,'FontSize',14)
sgtitle('Relation Between Saccadic Ending Error (Radial Distance ud) and Reaction Time','FontSize',15)

%% plot relation between ending error (angular error) and RT
figure(5)
for iCond = 0:2
    datas = [Dataf1.TarDir] == iCond;
    subplot(1,3,iCond+1)
    scatter(SacRTGoc1(datas),SacEndErrAngTan(datas),20,"filled",'o','CData',colorRGB(iCond+1,:));
    % s1.CData = colorRGB(iCond+1,:);
    % scatter(SacRTGoc1(datas),[Dataf1(datas).DurDelay])
    % ylim([-1,5])
    ytickValues = -2*pi :pi/2 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    xlim([100,500])
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


%% Calculate the dynamic saccade relation with the target location at saccade offset
% Anglular error between saccade initial direction and ending direction

% SacDynErrX = zeros(size(Dataf1)); % Saccade Dynamic Error X
% SacDynErrY = zeros(size(Dataf1)); % Saccade Dynamic Error Y
EyeCartGoc2Z = cell(size(Dataf1)); %2Z = 2 zero
EyePolrGocTan = cell(size(Dataf1)); % tangent angular
SacDynErrAngTan = cell(size(Dataf1)); % Saccade Dynamic angular Error
SacIniErrAngTan = zeros(size(Dataf1));
SacEndErrAngTan = zeros(size(Dataf1));
% SacDynErrRho = zeros(size(Dataf1)); % Saccade Dynamic Radius Error

for iTrial = 1:size(Dataf1,2)
    EyeLocGoc = []; % whole eye traces
    % EyeCartGoc2Zero = []; % whole eye traces (X-Y location) relative to zero point
    % EyePolrGoc2Zero = []; % whole eye traces (theta and rho)
    SacIniLoc = []; % Saccade Initial location
    TimeS = [];
    TimeE = [];
    TimeS = Dataf1(iTrial).SacTimeGoc1(1)-Dataf1(iTrial).TimeGocOn +GocC;
    TimeE = Dataf1(iTrial).SacTimeGoc1(2)-Dataf1(iTrial).TimeGocOn +GocC;
    % rows: X, Y, Rho, Theta, Disp, AccDisp, VelX, VelY, VelRho, don't need
    % velocity mark
    EyeLocGoc = Dataf1(iTrial).EyeLocRGoc(1:9,TimeS:TimeE);
    SacIniLoc = Dataf1(iTrial).EyeLocRGoc(1:9,TimeS);
    EyeCartGoc2Z{iTrial} = EyeLocGoc(1:2,:) - SacIniLoc(1:2,1);
    % EyeCartGoc2Z{iTrial} = EyeLocGoc(1:2,1) - EyeLocGoc(1:2,1:end-1);

    % % Dynamic saccade ending traces
    % SacDynErrX(iTrial) = EyeLocGoc(1,:) - Dataf1(iTrial).SacTarGoc1(3,1);
    % SacDynErrY(iTrial) = EyeLocGoc(2,:) - Dataf1(iTrial).SacTarGoc1(3,2);
    % only need X, Y location, at ten ms after saccade initiate
    % for iTime = 1:size(EyeLocGoc,2)-1
    %     [EyePolrGoc2Z{iTrial}(1,iTime), EyePolrGoc2Z{iTrial}(2,iTime) ] = ...
    %         cart2pol(EyeCartGoc2Z{iTrial}(1,iTime),EyeCartGoc2Z{iTrial}(2,iTime));
    %     SacDynErrAng2Z{iTrial}(iTime) = wrapToPi(EyePolrGoc2Z{iTrial}(1,iTime) - Dataf1(iTrial).SacTarGoc1(3,3));
    %     if iTime == 5
    %         SacIniErrAng2Z(iTrial) = SacDynErrAng2Z{iTrial}(iTime);
    %     end
    % 
    %     if iTime == size(EyeLocGoc,2)-1 -5
    %         SacEndErrAng2Z(iTrial) = SacDynErrAng2Z{iTrial}(iTime);
    %     end
    % end
    
    % atan2(y,x)
    EyePolrGocTan{iTrial} = atan2(EyeLocGoc(8,:),EyeLocGoc(7,:));
    SacDynErrAngTan{iTrial}  = wrapToPi(EyePolrGocTan{iTrial} - Dataf1(iTrial).SacTarGoc1(3,3));

    SacIniErrAngTan(iTrial) = SacDynErrAngTan{iTrial}(10);
    SacEndErrAngTan(iTrial) = SacDynErrAngTan{iTrial}(end-10);
end

%% Ending error with Time
figure(6)
for iCond = 0:2
    datas = [Dataf1.TarDir] == iCond;
    subplot(1,3,iCond+1)
    
    % Relation with RT
    scatter(SacRTGoc1(datas),SacIniErrAngTan(datas),20,colorRGB(iCond+1,:),'filled');
    
    % scatter(SacRTGoc1(datas)+[Dataf1(datas).DurDelay],SacIniErrAngTan(datas),20,...
    %     [Dataf1(datas).DurDelay],"filled",'o');

    % colormap('turbo')
    % colorbar

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([-pi/4,pi/4])
    % xlim([100,300])
    if iCond == 0
        ylabel('Angular Distance to the Target, deg')
    end
    xlabel(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccadic Initial Direction and Reaction Time','FontSize',15)
% sgtitle('Relation Between Saccadic Initial Direction and Reaction Time + Delay (from Target onset to Gocue)','FontSize',15)

%
figure(7)
for iCond = 0:2
    datas = [Dataf1.TarDir] == iCond;
    subplot(1,3,iCond+1)

    % Relation with RT
    scatter(SacRTGoc1(datas),SacEndErrAngTan(datas),20,colorRGB(iCond+1,:),'filled');

    % scatter(SacRTGoc1(datas)+[Dataf1(datas).DurDelay],SacEndErrAngTan(datas),20,...
    %     [Dataf1(datas).DurDelay],"filled",'o');

    % colormap('turbo')
    % colorbar

    ytickValues = -2*pi :pi/10 :2*pi;
    yticks(ytickValues);
    ytickLabels = arrayfun(@num2str, rad2deg(ytickValues), 'UniformOutput', false);
    yticklabels(ytickLabels);
    
    ylim([-pi/3,pi/3])
    % xlim([100,300])
    if iCond == 0
        ylabel('Angular Distance to the Target, deg')
    end
    xlabel(LegText{iCond+1})
    set(gca,'FontSize',14)
    axis square
end
sgtitle('Relation Between Saccadic Ending Direction and Reaction Time','FontSize',15)
% sgtitle('Relation Between Saccadic Ending Direction and Reaction Time + Delay (from Target onset to Gocue)','FontSize',15)

%% Color code the RT on the eye traces
figure(8)

% % Normalize the Reaction time to [0,1]
% Norm_RT = (SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix] - min(SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix]))/...
%     (max(SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix])-min(SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix]));

% MaxRTThrs = 300;
Norm_RT = (SacRTGoc1 - min(SacRTGoc1))/(max(SacRTGoc1)-min(SacRTGoc1));
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
colorbar_ticks = linspace(100, 500, 11); % Customize as needed
colorbar_labels = cellstr(num2str(colorbar_ticks.')); % Convert to cell array of strings
colorbar('Ticks', colorbar_ticks, 'TickLabels', colorbar_labels, 'TicksMode','auto','Position',[0.94,0.17,0.01,0.69]);

sgtitle('Saccade Traces in 3 Conditions, Aligned to Saccade Offset, Colored by RT','FontSize',15)

%% Color code the Target ending location on the eye traces
figure(4)

% % Normalize the Reaction time to [0,1]
% Norm_RT = (SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix] - min(SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix]))/...
%     (max(SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix])-min(SacRTGoc1+[Dataf1(:).DurDelay]+[Dataf1(:).DurFix]));

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

