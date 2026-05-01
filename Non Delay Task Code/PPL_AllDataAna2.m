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
SubjSize1 = 8;
SubjSize2 = [12,13,2,11,1,4,5,6];
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
    SaveName = 'SacEndErr_Tar_2E_Comb_De2NonDe_XY_DeSta_BootS_Shuff_SigBar';
    SampXAveAveAllAve1 = []; SampYAveAveAllAve1 = []; SampYAveAveAllStd1 = []; SampYAveAveAllSE1 = [];
    SampXAveAveAllCondi1 = cell(1,4); 
    SampYAveAveAllCondi1 = cell(1,4);
    SampXAveAveAllAve2 = []; SampYAveAveAllAve2 = []; SampYAveAveAllStd2 = []; SampYAveAveAllSE2 = [];
    SampXAveAveAllCondi2 = cell(1,4); 
    SampYAveAveAllCondi2 = cell(1,4);
    pVals = cell(1,4);
    ReTime = 1000;
    for iCond = CondIComp(1,2:end)
        nexttile;
        hold on
        % for non delay trials
        SampYAveAveAll1 = []; SampXAveAveAll1 = []; 
        for iSubj = 1:SubjSize1
            SacEndErrAngBootS1 = DataAll1(iSubj).sbd.SacEndErrAngBootS_DeSta_Comb_Cen;
            % load the bootstrap result
            SampXAveAve1 = SacEndErrAngBootS1(iCond).SampXAveAve;
            SampYAveAve1 = SacEndErrAngBootS1(iCond).SampYAveAve;
            % combine the result
            SampYAveAveAll1 = [SampYAveAveAll1;SampYAveAve1];
            SampXAveAveAll1 = [SampXAveAveAll1;SampXAveAve1];

            % sort the result
            [SampXAveAve1, I] = sort(SampXAveAve1);
            SampYAveAve1 = SampYAveAve1(I);

            % plot the mean value for each subj
            plot(SampXAveAve1,SampYAveAve1,'color',colorRGB1(iCond,:),'LineStyle','-','LineWidth',2)
        end
        SampXAveAveAllCondi1{iCond} = SampXAveAveAll1;
        SampYAveAveAllCondi1{iCond} = SampYAveAveAll1;
        % plot all subject's data
        SampXAveAveAllAve1(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll1));
        SampYAveAveAllAve1(iCond,:) = circ_mean_nan(SampYAveAveAll1);
        SampYAveAveAllStd1(iCond,:) = circ_std_nan(SampYAveAveAll1);
        SampYAveAveAllSE1(iCond,:) = SampYAveAveAllStd1(iCond,:)/sqrt(SubjSize1);
        
        % for delay trials
        SampYAveAveAll2 = []; SampXAveAveAll2 = []; 
        for iSubj = SubjSize2
            SacEndErrAngBootS2 = DataAll2(iSubj).sbd.SacEndErrAngBootS_DeSta_Comb_Cen;
            % load the bootstrap result
            SampXAveAve2 = SacEndErrAngBootS2(iCond).SampXAveAve;
            SampYAveAve2 = SacEndErrAngBootS2(iCond).SampYAveAve;
            % combine the result
            SampYAveAveAll2 = [SampYAveAveAll2;SampYAveAve2];
            SampXAveAveAll2 = [SampXAveAveAll2;SampXAveAve2];

            % sort the result
            [SampXAveAve2, I] = sort(SampXAveAve2);
            SampYAveAve2 = SampYAveAve2(I);

            % plot the mean value for each subj
            plot(SampXAveAve2,SampYAveAve2,'color',colorRGB1(iCond,:),'LineStyle','--','LineWidth',2)
        end
        SampXAveAveAllCondi2{iCond} = SampXAveAveAll2;
        SampYAveAveAllCondi2{iCond} = SampYAveAveAll2;
        % plot all subject's data
        SampXAveAveAllAve2(iCond,:) = wrapTo2Pi(circ_mean_nan(SampXAveAveAll2));
        SampYAveAveAllAve2(iCond,:) = circ_mean_nan(SampYAveAveAll2);
        SampYAveAveAllStd2(iCond,:) = circ_std_nan(SampYAveAveAll2);
        SampYAveAveAllSE2(iCond,:) = SampYAveAveAllStd2(iCond,:)/sqrt(SubjSize1);
        
        yline(0,'k--','LineWidth',1)

        % sort the result
        [~, I] = sort(SampXAveAveAllAve1(iCond,:));
        % use boundedline to plot which can also skip the nan point
        [hl,hp] = boundedline(SampXAveAveAllAve1(iCond,I),SampYAveAveAllAve1(iCond,I),SampYAveAveAllSE1(iCond,I));
        set(hl,'color',colorRGB2(iCond,:),'LineStyle','-','LineWidth',3);
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        % sort the result
        [~, I] = sort(SampXAveAveAllAve2(iCond,:));
        % use boundedline to plot which can also skip the nan point
        [hl,hp] = boundedline(SampXAveAveAllAve2(iCond,I),SampYAveAveAllAve2(iCond,I),SampYAveAveAllSE2(iCond,I));
        set(hl,'color',colorRGB2(iCond,:),'LineStyle','--','LineWidth',3);
        set(hp,'FaceColor',colorRGB2(iCond,:),'FaceAlpha',0.4,'EdgeColor','none')

        % plot the significance bar
        % pVals{iCond} = F_BootSStat_GroupAve_pV5(SampYAveAveAll, ShuffYAveAveAll, ...
        %     SampYAveAveAllAve(iCond,:), ShuffYAveAveAllAve(iCond,:), ReTime);
        pVals{iCond} = F_BootSStat_GroupAve_pV5(SampYAveAveAll1, SampYAveAveAll2);
        % do the FDR correction
        % pVals{iCond} = mafdr(pVals{iCond},'BHFDR', true);
        pVals{iCond} = mafdr(pVals{iCond});
        F_CartPlotSigBar(SampXAveAveAllAve1(iCond,I), pVals{iCond}(I), 0.05, deg2rad(40));
        
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
        TV = mod(SampXAveAveAllAve1(iCond,:)+pi/2,2*pi); %theta value
        TV = [TV,TV(1)];
        RV1 = [SampYAveAveAllAve1(iCond,:),SampYAveAveAllAve1(iCond,1)];
        RV2 = [SampYAveAveAllSE1(iCond,:),SampYAveAveAllSE1(iCond,1)];
    
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

