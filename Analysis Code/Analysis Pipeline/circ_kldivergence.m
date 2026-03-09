function kl_divergence = circ_kldivergence(pdf_P,pdf_Q,vfPDFSamples)
% This code is used to calculate the KL divergence on circular data
% Edited on Mar 14 2024, Xuan

% pdf_P and pdf_Q should be calculated from function "circ_ksdensity"
% Dylan Muir (2024). Kernel density estimation for circular functions ...
% (https://www.mathworks.com/matlabcentral/fileexchange/44072-kernel-density-estimation-for-circular-functions), ...
% MATLAB Central File Exchange. Retrieved March 15, 2024.

% Requires Circular Statistics Toolbox for Matlab

% Divergence from P to Q, Q is the reference, P is the observation
% pdf_P and pdf_Q should be estimated on vfPDFSamples, they should also
% have the same size;
% only for 1 dimension

% This code provides the KL area to be integrated

kl_divergence = zeros(size(vfPDFSamples));
for i = 1:length(kl_divergence)
    if pdf_P(i) > 0 && pdf_Q(i) > 0
        kl_divergence(i) = pdf_P(i) * log(pdf_P(i) / pdf_Q(i));
    elseif pdf_P(i) > 0 && pdf_Q(i) == 0
        kl_divergence(i) = nan;  % Handle the case where Q is zero and P is non-zero
    end

end

end