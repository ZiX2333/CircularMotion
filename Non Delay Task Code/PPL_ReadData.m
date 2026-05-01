% this code is the read data pipeline
% for human data, from
% create on Feb 23 2024, Xuan

%% Participants info
global PartInfo plotAllfig

PartInfo.Names = {'Lane04','Amd01','Eve01','zx03','Em02','Jon02','KD02','Kel02'};
PartInfo.Dates = {'031225','031925','031925','031925','032625','032625','032625','040225'};

plotAllfig = 0;

RawDataDir = '/Volumes/NO NAME/InterceptiveNoDelay';
% RawDataDir = '/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/Human/Circular';
EachSubDir = '/Users/zixuan/Desktop/Pitt_Research/Interception Saccade/Experiment/Human/CircularNoDelay';

%% load data
% userID = '/EM01';
% userDate = '100124';
userNum = 8;
for iSub = userNum
    [userID, userDate] = getInfo (iSub);
    mkdir(userID)
    
    %% raw to preprocess 1
    load([RawDataDir,'/',userID,'/',userID,'_',userDate,'_rawData.mat']);
    is1k = 0;
    ReadAllData
    %% preprocess 1 to preprocess 4
    % I don't know why is 4. maybe there are some versions between

    ReadEyeLoc

    varSave = [];
    % save and clear all data
    varSave = {'DataEdf','Dataf','Sti','FP','Pre_FP','screen'};
    save([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed4.mat'],varSave{:});
    % clearvars -except DataEdf Dataf Sti FP Pre_FP screen
    %save('zx01_110823_PreProcessed2')

    clearvars -except PartInfo plotAllfig EachSubDir RawDataDir
end

%% Load Data
clearvars -except PartInfo EachSubDir plotAllfig
userNum = 12;
[userID, userDate] = getInfo (userNum);
load([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed4.mat']);
% pre setup of adjusting data
iTriali = 0;
DataAdj = [];

%% Adjust Data: PreProcess 4 to 5
IsOnOff = 0; % if it is 1, means addjust onset; 0 means adjust offset

% Get the current axes handle. If you have a specific axes handle, use that instead.
figNow = []; Kids = []; titleStr = []; dcm_obj = []; info_struct = [];
figNow = gcf;
% Get the title object from the axes
Kids = figNow.Children;
titleStr = Kids(1).String;
% read the trial number
iTrial = str2double(cell2mat(regexp(titleStr, 'Trial:\s+(\d+)', 'tokens','once')))
dcm_obj = datacursormode(figNow);
info_struct = getCursorInfo(dcm_obj);
% read the adjust info
num2adjust = info_struct(1).Position(1)

% write in the data I selected
iTriali = iTriali+1;
DataAdj(iTriali).TrailNum = iTrial;
DataAdj(iTriali).TimeGocOn = Dataf(iTrial).TimeGocOn;
DataAdj(iTriali).IsOnOff = IsOnOff;
DataAdj(iTriali).num2adjust = num2adjust;

ReadSacAdj

%% Save data
if exist('DataAdj','var')
    varSave = 'DataAdj';
    save([EachSubDir,'/',userID,'/',userID,'_',userDate,'_SaccCheck.mat'],varSave);
end

varSave = {'DataEdf','Dataf','Sti','FP','Pre_FP','screen'};
save([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed5.mat'],varSave{:});
clearvars -except DataEdf Dataf Sti FP Pre_FP screen PartInfo userNum EachSubDir plotAllfig
%save('zx01_110823_PreProcessed2')

%% Adjust the condition and save them into preprocessed 6
% a big change on the conditon:
% CondI = [0,1,3,5,2,4,6]; Sta, CCW 15, CCW 30, CCW 45, CW 15, CW 30, CW 45
% CondINew = [1,2,3,4,5,6,7]; Sta, CCW 15, CCW 30, CCW 45, CW 15, CW 30, CW 45
for userNum = 8
    [userID, userDate] = getInfo (userNum);
    load([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed4.mat']);

    % add new fields to the structure Dataf
    FNames = fieldnames(Dataf);
    newFName = 'TarDir1';
    Dataf(1).TarDir1 = [];
    FBefore = FNames(1:17); % Target Direction is on the 17 field
    FAfter = FNames(18:end);
    NewFOrder = [FBefore; {newFName}; FAfter];
    Dataf = orderfields(Dataf,NewFOrder);

    TarDir1 = nan(size(Dataf,2),1);
    for iTrial = 1:size(Dataf,2)
        switch Dataf(iTrial).TarDir
            case 0
                TarDir1(iTrial) = 1;
            case 1
                TarDir1(iTrial) = 2;
            case 3
                TarDir1(iTrial) = 3;
            case 5
                TarDir1(iTrial) = 4;
            case 2
                TarDir1(iTrial) = 5;
            case 4
                TarDir1(iTrial) = 6;
            case 6
                TarDir1(iTrial) = 7;
        end
        Dataf(iTrial).TarDir1 = TarDir1(iTrial);
    end

    varSave = {'DataEdf','Dataf','Sti','FP','Pre_FP','screen'};
    save([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed6.mat'],varSave{:});
    clearvars -except PartInfo EachSubDir userNum
end

%% Plot basic figure
for userNum = 12
    [userID, userDate] = getInfo (userNum);
    load([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed6.mat']);
    ResultDate = 'BasicPlots';

    ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];
    mkdir(ResultDir);

    PPL_BasicPlots

    close all

    pause(5)

    close all

    clearvars -except PartInfo EachSubDir
end

% %% Plot Ana figure
% iFigAcc = 0;
% for userNum = 1:11
%     [userID, userDate] = getInfo (userNum);
%     load([EachSubDir,'/',userID,'/',userID,'_',userDate,'_PreProcessed6.mat']);
%     ResultDate = 'July10';
% 
%     ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];
%     % rmdir(ResultDir);
%     mkdir(ResultDir);
%     % iFigAcc = userNum*100; 
%     SecPlots = [1,2];
%     PPL_DataAna18
% 
%     pause(5)
% 
%     % DataAll1(userNum).Dataf = Dataf;
%     % DataAll1(userNum).Dataf1 = Dataf1;
%     % DataAll1(userNum).Dataf2 = Dataf2;
%     % DataAll1(userNum).sbd = sbd;
%     % DataAll1(userNum).SacEndErrAngBootS = SacEndErrAngBootS;
%     % DataAll1(userNum).SacEndErrAngShuff = SacEndErrAngShuff;
% 
%     close all
% 
%     clearvars -except PartInfo EachSubDir userNum DataAll1
% end

%% save figures

for userNum = 12
    [userID, userDate] = getInfo (userNum);
    ResultDate = 'BasicPlots';
    ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];

    saveAllFig(ResultDir)
    pause(1)
end


%% Save Figure that combine all subj

ResultDate = 'Jun20';
userID = 'AllSubject2';
ResultDir = [EachSubDir,'/',userID,'/ResultFig/',ResultDate,'/'];
mkdir(ResultDir);


