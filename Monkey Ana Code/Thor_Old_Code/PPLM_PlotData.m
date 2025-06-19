% this code is the read data pipeline
% for human data, from
% create on Feb 23 2024, Xuan
% This is now used for pre-processing all the data and plot the results
% Adjusted on Feb 19 2025, Xuan
% This code is used to loop through all the preprocessed data and plot the
% analysis results

clc
clear
%% Load all the recording files
folderPath = pwd; % Change this to your directory
allItems = dir(folderPath); % Get all files and folders
mkdir('AllSessionData');

% Filter only directories and exclude '.' and '..'
% Record Files and Files location
RcdFiles = allItems([allItems.isdir]); % Get only directories
RcdFilesName = {RcdFiles.name}; % Extract names
RcdFilesName = RcdFilesName(~ismember(RcdFilesName, {'.', '..','AllSessionData'})); % Remove '.' and '..'

% Record Analysis date
% AnaDate = '/25_Feb19'; % plot the SmP & RT with End Err, KL Diver, SacEnd_TargLoc
AnaDate = '/25_Feb20'; % same plot as above but limit the ending raidus into 6 deg radius check window

%% load and preProcess loop through the preprocessed data
for iSession = 1:length(RcdFilesName)

    ResultDir = [pwd,'/',RcdFilesName{iSession},'/ResultsFig',AnaDate];
    % mkdir([pwd,'/',RcdFilesName{iSession},'/ResultsFig',AnaDate])
    % Load Data preprocessing
    load([pwd,'/',RcdFilesName{iSession},'/',RcdFilesName{iSession},'_PreProcessed1.mat'])

    %% plot the firgure (just for now)
    SecPlots = 1:3;
    PPLM_DataAna2
    % DataxAll(iSession).Datax1 = Datax1;
    % DataxAll(iSession).sbd = sbd;
    % DataxAll(iSession).klDivg = klDivg;
    % if only update the sbd, use this variable
    sbdAll(iSession).sbd = sbd;
    close all
    clearvars -except AnaDate RcdFilesName iSession RcdFilesLoc sbdAll
    % clearvars -except AnaDate RcdFilesName iSession RcdFilesLoc
end
save([pwd,'/AllSessionData/Thor_AllData_PreProcessed1_1.mat'],'sbdAll','-v7.3')

%% save figures
for iSession = 1:length(RcdFilesName)
    FigSaveName = {'SacEndErr2E_Normed_SmPVel_Linear_50_150_20240701_Thor_1';...
        'SacEndErr2E_Normed_SmPVel_Linear_80_180_20240701_Thor_1';...
        'SacEndErr2E_Normed_SmPVel_Linear_100_200_20240701_Thor_1'};
    ResultDir = [pwd,'/',RcdFilesName{iSession},'/ResultsFig',AnaDate,'/'];

    saveAllFig(ResultDir,FigSaveName)
    pause(0.1)
end


%% Load datax All and plot the results
AnaDate = '25_Feb19'; % plot the SmP & RT with End Err, KL Diver, SacEnd_TargLoc for all sessions

% load([pwd,'/AllSessionData/Thor_AllData_PreProcessed1.mat']);
ResultDir = [pwd,'/AllSessionData/ResultsFig/',AnaDate];
% mkdir(ResultDir);

SecPlots = 3:5;
PPLM_AllDataAna1

close all
clearvars -except AnaDate RcdFilesName iSession RcdFilesLoc ResultDir

%% save figures for all sessions data

FigSaveName = {'SacEndErr_SmPL_Normed_50_150_AllSessi';...
    'SacEndErr_SmPL_Normed_80_180_AllSessi';...
    'SacEndErr_SmPL_Normed_100_200_AllSessi'};
saveAllFig([ResultDir,'/'],FigSaveName)



