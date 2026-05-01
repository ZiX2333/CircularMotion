% Data Processing
% This script is used for data processing for all subject's data
% Created on Jun 19
%   Main use for ending error relevant analysis
% Adjusted on July 23 2024
%   Add the KL divergence cross subject analysis
% Adjusted on Aug 05 2024
%   Add the comparision
% Adjusted on Sep 12 2024
%   Plot the ending error in polar plot
% Adjusted on Sep 16
%   Plot the ending error in polar plot with eye axis
% Adjusted on Sep 18
%   Plot the polar plot of the RT
% Adjusted on Jan 02
%   Plot TMrk polar plot ending error, for -80ms
% Adjusted on Feb 19 2025
%   Plot the Target location at gocue as a function of RT
% Adjusted on Apr 24 2025
%   Polar plots for ending error as a function of eye location, for RT
% Adjusted on Jul 16 2025
%   Plot the sig bar of the averaged result

%% Basic info
LegText = [{'Stationary'},{'CCW 15'},{'CCW 30'},{'CCW 45'},{'CW 15'},{'CW 30'},{'CW 45'}];
% CondI = [0,1,3,5]; % CCW
% CondName = 'CCW';
% % CondI = [0,2,4,6];
% % CondName = 'CW';

% CondI = [0,1,3,5,2,4,6]; % CCW % CW
CondI = [1,2,3,4,5,6,7]; % Sta % CCW % CW
CondIComp = [1,2,3,4; 1,5,6,7]; % When I want to compare with stationary
CondICompName = {'CCW','CW'};
CondName = '_AllSubj';

colorRGB = [0 0.4470 0.7410;... % blue
    0.9290 0.6940 0.1250;... %yellow
    0.4660 0.6740 0.1880;... % green;
    0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250;... %yellow
    0.4660 0.6740 0.1880;... % green;
    0.8500 0.3250 0.0980];% orange
% light one
colorRGB1 = [202, 218, 237;...
    248, 222, 126;... % 246, 219, 117
    206, 232, 195;...
    246, 210, 168;...
    248, 222, 126;... % 246, 219, 117
    206, 232, 195;...
    246, 210, 168]/255;
% dark one
colorRGB2 = [72, 128, 184;... %blue
    206, 137, 56;... % yellow 238, 169, 60 194, 123, 55
    85, 161, 92;... % green),2)
    213, 95, 43;...
    206, 137, 56;... % yellow 238, 169, 60
    85, 161, 92;... % green),2)
    213, 95, 43]/255; %pink/orange

ifDoBasic = 1;
% SubjSize = length(DataAll1);
SubjSize = 8;
iFigAcc = 0;
SecNum = 0;

% -100, -80, -60, -40, -20, 0, Sacc Off
iTime = 1;

%% 1. plot all the subjects data together with mean value across and sigbar, Combine CCW and CW 0mean
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_Comb_XY_DeSta_BootS_Shuff_SigBar';
    SampXAveAveAllAve = []; SampYAveAveAllAve = []; SampYAveAveAllStd = []; SampYAveAveAllSE = [];
    SampXAveAveAllCondi = cell(1,4); 
    SampYAveAveAllCondi = cell(1,4);
    ShuffYAveAveAllCondi = cell(1,4);
    pVals = cell(1,4);
    ReTime = 1000;
    for iCond = CondIComp(1,2:end)
        nexttile;
        hold on
        SampYAveAveAll = []; SampXAveAveAll = []; ShuffYAveAveAll = [];

        for iSubj = 1:SubjSize
            SacEndErrAngBootS = DataAll1(iSubj).sbd.SacEndErrAngBootS_DeSta_Comb_Cen;
            SacEndErrAngShuff = DataAll1(iSubj).sbd.SacEndErrAngShuff_DeSta_Comb_Cen;

            % load the bootstrap result
            SampXAveAve = SacEndErrAngBootS(iCond).SampXAveAve;
            SampYAveAve = SacEndErrAngBootS(iCond).SampYAveAve;
            % load the shuff result for the future comparision
            ShuffYAveAve = SacEndErrAngShuff(iCond).ShuffYAveAve;
            % combine the result
            SampYAveAveAll = [SampYAveAveAll;SampYAveAve];
            SampXAveAveAll = [SampXAveAveAll;SampXAveAve];
            ShuffYAveAveAll = [ShuffYAveAveAll; ShuffYAveAve];

            % sort the result
            [SampXAveAve, I] = sort(SampXAveAve);
            SampYAveAve = SampYAveAve(I);
            ShuffYAveAve = ShuffYAveAve(I);

            % plot the mean value for each subj
            plot(SampXAveAve,SampYAveAve,'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',2)
            plot(SampXAveAve,ShuffYAveAve,'color','k','LineStyle','--','LineWidth',2)
        end
        SampXAveAveAllCondi{iCond} = SampXAveAveAll;
        SampYAveAveAllCondi{iCond} = SampYAveAveAll;
        ShuffYAveAveAllCondi{iCond} = ShuffYAveAveAll;
        % plot all subject's data
        SampXAveAveAllAve(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll));
        SampYAveAveAllAve(iCond,:) = circ_mean_nan(SampYAveAveAll);
        SampYAveAveAllStd(iCond,:) = circ_std_nan(SampYAveAveAll);
        ShuffYAveAveAllAve(iCond,:) = circ_mean_nan(ShuffYAveAveAll);
        SampYAveAveAllSE(iCond,:) = SampYAveAveAllStd(iCond,:)/sqrt(SubjSize);
        
        yline(0,'k--','LineWidth',1)

        % sort the result
        [~, I] = sort(SampXAveAveAllAve(iCond,:));
        % use boundedline to plot which can also skip the nan point
        [hl,hp] = boundedline(SampXAveAveAllAve(iCond,I),SampYAveAveAllAve(iCond,I),SampYAveAveAllSE(iCond,I));
        set(hl,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3);
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        % plot the significance bar
        % pVals{iCond} = F_BootSStat_GroupAve_pV5(SampYAveAveAll, ShuffYAveAveAll, ...
        %     SampYAveAveAllAve(iCond,:), ShuffYAveAveAllAve(iCond,:), ReTime);
        pVals{iCond} = F_BootSStat_GroupAve_pV5(SampYAveAveAll, ShuffYAveAveAll);
        % do the FDR correction
        % pVals{iCond} = mafdr(pVals{iCond},'BHFDR', true);
        pVals{iCond} = mafdr(pVals{iCond});
        F_CartPlotSigBar(SampXAveAveAllAve(iCond,I), pVals{iCond}(I), 0.05, deg2rad(40));
        
        xticks(deg2rad([0,90,180,270,360]))
        xticklabels([90,180,270,0,90])
        xlim(deg2rad([-5,365]))
        ylim(deg2rad([-30,50]))
        yticks(deg2rad(-30:15:30))
        yticklabels(-30:15:30)

        if iCond == 2
            xlabel('Target Direction at Sacc End, deg')
            ylabel('Sacc End Direction Difference - Sta, deg')
        end
        xline(pi/2,'LineWidth',1.5,'LineStyle',':');
        xline(pi,'LineWidth',1.5,'LineStyle',':');
        xline(3*pi/2,'LineWidth',1.5,'LineStyle',':');
        hold off
        title(LegText{iCond},'FontWeight','normal')
        set(gca,'FontSize',17)
    end
%     GroupStatR.pVals_CombCondi = pVals;
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

%% 2. plot the ave ending error in polar plot
% SecNum = SecNum+1;
% if ismember(SecNum,SecPlots)
    iFigAcc = iFigAcc+1;
    figure(iFigAcc)
    set(gcf,'Position',[1,154,826,712]);
    SaveName = [];
    SaveName = 'SacEndErr_Tar_2E_Comb_Polar_DeSta_BootS_Shuff_SigBar';
    
    RV = deg2rad([12, 13, 14]);
    
    iCondi = 0;
    for iCond = CondIComp(1,2:end)
        iCondi = iCondi+1;
        % plot the result saved above
        TV = mod(SampXAveAveAllAve(iCond,:)+pi/2,2*pi); %theta value
        TV = [TV,TV(1)];
        RV1 = [SampYAveAveAllAve(iCond,:),SampYAveAveAllAve(iCond,1)];
        RV2 = [SampYAveAveAllSE(iCond,:),SampYAveAveAllSE(iCond,1)];
    
        % plot the first fline
        polarplot(TV,RV1,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',2);
        hold on
        polarplot(TV,RV1-RV2,'color',[colorRGB1(iCond,:),0.7],'LineStyle','-','LineWidth',2);
        polarplot(TV,RV1+RV2,'color',[colorRGB1(iCond,:),0.7],'LineStyle','-','LineWidth',2);
    
        % add the significance
        pV = [pVals{iCond},pVals{iCond}(1)];
        F_PolarPlotSigBar(TV, pV, 0.05, RV(iCondi), [colorRGB(iCond,:),0.6]);
    end
    
    polarplot(0:0.01:2*pi,zeros(size(0:0.01:2*pi)),'LineStyle',':','Color','k','LineWidth',1.5)
    
    hold off
    
    rlim(deg2rad([-15,15]));
    rticks(deg2rad([-10,0,10]))
    rticklabels({'-10°','0°','10°'})
% 
%     % title(CondICompName{iDir},'FontWeight','normal')
%     set(gca,'FontSize',16)
%     saveas(gcf,[ResultDir,SaveName,CondName,'Subj_',userID,'.fig'])
% end

