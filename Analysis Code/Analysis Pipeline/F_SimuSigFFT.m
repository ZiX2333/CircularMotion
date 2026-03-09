function recsignal = F_SimuSigFFT(v, x)
%This is the function corresponding to F_PhiMeasure
% Adjust by Xuan, Sep 04 2024

% % v - original signal
% % x - x-values corresponding to the signal (e.g., time values)
%
% windows generation
vwin = hanning(length(v), 'periodic'); % Apply Hanning window
V = fft(v .* vwin); % Perform FFT on the windowed signal

% fundamental frequency detection
[~, indv] = max(abs(V)); 

% phase difference estimation and amplitude
% length(V)/2 since we only consider the one-side FFT spectrum (positive
% freqs), must multiply the amp by 2 to account for this distribution
amplitude = abs(V(indv)) / (length(v)/2); % Normalize to get the amplitude
phase = angle(V(indv)); % Phase of the fundamental frequency

% Calculate frequency from the FFT index and x-values
N = length(v); % Total number of samples
delta_x = mean(diff(x)); % Mean difference between consecutive x-values (sampling interval)
frequency = (indv-1) / (N * delta_x); % Frequency in Hz (or in 1/x units if x is not time)

% Reconstruct the signal using the calculated frequency
recsignal = amplitude * cos(2 * pi * frequency * x + phase); % using cosine wave
end
