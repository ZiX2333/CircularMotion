% This is use to save all the figures
% Adjusted on July 24, Xuan
%   Make this function avaliable for save particular name of the figure
function saveAllFig(ResultDir,FigSaveName)
folderPath = ResultDir;
figFiles = dir(fullfile(folderPath, '*.fig'));
for i = 1:length(figFiles)

    [~, nameWithoutExt, ~] = fileparts(figFiles(i).name);
    if nargin < 2
        openfig([folderPath,nameWithoutExt,'.fig']);
        savebigPNG(1, [folderPath,nameWithoutExt])
    else
        for j = 1:length(FigSaveName)
            if strcmp(nameWithoutExt,FigSaveName{j})
                openfig([folderPath,nameWithoutExt,'.fig']);
                savebigPNG(1, [folderPath,nameWithoutExt])
            end
        end
    end

    close all
    pause(1)
end
end