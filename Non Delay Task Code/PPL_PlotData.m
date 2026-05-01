% this code is the read data pipeline
% create on Feb 23 2024, Xuan

%% Participants info

PartInfo.Names = {'Lane04','Amd01','Eve01','zx03','Em02','Jon02','KD02','Kel02'};
PartInfo.Dates = {'031225','031925','031925','031925','032625','032625','032625','040225'};
plotAllfig = 0;

RawDataDir = '/Volumes/NO NAME/Interceptive Saccade';
EachSubDir = '/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/Human/CircularNoDelay';


%% Plot basic figure
for userNum = [1 2 4]
    [userID, userDate] = getInfo (userNum);
    load([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed6.mat']);
    ResultDate = 'Jun04';

    ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];
    mkdir(ResultDir);

    PPL_BasicPlots

    close all

    pause(5)

    close all

    clearvars -except PartInfo EachSubDir
end

%% Plot Ana figure
iFigAcc = 0;
for userNum = 1:8
    disp(['userNum = ',num2str(userNum)]);
    [userID, userDate] = getInfo (PartInfo, userNum);
    load([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed6.mat']);
    ResultDate = 'Jul30_25';

    ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];
    % rmdir(ResultDir);
    mkdir(ResultDir);
    % iFigAcc = userNum*100; 
    SecPlots = 1:20;
    PPL_DataAna4

    pause(1)

    % % % DataAll1(userNum).Dataf = Dataf;
    % DataAll1(userNum).Dataf1 = Dataf1;
    % % % DataAll1(userNum).Dataf2 = Dataf2;
    DataAll1(userNum).sbd = sbd;
    % DataAll1(userNum).sbdBoots.SacEndErrAngBootS_TarAxis = SacEndErrAngBootS;
    % DataAll1(userNum).sbdBoots.SacEndErrAngShuff_TarAxis = SacEndErrAngShuff;
    % DataAll1(userNum).sbdBoots.SacEndErrAngBootS_SacAxis = SacEndErrAngBootS;
    % DataAll1(userNum).sbdBoots.SacEndErrAngShuff_SacAxis = SacEndErrAngShuff;
    % DataAll1(userNum).sbdBoots.RTBootS_TarAxis = RTBootS;
    % DataAll1(userNum).sbdBoots.RTBootS_SacAxis = RTBootS;
    % DataAll1(userNum).sbdBoots.SmPVBootS_SacAxis = SmPVBootS;
    % DataAll1(userNum).sbdBoots.SacTMrkErrAngBootS_TarAxis = SacTMrkErrAngBootS;
    % DataAll1(userNum).sbdBoots.SacTMrkErrAngShuff_TarAxis = SacTMrkErrAngShuff;
    % DataAll1(userNum).sbdBoots.TarDispBootS_TarAxis = TarDispBootS;

    close all

    clearvars -except PartInfo EachSubDir userNum DataAll1
    % clearvars -except PartInfo EachSubDir userNum 
end
save([EachSubDir,'/AllSubject2/AllSubj_073025_PreProcessed2.mat'],'-v7.3')

%% save Ana figures for all subjects

for userNum = 1:8
    [userID, userDate] = getInfo (userNum);
    ResultDate = 'Apr03_25';
    ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];
    % FigSaveName{1} = ['RT_TarSacEnd_SacEndErr2E_Corr2_1Subj_',userID];
    saveAllFig(ResultDir)
    pause(0.3)
end


%% Plot Figure that combine all subj
% SecPlots = 1:3;
ResultDate = 'Sep23';
userID = 'AllSubject2';
ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];
% mkdir(ResultDir);
% PPL_AllDataAna5

%% Save Figures that combine all subjs
ResultDate = 'Apr10_25';
userID = 'AllSubject2';
ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];
saveAllFig(ResultDir)








