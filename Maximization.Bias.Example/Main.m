close all;
clear;
rng(0);

N = 10;
Problem = struct('N', N, 'Mean', -0.1 * ones(N, 1), 'STD', ones(N, 1), 'gamma', 1);
Policy = struct('Name', 'EpsGreedy', 'eps', 0.1);

Q_dict = struct('s', 0, 'a', 0, 'Val', 0, 'Count', 0, 'Q0', 0);
alpha = 0.1;
RunNum = 10000;
EpisodeNum = 300;

if ~exist('Simulated.Results.mat', 'file')
    for SimID = 1:4
        FirstMove_list = zeros(RunNum, EpisodeNum);
        tStart = tic;
        for Run = 1:RunNum
            switch SimID
                case 1
                    Agent = struct('LearningMethod', 'Q-learning', 'Q_dict', Q_dict, 'alpha', alpha);
                case 2
                    Agent = struct('LearningMethod', 'Double Q-learning', 'Q1_dict', Q_dict, 'Q2_dict', Q_dict, 'alpha', alpha);
                case 3
                    Agent = struct('LearningMethod', 'Expected SARSA', 'Q_dict', Q_dict, 'alpha', alpha);
                case 4
                    Agent = struct('LearningMethod', 'Double expected SARSA', 'Q1_dict', Q_dict, 'Q2_dict', Q_dict, 'alpha', alpha);
            end
            for Episode = 1:EpisodeNum
                [~, a_history, ~, Agent] = OneEpisode(StateIndex('A'), Problem, Policy, Agent);
                FirstMove_list(Run, Episode) = a_history(1);
            end
            if mod(Run, 100) == 0
                tElapse = toc(tStart);
                display(sprintf('%d/%d runs processed, elapsed time: %.1fs', Run, RunNum, tElapse));
            end
        end
        switch SimID
            case 1
                LeftProbability_Q = mean(double(FirstMove_list == 1), 1);
            case 2
                LeftProbability_2Q = mean(double(FirstMove_list == 1), 1);
            case 3
                LeftProbability_ES = mean(double(FirstMove_list == 1), 1);
            case 4
                LeftProbability_2ES = mean(double(FirstMove_list == 1), 1);
        end
    end
    save('Simulated.Results.mat', 'LeftProbability_Q', 'LeftProbability_2Q', 'LeftProbability_ES', 'LeftProbability_2ES');
else
    load('Simulated.Results.mat');
end

figure('Position', [300 200 600 400]); hold on;
plot(LeftProbability_Q, 'Color', 'r');
plot(LeftProbability_2Q, 'Color', 'g');
plot(LeftProbability_ES, 'Color', 'b');
plot(LeftProbability_2ES, 'Color', 'm');
plot(1:EpisodeNum, Policy.eps / 2 * ones(1, EpisodeNum), 'k--');
xlabel('Episode');
ylabel('% of left');
legend('Q-learning', 'Double Q-learning', 'Expected SARSA', 'Double expected SARSA', 'Location', 'NorthEast');
set(gca, 'FontSize', 15);