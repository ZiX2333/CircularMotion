% This code is used to check if saccades are correctly detected
% I'm going to use Datax this file to plot all the saccade eye traces
% Created by Xuan, Jan 29th

% if plotAllfig == 1

%% load data and parameters
SacTraFolder = 'SacTraFigNew';
DataDir = [pwd,'/'];
FigDir = [DataDir, SacTraFolder];
mkdir(FigDir);
mkdir([FigDir,'/CW/']);
mkdir([FigDir,'/CCW/']);
mkdir([FigDir,'/Sta/']);
% basic settings
colorRGB = [0 0.4470 0.7410;... % blue
    0.9290 0.6940 0.1250; %yellow
    0.4660 0.6740 0.1880;... % green;
    0.8500 0.3250 0.0980;];% orange
% light one
colorRGB1 = [202, 218, 237;...
    248, 222, 126;... % 246, 219, 117
    206, 232, 195;...
    246, 210, 168]/255;
% dark one
colorRGB2 = [72, 128, 184;... %blue
    194, 123, 55;... % yellow 238, 169, 60
    85, 161, 92;... % green),2)
    213, 95, 43]; %pink/orange

TarDir = {'Sta','CCW','CCW','CCW','CW','CW','CW'};
TarVel = {'0','108','215','323','-108','-215','-323'};


%% For loop to plot all the saccades
% for iTrial = 130:height(Datax)
for iTrial = 1:size(Datax,1)
    % skip the step trials
    if contains(Datax.trialType{iTrial},'Step')
        continue
    end
    if Datax.trialErr(iTrial) ~= 1
        continue
    else
        figure(iTrial)
        set(gcf,'Position',[1,53,1403,813]);
        GoCueTime = []; SaccTime = []; TargTime = []; 
        GoCueTime = Datax.GoCueTime(iTrial);
        SaccTime = double(1:length(Datax.EyeLoc{iTrial})) - GoCueTime;
        TargTime = Datax.T1TimeReal{iTrial}' - GoCueTime;

        SaccTimeS = SaccTime<=600 & SaccTime>=-400;
        TargTimeS = TargTime<=600 & TargTime>=-400;

        SaccTime = SaccTime(SaccTimeS);
        TargTime = TargTime(TargTimeS);

        EyeLocXY = []; EyeLocTR = []; EyeVelR = []; EyeVelAcc = [];
        EyeLocXY = Datax.EyeLoc{iTrial}(1:2,SaccTimeS);
        EyeLocTR = Datax.EyeLoc{iTrial}(3:4,SaccTimeS);
        EyeVelR = Datax.EyeVel{iTrial}(4,SaccTimeS)/100;
        EyeVelAcc = Datax.EyeVel{iTrial}(end,SaccTimeS)/100;

        SaccOnT = Datax.SacTimeGoc2{iTrial}(1,1) - GoCueTime;
        SaccOffT = Datax.SacTimeGoc2{iTrial}(2,1) - GoCueTime;
        SaccPVel = Datax.SacPvelGoc2{iTrial}(2,1) - GoCueTime;

        SaccOnTIdx = SaccTime == SaccOnT;
        SaccOffTIdx = SaccTime == SaccOffT;
        SaccPVelIdx = SaccTime == SaccPVel;

        TargLocXY = []; TargLocTR = [];
        TargLocXY = Datax.T1LocReal{iTrial}(TargTimeS',1:2)';
        TargLocTR = Datax.T1LocReal{iTrial}(TargTimeS',3:4)';
        
        % plot the cartesian version first
        subplot(1,2,1)
        hold on
        % eye trace x
        p1 = plot(SaccTime,EyeLocXY(1,:),'LineWidth',2,'Color',colorRGB(1,:));
        % eye trace y
        p2 = plot(SaccTime,EyeLocXY(2,:),'LineWidth',2,'Color',colorRGB(4,:));
        % plot the eye velocity traces
        plot(SaccTime,EyeVelAcc,'LineWidth',2,'Color',colorRGB1(3,:),'LineStyle','-.');
        p3 = plot(SaccTime,EyeVelR,'LineWidth',2,'Color',colorRGB(3,:));

        % target trace x
        p1_1 = plot(TargTime,TargLocXY(1,:),'LineWidth',2,'LineStyle','-.','Color',colorRGB1(1,:));
        % target trace y
        p2_1 = plot(TargTime,TargLocXY(2,:),'LineWidth',2,'LineStyle','-.','Color',colorRGB1(4,:));

        % target on and go cue
        xline(Datax.GoCueTime(iTrial),'k','LineWidth',1,'LineStyle',':');
        
        % Mark the saccade on and saccade off
        xline(0,'k','LineWidth',1,'LineStyle',':');
        xline(SaccOnT,'k','LineWidth',1,'LineStyle','--');
        xline(SaccOffT,'k','LineWidth',1,'LineStyle','--');
        
        hold off
        xlim([-400,600]);
        ylim([-10,10]);
        xlabel('Time from Go Cue, ms');
        ylabel('Saccade Amplitude, deg');
        legend([p1,p2,p3,p1_1,p2_1],{'Eye X','Eye Y','Eye Vel','Tar X','Tar Y'},"Box","off");
        set(gca,'FontSize',16);

        % plot the polar plot
        subplot(1,2,2)
        polarplot(wrapToPi(EyeLocTR(1,find(SaccOnTIdx==1):end)),...
            EyeLocTR(2,find(SaccOnTIdx==1):end),'LineWidth',2,'Color',colorRGB(2,:));
        hold on
        polarplot(wrapToPi(TargLocTR(1,:)),TargLocTR(2,:),'LineWidth',2,'Color','k');
        % mark the saccade onset and offset point and peak velocity location
        polarplot(EyeLocTR(1,SaccOnTIdx),EyeLocTR(2,SaccOnTIdx),'kx', 'MarkerSize', 8,'LineWidth',1.5)
        polarplot(EyeLocTR(1,SaccOffTIdx),EyeLocTR(2,SaccOffTIdx),'kx', 'MarkerSize', 8,'LineWidth',1.5)
        polarplot(EyeLocTR(1,SaccPVelIdx),EyeLocTR(2,SaccPVelIdx),'ko', 'MarkerSize', 8,'LineWidth',1.5)
        
        % try to plot the target location at the saccade end
        TargTimeRela = TargTime - SaccOffT;
        % find the first frame before saccade events
        TargTSaccE = TargTimeRela == max(TargTimeRela(TargTimeRela<=0));
        polarplot(TargLocTR(1,TargTSaccE),TargLocTR(2,TargTSaccE),'k*', 'MarkerSize', 8,'LineWidth',1.5)
        % mark the target start and target end
        polarplot(TargLocTR(1,1),TargLocTR(2,1),'ko','MarkerSize', 8,'LineWidth',1.5)
        polarplot(TargLocTR(1,end),TargLocTR(2,end),'k.','MarkerSize', 10,'LineWidth',1.5)
        hold off

        rlim([0,10]);
        set(gca,'FontSize',16);
        
        sgtitle(['Trial: ',num2str(iTrial),', Target Dir: ',TarDir{Datax.trialGrp(iTrial)},', Velocity: ',TarVel{Datax.trialGrp(iTrial)}],'FontSize',16);

        saveas(gcf,[FigDir,'/',TarDir{Datax.trialGrp(iTrial)},'/ExampleEyeTrace',num2str(iTrial),'.fig'])
        close all
        pause(0.1)
    end
end
% end