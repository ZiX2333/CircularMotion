% This function is used for smooth pursuit velocity calculation.
% Can seperate between different types of velocity, like angular or linear
% SmPVSec Velocity section
% SmPASec Acceleration section
% VelType: can be Linear or angular, in String
% Created by Xuan, Aug 15 2024
function SmPVel = FM_SmPCalcu(SmPVSec,SmPASec,DurThrs,VelThrs,AccThrs,VelAvd,VelType)
if strcmpi(VelType,'linear')
    % I will also remove all the trials that velocity >VelAvd to avoid
    SmPVSecDeMean = SmPVSec-mean(SmPVSec(abs(SmPVSec)<VelAvd),'omitmissing');
    % mark the de mean vel that exceed threshold
    SmPVSecDMM = zeros(size(SmPVSecDeMean)); SmPVSecDMM(abs(SmPVSecDeMean)>=VelThrs) = 1;
    [TimeS,TimeE,~,~,~] = SaccDetectAcc(SmPVSecDeMean, SmPVSecDMM, SmPASec, DurThrs, AccThrs);
    SmPSecCheck = ones(size(SmPVSecDeMean));
    for iTime = 1:length(TimeS)
        % remove the catch up saccades that detected
        SmPSecCheck(TimeS(iTime):TimeE(iTime)) = 0;
    end
    SmPSecCheck = logical(SmPSecCheck);
    if sum(SmPSecCheck) >= 20 % if after remove the saccade there is still 20 ms left
        SmPVel = mean(SmPVSec(SmPSecCheck),"omitmissing");
    else
        SmPVel = nan;
    end

elseif strcmpi(VelType,'angular')
    % I will also remove all the trials that velocity >VelAvd to avoid
    SmPVSecDeMean = SmPVSec-mean(SmPVSec(abs(SmPVSec)<VelAvd),'omitmissing');
    % mark the de mean vel that exceed threshold
    SmPVSecDMM = zeros(size(SmPVSecDeMean)); SmPVSecDMM(abs(SmPVSecDeMean)>=VelThrs) = 1;
    [TimeS,TimeE,~,~,~] = SaccDetectAcc(SmPVSecDeMean, SmPVSecDMM, SmPASec, DurThrs, AccThrs);
    SmPSecCheck = ones(size(SmPVSecDeMean));
    for iTime = 1:length(TimeS)
        % remove the catch up saccades that detected
        SmPSecCheck(TimeS(iTime):TimeE(iTime)) = 0;
    end
    SmPSecCheck = logical(SmPSecCheck);
    if sum(SmPSecCheck) >= 20 % if after remove the saccade there is still 20 ms left
        SmPVel = mean(SmPVSec(SmPSecCheck),"omitmissing");
    else
        SmPVel = nan;
    end
end
end