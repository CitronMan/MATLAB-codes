close all;
clear;

StateNum = 1000; StepSize = 100;
RWA_Obj = RandomWalkAgent(StateNum, StepSize);
s0 = 500;

EpisodeNum = 100000;
if ~exist('Result1.mat', 'file')
    display('Simulating Fig. 9.1...');
    GroupSize = 100; GroupNum = ceil(StateNum / GroupSize); alpha = 2e-5;
    V = AggregationPrediction(GroupSize, GroupNum, alpha);
    d = zeros(StateNum, 1);
    tStart = tic;
    for EpisodeID = 1:EpisodeNum
        [s_history, ~, r_history] = OneEpisode(s0, RWA_Obj);
        T = length(s_history) - 1; G = r_history(T);
        for t = 1:T
            V = V.Update(s_history(t), G);
            d(s_history(t)) = d(s_history(t)) + 1;
        end
        if mod(EpisodeID, 10000) == 0
            tElapse = toc(tStart);
            display(sprintf('%d/%d episodes processed, elapsed time %.2fs', EpisodeID, EpisodeNum, tElapse));
        end
    end
    V_est = zeros(StateNum, 1);
    for s = 1:StateNum
        V_est(s) = V.StateValue(s);
    end
    save('Result1.mat', 'd', 'V_est');
else
    load('Result1.mat', 'd', 'V_est');
    display('Previous results loaded.');
end

figure('Position', [300 200 400 300]);
hold on;
plot(RWA_Obj.V_true, 'b--');
plot(V_est, 'k');
xlabel('State');
legend('True', 'Estimation', 'Location', 'SouthEast');
set(gca, 'FontSize', 15);
figure('Position', [300 200 400 300]);
bar(d / sum(d), 1, 'EdgeColor', 'none');
xlim([1, StateNum]);
xlabel('State');
ylabel('Frequency');
title('d(s)');
set(gca, 'FontSize', 15);

if ~exist('Result2.mat', 'file')
    display('Simulating Fig. 9.2 left...');
    GroupSize = 100; GroupNum = ceil(StateNum / GroupSize); alpha = 0.2;
    V = AggregationPrediction(GroupSize, GroupNum, alpha);
    tStart = tic;
    for EpisodeID = 1:EpisodeNum
        [s_history, ~, r_history] = OneEpisode(s0, RWA_Obj);
        T = length(s_history) - 1;
        for t = 1:T
            G = r_history(t) + V.StateValue(s_history(t + 1));
            V = V.Update(s_history(t), G);
        end
        if mod(EpisodeID, 10000) == 0
            tElapse = toc(tStart);
            display(sprintf('%d/%d episodes processed, elapsed time %.2fs', EpisodeID, EpisodeNum, tElapse));
        end
    end
    V_est = zeros(StateNum, 1);
    for s = 1:StateNum
        V_est(s) = V.StateValue(s);
    end
    save('Result2.mat', 'V_est');
else
    load('Result2.mat', 'V_est');
    display('Previous results loaded.');
end

figure('Position', [300 200 400 300]);
hold on;
plot(RWA_Obj.V_true, 'b--');
plot(V_est, 'k');
xlabel('State');
legend('True', 'Estimation', 'Location', 'SouthEast');
set(gca, 'FontSize', 15);

if ~exist('Result3.mat', 'file')
    display('Simulating Fig. 9.2 right...');
    SimNum = 1000;
    EpisodeNum = 10;
    s_history = cell(SimNum, EpisodeNum);
    r_history = cell(SimNum, EpisodeNum);
    for SimID = 1:SimNum
        for EpisodeID = 1:EpisodeNum
            [s_history{SimID, EpisodeID}, ~, r_history{SimID, EpisodeID}] ...
                = OneEpisode(s0, RWA_Obj);
        end
    end
    GroupSize = 50; GroupNum = ceil(StateNum / GroupSize);
    
    n_list = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]; Resol = 50;
    RMS = zeros(length(n_list), Resol);
    alpha_max = [1, 1, 1, 0.9, 0.6, 0.4, 0.3, 0.2, 0.2, 0.2];
    for n = n_list
        display(sprintf('%d-step learning...', n));
        alpha_list = linspace(0, alpha_max(n_list == n), Resol);
        for alpha = alpha_list
            for SimID = 1:SimNum
                V = AggregationPrediction(GroupSize, GroupNum, alpha);
                for EpisodeID = 1:EpisodeNum
                    T = length(s_history{SimID, EpisodeID}) - 1;
                    for t = 1:T
                        if t + n <= T
                            G = sum(r_history{SimID, EpisodeID}(t:(t + n - 1))) + V.StateValue(s_history{SimID, EpisodeID}(t + n));
                        else
                            G = sum(r_history{SimID, EpisodeID}(t:T));
                        end
                        V = V.Update(s_history{SimID, EpisodeID}(t), G);
                    end
                end
                V_est = zeros(StateNum, 1);
                for s = 1:StateNum
                    V_est(s) = V.StateValue(s);
                end
                RMS(n_list == n, alpha_list == alpha) = RMS(n_list == n, alpha_list == alpha) ...
                    + mean((V_est - RWA_Obj.V_true).^2) / SimNum;
            end
        end
    end
    save('Result3.mat', 'n_list', 'alpha_max', 'Resol', 'RMS');
else
    load('Result3.mat', 'n_list', 'alpha_max', 'Resol', 'RMS');
    display('Previous results loaded.');
end

figure('Position', [300 200 500 400]);
hold on;
for n = n_list
    plot(linspace(0, alpha_max(n_list == n), Resol), RMS(n_list == n, :).^0.5);
end
xlabel('\alpha');
ylabel('RMS');
xlim([0, 1]); ylim([0.15, 0.55]);