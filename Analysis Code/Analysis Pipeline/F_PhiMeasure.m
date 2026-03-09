function [V,Phase] = F_PhiMeasure(v)
% instead of phase difference measure, this function give the phase measure
% based on dtf method
% just input v
% Created by Xuan, Aug 16, 2024, idea from Hristo Zhivomirov (2024). Phase 
% Difference Measurement with Matlab (https://www.mathworks.com/matlabcentral
% /fileexchange/48025-phase-difference-measurement-with-matlab), 
% MATLAB Central File Exchange. Retrieved August 26, 2024.

% When I have an offset on y-axis in my data, I'm introduce an DC-component
% to my data. The following part are from ChatGPT:
% Adding a DC component can affect the magnitudes of other frequency components
% because the DC component might become the largest one in the spectrum. 
% Consequently, when your F_PhiMeasure function tries to find the fundamental
% frequency by searching for the maximum magnitude, it may mistakenly identify
% the DC component as the dominant frequency, leading to an incorrect frequency
% and phase result.
% A DC component (a constant value) has a frequency of zero and no oscillatory
% behavior. Its phase is typically considered undefined or zero. So, when 
% your function detects the DC component as the major frequency (due to its 
% strong magnitude), the phase result will be zero, which is why you see 
% "no phase shift" after adding an offset.

% windows generation
vwin = hanning(length(v), 'periodic');

% perform fft on the signals
V = fft(v.*vwin); 

% fundamental frequency detection
[~, indv] = max(abs(V));

% phase difference estimation
Phase = angle(V(indv));

% restrict the phase difference in the range [-pi, pi]
Phase = wrapToPi(Phase);

end