function [sbd] = BehaviorGrpAnaM(Datax1,sbd)
% This code is used for behavior analysis
% Behavior Ana Monkey
% input Datax1, output is behavior data (sbd, saccade behavior data)
% I'm going to make sbd a table variable
% This code is especially for data that involve normalization, comparision
% that need to remove some outlier first

% Created on Feb 18, 2025, Xuan, Analysis basic saccade info
% Adjusted on Feb 19, 2025, Xuan, Add Smooth pursuit normalization

%% Calculate the Normalized RT
sbd.SacRTGoc1Norm = NaN(size(Datax1,1),1);
datasAll = find(Datax1.trialGrp ~= 0 & Datax1.trialErr == 1);
RTmin = min(sbd.SacRTGoc1(datasAll));
RTmax = max(sbd.SacRTGoc1(datasAll));
sbd.SacRTGoc1Norm = (sbd.SacRTGoc1-RTmin)/(RTmax-RTmin);

%% Calculated the normalized smooth pursuit velocity
sbd.SmPLVelGoc1Norm = NaN(size(Datax1,1),3); % linear velocity [50ms, 120ms]/[120ms, 200ms]/[200ms, 300ms] after the first sacc
sbd.SmPAVelGoc1Norm = NaN(size(Datax1,1),3); % Angular velocity [50ms, 120ms]/[120ms, 200ms]/[200ms, 300ms] after the first sacc
datasAll = find(Datax1.trialGrp ~= 0 & Datax1.trialErr == 1);
for iSelc = 1:size(sbd.SmPLVelGoc1Norm,2)
    % Linear velocity
    SmPLmin = min(sbd.SmPLVelGoc1(datasAll,iSelc));
    SmPLmax = max(sbd.SmPLVelGoc1(datasAll,iSelc));
    sbd.SmPLVelGoc1Norm = (sbd.SmPLVelGoc1-SmPLmin)/(SmPLmax-SmPLmin);

    SmPAmin = min(abs(sbd.SmPAVelGoc1(datasAll,iSelc)));
    SmPAmax = max(abs(sbd.SmPAVelGoc1(datasAll,iSelc)));
    sbd.SmPAVelGoc1Norm = (abs(sbd.SmPAVelGoc1)-SmPAmin)/(SmPAmax-SmPAmin);
end

%% Calculate the de-stationary-trend ending error 2E
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
XVbase = []; YVbase = []; % pre occupy this variable
sbd.SacEndErrAng2ESignDeSta = NaN(size(Datax1,1),1);
for iCond = CondI
    datas1 = find(Datax1.trialGrp == iCond & Datax1.trialErr == 1);
    XV = []; YV = [];  
    XAve = []; YAve = []; YStd = [];
    XV = mod(wrapTo2Pi(sbd.TargLocSacEndAtcpTR2E(datas1,1))-pi/2,2*pi);
    YV = sbd.SacEndErrAng2ESign(datas1);
    if iCond == 1
        XVbase = XV; YVbase = YV;
    end
    winSize = deg2rad(45);
    stepSize = winSize;
    if iCond <5
        XNorm = []; YNorm = []; XIndAll = [];
        [~, YNorm, ~] = FM_CartScaMovNorm(winSize,stepSize,XV,XVbase,YV,YVbase,[0,deg2rad(315)]);
    else
        XNorm = []; YNorm = []; XIndAll = [];
        [~, YNorm, ~] = FM_CartScaMovNorm(winSize,stepSize,XV,XVbase,YV,-YVbase,[0,deg2rad(315)]);
    end

    % Record the normalized data
    sbd.SacEndErrAng2ESignDeSta(datas1) = YNorm;

end

end




% end