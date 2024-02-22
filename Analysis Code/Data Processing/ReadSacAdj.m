%% change individual trials
userID = 'EM01';
userDate = '100124';
SacTraFolder = 'SacTraFigNew';
DataDir = ['/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/CircularMotion/Circular/', userID, '/'];
FigDir = [DataDir, SacTraFolder];

%% Load Data
load([userID,'_',userDate,'_','PreProcessed4.mat'])

%% adjust the saccade
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

TarDir = {'Sta','CCW','CW','CCW','CW','CCW','CW'};
TarVel = {'0','15','-15','30','-30','45','-45'};

iTrial = 438;
num2adjust = 244;
IsOnOff = 0; % if it is 1, means addjust onset; 0 means adjust offset
iColm = 3; % find Radius
GocW = [-500,500];
GocC = find(GocW(1):GocW(2) == 0);

% find the first saccade after gocue, this part is also used for change
% this saccade
% SaccTemp = [];
% SaccTemp = Dataf(iTrial).SaccSeqInfo{3};
% do not include peak velocity in time
% Start time, End time, Duration, Reaction Time
WhichC = find(Dataf(iTrial).SaccSeqInfo{iColm}(1,:)>=Dataf(iTrial).TimeGocOn,1,"first");

% onset or offset
if IsOnOff == 1
    % adjust the onset time
    Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC) = num2adjust + Dataf(iTrial).TimeGocOn;
elseif IsOnOff == 0
    % adjust the offset time
    Dataf(iTrial).SaccSeqInfo{iColm}(2,WhichC) = num2adjust + Dataf(iTrial).TimeGocOn;
end

% ajust the duration and peakvelocity based on the adjustment
Dataf(iTrial).SaccSeqInfo{iColm}(3,WhichC) = Dataf(iTrial).SaccSeqInfo{iColm}(2,WhichC)-...
    Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC);
Dataf(iTrial).SaccSeqInfo{iColm}(4,WhichC) = max(Dataf(iTrial).EyeLocRVel...
    (iColm,Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC):Dataf(iTrial).SaccSeqInfo{iColm}(2,WhichC)));

% find the saccades after gocue
% SaccTemp = [];
% SaccTemp = Dataf(iTrial).SaccSeqInfo{3};
% do not include peak velocity in time
% Start time, End time, Duration, Reaction Time
for iCols = 1:size(Dataf(iTrial).SaccSeqInfo{iColm},1)-2
    Dataf(iTrial).SacTimeGoc2(iCols,:) = Dataf(iTrial).SaccSeqInfo{iColm}(iCols,WhichC:end);
end
% Reaction Time: Start time - Gocue TIme
Dataf(iTrial).SacTimeGoc2(iCols+1,:) = Dataf(iTrial).SaccSeqInfo{iColm}(1,WhichC:end)-Dataf(iTrial).TimeGocOn;

% 11 12 X start and end location, 21 22 Y Start and End location, 31 32 XY Start and end
% location, Theta Start and end, Displacement Start and end, Acc Disp
% Start and End
for iSacc = 1:size(Dataf(iTrial).SacTimeGoc2,2)
    Dataf(iTrial).SacLocGoc2{iSacc} = [Dataf(iTrial).EyeLocR(:, Dataf(iTrial).SacTimeGoc2(1,iSacc): Dataf(iTrial).SacTimeGoc2(2,iSacc));...
        Dataf(iTrial).EyeLocRVel(:, Dataf(iTrial).SacTimeGoc2(1,iSacc): Dataf(iTrial).SacTimeGoc2(2,iSacc));...
        Dataf(iTrial).EyeLocRAcc(:, Dataf(iTrial).SacTimeGoc2(1,iSacc): Dataf(iTrial).SacTimeGoc2(2,iSacc))];
end
% find the peak velocity
Dataf(iTrial).SacPvelGoc2(1:2,:) = Dataf(iTrial).SaccSeqInfo{iColm}(end-1:end,WhichC:end);

% plot this trial to check
figure(300)
set(gcf,'Position',[1,1,1380,865])
p1 = []; p2 = []; p3 = [];
EyeLoc = [];
TimeS1 = [];
TimeE1 = [];
EyeLoc = Dataf(iTrial).EyeLocRGoc2E;
TimeS1 = Dataf(iTrial).SacTimeGoc2(1,1)-Dataf(iTrial).TimeGocOn+1;
TimeE1 = Dataf(iTrial).SacTimeGoc2(2,1)-Dataf(iTrial).TimeGocOn+1;
TimeV1 = Dataf(iTrial).SacPvelGoc2(2,1)-Dataf(iTrial).TimeGocOn+1;

% find the second saccade after gocue (if exist)
TimeS2 = [];
TimeE2 = [];
TimeV2 = [];
if size(Dataf(iTrial).SacTimeGoc2,2) >1
    TimeS2 = Dataf(iTrial).SacTimeGoc2(1,2)-Dataf(iTrial).TimeGocOn+1;
    TimeE2 = Dataf(iTrial).SacTimeGoc2(2,2)-Dataf(iTrial).TimeGocOn+1;
    TimeV2 = Dataf(iTrial).SacPvelGoc2(2,2)-Dataf(iTrial).TimeGocOn+1;
end
TarTime = double(Dataf(iTrial).TarPathXReal(2,:))-Dataf(iTrial).TimeGocOn+1;
TarLocX = (double(Dataf(iTrial).TarPathXReal(1,:))- Dataf(iTrial).center(1))/Dataf(iTrial).ppd(1);
TarLocY = (double(Dataf(iTrial).TarPathYReal(1,:))- Dataf(iTrial).center(2))/Dataf(iTrial).ppd(2);
% plot cartesian
subplot(1,2,1)

hold on
% plot target lcoation
p1_1 = plot(TarTime,TarLocX,'LineWidth',2,'LineStyle','-.','Color',colorRGB1(1,:));
p2_1 = plot(TarTime,TarLocY,'LineWidth',2,'LineStyle','-.','Color',colorRGB1(4,:));

% plot eye x location
p1 = plot(GocW(1):length(EyeLoc(1,:))+GocW(1)-1,EyeLoc(1,:),'LineWidth',2,'Color',colorRGB(1,:));
% plot y location
p2 = plot(GocW(1):length(EyeLoc(2,:))+GocW(1)-1,EyeLoc(2,:),'LineWidth',2,'Color',colorRGB(4,:));
% plot the velocity traces xy
p3 = plot(GocW(1):length(EyeLoc(1,:))+GocW(1)-1,EyeLoc(9,:)/100,'LineWidth',2,'Color',colorRGB(3,:));
% plot the velocity traces acc disp
plot(GocW(1):length(EyeLoc(1,:))+GocW(1)-1,EyeLoc(12,:)/100,'LineWidth',2.5,'Color',colorRGB(3,:),'LineStyle','-.');


% plot reference line
plot([0,0],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],':k','LineWidth',1)
% plot Start and end of first Saccade Location
plot([TimeS1,TimeS1],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--k','LineWidth',1);
plot([TimeE1,TimeE1],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--k','LineWidth',1);
% mark the peak velocity point
plot(TimeV1,EyeLoc(9,TimeV1-GocW(1))/100,'ko','MarkerSize',10);

% plot Start and end of second Saccade Location if exist
if ~isempty(TimeS2)
    plot([TimeS2,TimeS2],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--r','LineWidth',1);
    plot([TimeE2,TimeE2],[min([EyeLoc(1,:),EyeLoc(2,:)])-1,max([EyeLoc(1,:),EyeLoc(2,:)])+1],'--r','LineWidth',1);
    plot(TimeV2,EyeLoc(9,TimeV2-GocW(1))/100,'ro','MarkerSize',10);
end


xlabel('Time from Fixation Off, ms')
ylabel('Saccade Amplitude, deg')

xlim([GocW(1),length(EyeLoc(1,:))+GocW(1)-1]);
ylim([-10,10]);

legend([p1,p2,p3,p1_1,p2_1],{'Eye X','Eye Y','Eye Vel','Tar X','Tar Y'},"Box","off");
set(gca,'FontSize',16);
hold off

% plot polar plot
subplot(1,2,2)
[TarAng, TarRho] = cart2pol(TarLocX,TarLocY);
TarAngTemp = TarAng(TarTime>=TimeS1-100 & TarTime<=TimeE1);
TarRhoTemp = TarRho(TarTime>=TimeS1-100 & TarTime<=TimeE1);

p3 = polarplot(wrapToPi(EyeLoc(4,:)),EyeLoc(3,:),'LineWidth',2,'Color',[0.4660 0.6740 0.1880]);
hold on
polarplot(wrapToPi(TarAng(TarTime>=TimeS1-100)), TarRho(TarTime>=TimeS1-100),...
    'LineWidth',2,'Color','Black');

% mark the saccade onset and offset point and peak velocity location
polarplot(EyeLoc(4,TimeS1-GocW(1)),EyeLoc(3,TimeS1-GocW(1)),'kx', 'MarkerSize', 8,'LineWidth',1.5)
polarplot(EyeLoc(4,TimeE1-GocW(1)),EyeLoc(3,TimeE1-GocW(1)),'kx', 'MarkerSize', 8,'LineWidth',1.5)
polarplot(EyeLoc(4,TimeV1-GocW(1)),EyeLoc(3,TimeV1-GocW(1)),'ko', 'MarkerSize', 8,'LineWidth',1.5)

% mark the second saccade onset and offset point and peak velocity location
if ~isempty(TimeS2)
    polarplot(EyeLoc(4,TimeS2-GocW(1)),EyeLoc(3,TimeS2-GocW(1)),'rx', 'MarkerSize', 8,'LineWidth',1.5)
    polarplot(EyeLoc(4,TimeE2-GocW(1)),EyeLoc(3,TimeE2-GocW(1)),'rx', 'MarkerSize', 8,'LineWidth',1.5)
    polarplot(EyeLoc(4,TimeV2-GocW(1)),EyeLoc(3,TimeV2-GocW(1)),'ro', 'MarkerSize', 8,'LineWidth',1.5)
end

if ~isempty(TarAngTemp)
    % mark the target location at saccade offset
    polarplot(TarAngTemp(end),TarRhoTemp(end),'k*', 'MarkerSize', 8,'LineWidth',1.5)
end

rlim([0,10]);
legend(p3,'Rho','Location', 'Northoutside','Box', 'off');
set(gca,'FontSize',16);
hold off

sgtitle(['Trial: ',num2str(iTrial),', Target Dir: ',TarDir{Dataf(iTrial).TarDir+1},', Velocity: ',TarVel{Dataf(iTrial).TarDir+1}],'FontSize',16);
saveas(gcf,[FigDir,'/',TarDir{Dataf(iTrial).TarDir+1},'/ExampleEyeTrace',num2str(iTrial),'_adj.fig'])


%% save and clear all data
varSave = {'DataEdf','Dataf','Sti','FP','Pre_FP','screen'};
save([DataDir,userID,'_',userDate,'_PreProcessed3.mat'],varSave{:});
clearvars -except DataEdf Dataf Sti FP Pre_FP screen
%save('zx01_110823_PreProcessed2')
