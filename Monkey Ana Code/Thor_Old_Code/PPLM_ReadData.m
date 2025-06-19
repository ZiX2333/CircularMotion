% this code is the read data pipeline
% for human data, from
% create on Feb 23 2024, Xuan
% This is now used for pre-processing all the data and plot the results
% Adjusted on Feb 19 2025, Xuan
% This code is only used for preprocessing all the data

clc
clear
%% Load all the recording files
folderPath = pwd; % Change this to your directory
allItems = dir(folderPath); % Get all files and folders
% mkdir('AllSessionData');

% Filter only directories and exclude '.' and '..'
% Record Files and Files location
RcdFiles = allItems([allItems.isdir]); % Get only directories
RcdFilesName = {RcdFiles.name}; % Extract names
RcdFilesName = RcdFilesName(~ismember(RcdFilesName, {'.', '..','AllSessionData'})); % Remove '.' and '..'

% Record Analysis date
AnaDate = '/25_Feb19';

%% load and preProcess all the data
for iSession = 1:size(RcdFilesName,2)
    matFiles = dir([pwd,'/',RcdFilesName{iSession},'/*.mat']);
    for iMat = 1:length(matFiles)
        load([matFiles(iMat).folder,'/',matFiles(iMat).name]); % load all the mat files in this location
    end

    % 1 step of pre process
    ReadAllData
    % plot all the eye traces...
    % ReadEyeTrace
    % save data
    save([pwd,'/',RcdFilesName{iSession},'/',RcdFilesName{iSession},'_PreProcessed1.mat'],'Datax')
end

%% save figures
for iSession = 1:length(RcdFilesName)
    ResultDir = [pwd,'/',RcdFilesName{iSession},'/ResultsFig',AnaDate,'/'];

    saveAllFig(ResultDir)
    pause(0.1)
end