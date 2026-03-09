%% — Toy data (shifted by +1)
rng(0);
N    = 100;
Y1   = randn(1,N) + 1;   % Group 1
Y2   = randn(1,N);       % Group 2
x    = 1:N;              % the “location” axis
win  = 5;                % smoothing window

%% 1) Observed smoothed curves & their difference
f1_obs   = movmean(Y1, win);    % 1×N
f2_obs   = movmean(Y2, win);    % 1×N
obsDiff  = f1_obs - f2_obs;      % 1×N

%% 2) Build the null (permutation) distribution
nPerm    = 2000;                 % number of permutations
permDiff = zeros(nPerm, N);
pooled   = [Y1, Y2];
for p = 1:nPerm
    idx       = randperm(N+N);          % shuffle all 200 points
    Y1p       = pooled(idx(1:N));       % first N → new “Group 1”
    Y2p       = pooled(idx(N+1:end));   % last N → new “Group 2”
    f1p       = movmean(Y1p, win);
    f2p       = movmean(Y2p, win);
    permDiff(p,:) = f1p - f2p;          % difference under H0
end

%% 3) Pointwise two-tailed p-values
extreme = sum( abs(permDiff) >= abs(obsDiff), 1 );  
pVals   = (extreme + 1) ./ (nPerm + 1);    % 1×N

%% 4) Plot
figure('Position',[200 200 800 300]);
subplot(1,2,1);
hold on; box on;
plot(x, f1_obs, 'b-', 'LineWidth',1.5);
plot(x, f2_obs, 'r--','LineWidth',1.5);
legend('Group1','Group2','Location','Best');
title('Observed smoothed curves');

subplot(1,2,2);
plot(x, pVals, 'k.-','MarkerSize',10);
hold on;
yline(0.05,'r:','LineWidth',1.2);
ylim([0 1]);
xlabel('x (index)'); ylabel('p-value');
title('Pointwise permutation p-values');
