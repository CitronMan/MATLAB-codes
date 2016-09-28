close all;
clear;
rng(0);

N = 5; gamma = 1;
V_gt = linspace(0, 1, N + 2); V_gt = V_gt(2:(end - 1));
V_0 = ones(size(V_gt)) * 0.5;

% Figure 6.3a
figure('Position', [300 200 500 400]); hold on;
plot(V_0, 'k--');
plot(V_gt, 'r--');
V = V_0; alpha = 0.1;
EpisodeNum = 100;
PlotEpisode = [1, 10, 100];
for Episode = 1:EpisodeNum
    [s_history, ~, r_history] = OneEpisode((N + 1) / 2, N, 'r_left', 0);
    V = nStepTD(s_history, r_history, gamma, V, 1, alpha, 'Online');
    if ismember(Episode, PlotEpisode)
        plot(V, 'Color', 'b');
    end
end
set(gca, 'XTick', 1:5, 'XTickLabel', {'A', 'B', 'C', 'D', 'E'}, 'FontSize', 15);

% Figure 6.3b
SimNum = 100;
for n = [1, Inf]
    switch n
        case 1
            alpha_list = [0.05, 0.1, 0.15];
        case Inf
            alpha_list = [0.01, 0.02, 0.03, 0.04];
    end
    figure('Position', [300 200 400 300]); hold on;
    for alpha = alpha_list
        RMS = zeros(1, EpisodeNum);
        for SimID = 1:SimNum
            V = V_0;
            for Episode = 1:EpisodeNum
                [s_history, ~, r_history] = OneEpisode((N + 1) / 2, N, 'r_left', 0);
                V = nStepTD(s_history, r_history, gamma, V, n, alpha, 'Online');
                RMS(Episode) = RMS(Episode) + mean((V - V_gt).^2)^0.5 / SimNum;
            end
        end
        plot(RMS);
    end
    xlabel('Episodes');
    ylabel('RMS'); ylim([0, 0.25]);
    switch n
        case 1
            title('TD(0)');
            legend('0.05', '0.1', '0.15', 'Location', 'NorthEast');
        case Inf
            title('Monte Carlo');
            legend('0.01', '0.02', '0.03', '0.04', 'Location', 'SouthWest');
    end
    set(gca, 'FontSize', 15);
end

% Figure 6.4
alpha = 5e-4;
SimNum = 100;
EpisodeNum = 100;
s_history = cell(1, EpisodeNum);
r_history = cell(1, EpisodeNum);
if ~exist('Fig6.4.mat', 'file')
    for n = [1, Inf]
        RMS = zeros(1, SimNum);
        tStart = tic;
        for SimID = 1:SimNum
            if mod(SimID, 10) == 0
                tElapse = toc(tStart);
                display(sprintf('Simulation %d/%d processed, elapsed time %.2fs', SimID, SimNum, tElapse));
            end
            V = V_0;
            for Episode = 1:EpisodeNum
                [s_history{Episode}, ~, r_history{Episode}] = OneEpisode((N + 1) / 2, N, 'r_left', 0);
                dV = Inf * ones(size(V));
                while max(abs(dV)) > 1e-4
                    dV = zeros(size(V));
                    for BatchIter = 1:Episode
                        V_new = nStepTD(s_history{BatchIter}, r_history{BatchIter}, gamma, V, n, alpha, 'Offline');
                        dV = dV + (V_new - V);
                    end
                    V = V + dV;
                end
                RMS(Episode) = RMS(Episode) + mean((V - V_gt).^2)^0.5 / SimNum;
            end
        end
        
        switch n
            case 1
                RMS_TD = RMS;
            case Inf
                RMS_MC = RMS;
        end
    end
    save('Fig6.4.mat', 'RMS_TD', 'RMS_MC');
else
    load('Fig6.4.mat', 'RMS_TD', 'RMS_MC');
end
figure('Position', [300 200 400 300]); hold on;
plot(RMS_TD); plot(RMS_MC);
xlabel('Episodes');
ylabel('RMS'); ylim([0, 0.25]);
title('Batch updating');
legend('TD(0)', 'MC');
set(gca, 'FontSize', 15);