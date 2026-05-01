% Participants info
% this script used to store every participants' info

function [userID, userDate] = getInfo (PartInfo, userNum)
    userID = PartInfo.Names{userNum};
    userDate = PartInfo.Dates{userNum};
end