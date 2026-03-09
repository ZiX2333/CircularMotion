function [s1,s2,s3] = SacMainSeq(sacAmp,sacPVel,sacDur,sacRT,xmax,dColor,dType,sz)

% sign size
% sz = 15;

% dType = '.' or 'x'

% xmax = max(sacAmp);

% Peak vel to Amp
subplot(3,1,1)
hold on
s1 = scatter(sacAmp,sacPVel,sz,'filled');
hold off
s1.CData = dColor;
s1.Marker = dType;
% s1.MarkerFaceAlpha = 0.6;
% s1.MarkerEdgeAlpha = 0.6;
ylabel ('Peak Velocity [deg/s]');
ylim([0,600])
xlim([0,xmax+2])
h1 = gca;
h1.XAxis.Visible = 'off';
set (h1,"XTick",[],"FontSize",15);
box off

% Saccade duration to Amplitude
subplot(3,1,2)
hold on
s2 = scatter(sacAmp,sacDur,sz,'filled');
s2.CData = dColor;
s2.Marker = dType;
% s2.MarkerFaceAlpha = 0.6;
% s2.MarkerEdgeAlpha = 0.6;
ylabel ('Duration [ms]');
ylim([0,120])
xlim([0,xmax+2])
h2 = gca;
h2.XAxis.Visible = 'off';
set (h2,"XTick",[],"FontSize",15);
box off

% Saccade Reaction Time to Amplitude
subplot(3,1,3)
hold on
s3 = scatter(sacAmp,sacRT,sz,'filled');
hold off
s3.CData = dColor;
s3.Marker = dType;
% s3.MarkerFaceAlpha = 0.6;
% s3.MarkerEdgeAlpha = 0.6;
ylabel ('Reaction Time [ms]');
ylim([0,600])
xlim([0,xmax+2])
xlabel ('Amplitude [deg]');
h3 = gca;
set (h3,"FontSize",15);
box off

end