close all;
clear;
rng(0);

N = 19; gamma = 1;
V_gt = linspace(-1, 1, N + 2); V_gt = V_gt(2:(end - 1));
V_0 = zeros(size(V_gt));
SimNum = 100;
EpisodeNum = 10;

n_list = 2.^(0:9);
k = [1, 1, 1, 1, 0.7, 0.5, 0.4, 0.2, 0.15, 0.15];
s_history = cell(SimNum, EpisodeNum); r_history = cell(SimNum, EpisodeNum);
for SimID = 1:SimNum
    for Episode = 1:EpisodeNum
        [s_history{SimID, Episode}, ~, r_history{SimID, Episode}] = OneEpisode((N + 1) / 2, N);
    end
end
display('n-step TD algorithm');
for ModeID = 1:2
    switch ModeID
        case 1
            Mode = 'Online';
        case 2
            Mode = 'Offline';
    end
    figure('Position', [300 200 500 400]);
    hold on;
    for n = n_list
        display(sprintf('n = %d, %s updating...', n, Mode));
        switch Mode
            case 'Online'
                alpha_list = linspace(0, 1 * k(n_list == n), 51);
            case 'Offline'
                alpha_list = linspace(0, 0.3 * k(n_list == n), 51);
        end
        RMS = zeros(1, length(alpha_list));
        for alpha = alpha_list
            for SimID = 1:SimNum
                V = V_0;
                for Episode = 1:EpisodeNum
                    V = nStepTD(s_history{SimID, Episode}, r_history{SimID, Episode}, gamma, V, n, alpha, Mode);
                    
                    RMS(alpha_list == alpha) = RMS(alpha_list == alpha) ...
                        + mean((V - V_gt).^2) / EpisodeNum / SimNum;
                end
            end
        end
        plot(alpha_list, RMS.^0.5);
    end
    xlabel('\alpha');
    ylabel('RMS');
    ylim([0.25, 0.55]);
    set(gca, 'FontSize', 15);
end