function [s1,s2,s3,h] = sac_mainSeq(sacAmp,sacPVel,sacDur,sacRT,dColor,t,haxes)
% This plot is used to plot saccade main seq
% first subplot: Peak Vel to Amp
% second subplot: Dur to Amp
% third subplot: RT to Amp
% make the adjust on Fontsize on Aug 15

% sign size
sz = 20;

% Peak vel to Amp
if size(haxes,1) <3
    nexttile
    s1 = scatter(sacAmp,sacPVel,sz,'filled');
else
    axes(haxes(3))
    hold on
    s1 = scatter(gca,sacAmp,sacPVel,sz,'filled');
end
s1.CData = dColor;
% s1.MarkerFaceAlpha = 0.6;
% s1.MarkerEdgeAlpha = 0.6;
ylabel ('Peak Velocity [deg/s]');
h1 = gca;
h1.XAxis.Visible = 'off';
set (h1,"XTick",[],"FontSize",15);
box off

% Saccade duration to Amplitude
if size(haxes,1) <3
    nexttile
    s2 = scatter(sacAmp,sacDur,sz,'filled');
else
    axes(haxes(2))
    hold on
    s2 = scatter(gca,sacAmp,sacDur,sz,'filled');
end
s2.CData = dColor;
% s2.MarkerFaceAlpha = 0.6;
% s2.MarkerEdgeAlpha = 0.6;
ylabel ('Duration [ms]');
h2 = gca;
h2.XAxis.Visible = 'off';
set (h2,"XTick",[],"FontSize",15);
box off

% Saccade Reaction Time to Amplitude
if size(haxes,1) <3
    nexttile
    s3 = scatter(sacAmp,sacRT,sz,'filled');
else
    axes(haxes(1))
    hold on
    s3 = scatter(gca,sacAmp,sacRT,sz,'filled');
end
s3.CData = dColor;
% s3.MarkerFaceAlpha = 0.6;
% s3.MarkerEdgeAlpha = 0.6;
ylabel ('Reaction Time [ms]');
xlabel ('Amplitude [deg]');
h3 = gca;
set (h3,"FontSize",15);
box off

h = {h1,h2,h3};

t.TileSpacing = 'compact';
end