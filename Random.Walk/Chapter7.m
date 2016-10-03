close all;
clear;
rng(0);

N = 19; gamma = 1;
V_gt = linspace(-1, 1, N + 2); V_gt = V_gt(2:(end - 1));
V_0 = zeros(size(V_gt));
SimNum = 100;
EpisodeNum = 10;

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
            n_list = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512];
            alpha_max_list = [1, 1, 1, 1, 0.8, 0.5, 0.4, 0.2, 0.2, 0.2];
        case 2
            Mode = 'Offline';
            n_list = [1, 2, 3, 4, 8, 16, 32, 64, 128, 256, 512];
            alpha_max_list = [0.3, 0.3, 0.2, 0.25, 0.2, 0.15, 0.15, 0.1, 0.1, 0.05, 0.05];
    end
    figure('Position', [300 200 500 400]);
    hold on;
    for n = n_list
        display(sprintf('n = %d, %s updating...', n, Mode));
        alpha_list = linspace(0, alpha_max_list(n_list == n), 51);
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

display('lambda-return algorithm');
lambda_list = [0, 0.4, 0.8, 0.9, 0.95, 0.975, 0.99, 1];
for ModeID = 1:2
    switch ModeID
        case 1
            Mode = 'Online';
            lambda_list = [0, 0.4, 0.8, 0.9, 0.95, 0.975, 0.99, 1];
            alpha_max_list = [1, 1, 1, 1, 1, 0.6, 0.2, 0.1];
        case 2
            Mode = 'Offline';
            lambda_list = [0, 0.4, 0.8, 0.9, 0.95, 0.975, 0.99, 1];
            alpha_max_list = [0.3, 0.3, 0.25, 0.2, 0.2, 0.15, 0.1, 0.05];
    end
    figure('Position', [300 200 500 400]);
    hold on;
    for lambda = lambda_list
        display(sprintf('lambda = %g, %s updating...', lambda, Mode));
        alpha_list = linspace(0, alpha_max_list(lambda_list == lambda), 51);
        RMS = zeros(1, length(alpha_list));
        for alpha = alpha_list
            for SimID = 1:SimNum
                V = V_0;
                for Episode = 1:EpisodeNum
                    V = TDlambda(s_history{SimID, Episode}, r_history{SimID, Episode}, gamma, V, lambda, alpha, Mode);
                    
                    RMS(alpha_list == alpha) = RMS(alpha_list == alpha) ...
                        + mean((V - V_gt).^2) / EpisodeNum / SimNum;
                end
            end
        end
        plot(alpha_list, RMS.^0.5);
    end
    xlabel('\alpha');
    ylabel('RMS');
    switch Mode
        case 'Online'
            xlim([0, 1]);
        case 'Offline'
            xlim([0, 0.3]);
    end
    ylim([0.25, 0.55]);
    set(gca, 'FontSize', 15);
end

display('TD(lambda), accumulating traces');
for ModeID = 1:2
    switch ModeID
        case 1
            Mode = 'Online';
            lambda_list = [0, 0.4, 0.8, 0.9, 0.95, 0.975, 0.99, 1];
            alpha_max_list = [1, 1, 1, 0.6, 0.4, 0.2, 0.1, 0.05];
        case 2
            Mode = 'Offline';
            lambda_list = [0, 0.4, 0.8, 0.9, 0.95, 0.975, 0.99, 1];
            alpha_max_list = [0.3, 0.3, 0.2, 0.2, 0.2, 0.15, 0.1, 0.05];
    end
    figure('Position', [300 200 500 400]);
    hold on;
    for lambda = lambda_list
        display(sprintf('lambda = %g, %s updating...', lambda, Mode));
        alpha_list = linspace(0, alpha_max_list(lambda_list == lambda), 51);
        RMS = zeros(1, length(alpha_list));
        for alpha = alpha_list
            for SimID = 1:SimNum
                V = V_0;
                E = zeros(size(V));
                for Episode = 1:EpisodeNum
                    V = EligibilityLearning(s_history{SimID, Episode}, r_history{SimID, Episode}, gamma, V, E, lambda, alpha, Mode, 'Accumulating');
                    
                    RMS(alpha_list == alpha) = RMS(alpha_list == alpha) ...
                        + mean((V - V_gt).^2) / EpisodeNum / SimNum;
                end
            end
        end
        plot(alpha_list, RMS.^0.5);
    end
    xlabel('\alpha');
    ylabel('RMS');
    switch Mode
        case 'Online'
            xlim([0, 1]);
        case 'Offline'
            xlim([0, 0.3]);
    end
    ylim([0.25, 0.55]);
    set(gca, 'FontSize', 15);
end

lambda_list = [0, 0.4, 0.8, 0.9, 0.95, 0.975, 0.99, 1];
for TypeID = 1:2
    switch TypeID
        case 1
            Type = 'Replacing';
            alpha_max_list = [1, 1, 1, 1, 1, 1, 0.9, 0.8];
        case 2
            Type = 'Dutch';
            alpha_max_list = [1, 1, 1, 1, 1, 1, 0.6, 0.15];
    end
    figure('Position', [300 200 500 400]);
    hold on;
    for lambda = lambda_list
        display(sprintf('lambda = %g, %s trace...', lambda, Type));
        alpha_list = linspace(0, alpha_max_list(lambda_list == lambda), 51);
        RMS = zeros(1, length(alpha_list));
        for alpha = alpha_list
            for SimID = 1:SimNum
                V = V_0;
                E = zeros(size(V));
                for Episode = 1:EpisodeNum
                    V = EligibilityLearning(s_history{SimID, Episode}, r_history{SimID, Episode}, gamma, V, E, lambda, alpha, 'Online', Type);
                    
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