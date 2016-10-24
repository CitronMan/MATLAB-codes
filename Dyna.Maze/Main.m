close all;
clear;
SimNum = 100;

display('Simulating Figure 8.2...');
if ~exist('PlanningComparison.mat', 'file')
    Height = 6; Width = 9;
    Wall = [3, 3; 3, 4; 3, 5; 6, 2; 8, 4; 8, 5; 8, 6];
    Start = [1; 4]; Goal = [9; 6]; FinalReward = 1;
    MazeObj = Maze(Height, Width, Wall, Start, Goal, FinalReward);
    
    alpha = 0.1;
    PlanNum_list = [0, 5, 50];
    EpisodeNum = 50;
    StepNum = zeros(length(PlanNum_list), SimNum, EpisodeNum);
    for PlanNum = PlanNum_list
        display(sprintf('Dyna-Q with %d planning steps...', PlanNum));
        tStart = tic;
        for SimID = 1:SimNum
            Q = ActionValueSet; ModelObj = DeterministicModel;
            for EpisodeID = 1:EpisodeNum
                [~, a_history, ~, Q, ModelObj] = DynaQ(MazeObj, Q, ModelObj, 'PlanNum', PlanNum, 'alpha', alpha);
                StepNum(PlanNum_list == PlanNum, SimID, EpisodeID) = length(a_history);
            end
            if mod(SimID, 10) == 0
                tElapse = toc(tStart);
                display(sprintf('%d/%d processed, elapsed time: %.2fs', SimID, SimNum, tElapse));
            end
        end
    end
    save('PlanningComparison.mat', 'StepNum');
else
    load('PlanningComparison.mat');
    display('Previous result loaded.');
end

figure('Position', [300 200 500 400]);
plot(squeeze(mean(StepNum, 2))');
ylim([0, 800]);
xlabel('Episode');
ylabel('Step number');
title('Dyna-Q');
legend('0', '5', '50');
set(gca, 'FontSize', 15);

display('Simulating Exercise 8.1...');
if ~exist('nStepQ.mat', 'file')
    Height = 6; Width = 9;
    Wall = [3, 3; 3, 4; 3, 5; 6, 2; 8, 4; 8, 5; 8, 6];
    Start = [1; 4]; Goal = [9; 6]; FinalReward = 1;
    MazeObj = Maze(Height, Width, Wall, Start, Goal, FinalReward);
    
    alpha = 0.1;
    nStep_list = [1, 5, 50];
    EpisodeNum = 50;
    StepNum = zeros(length(nStep_list), SimNum, EpisodeNum);
    for nStep = nStep_list
        display(sprintf('Dyna-Q with %d-step bootstrapping...', nStep));
        tStart = tic;
        for SimID = 1:SimNum
            Q = ActionValueSet; ModelObj = DeterministicModel;
            for EpisodeID = 1:EpisodeNum
                [~, a_history, ~, Q, ModelObj] = DynaQ(MazeObj, Q, ModelObj, 'nStep', nStep, 'alpha', alpha);
                StepNum(nStep_list == nStep, SimID, EpisodeID) = length(a_history);
            end
            if mod(SimID, 10) == 0
                tElapse = toc(tStart);
                display(sprintf('%d/%d processed, elapsed time: %.2fs', SimID, SimNum, tElapse));
            end
        end
    end
    save('nStepQ.mat', 'StepNum');
else
    load('nStepQ.mat');
    display('Previous result loaded.');
end

figure('Position', [300 200 500 400]);
plot(squeeze(mean(StepNum, 2))');
ylim([0, 800]);
xlabel('Episode');
ylabel('Step number');
title('n-step Q');
legend('1', '5', '50');
set(gca, 'FontSize', 15);

display('Simulating Figure 8.5...');
if ~exist('BlockingMaze.mat', 'file')
    Height = 6; Width = 9;
    OldWall = [1, 3; 2, 3; 3, 3; 4, 3; 5, 3; 6, 3; 7, 3; 8, 3];
    NewWall = [2, 3; 3, 3; 4, 3; 5, 3; 6, 3; 7, 3; 8, 3; 9, 3];
    Start = [4; 1]; Goal = [9; 6]; FinalReward = 1;
    TotalDuration = 3000; SwitchTime = 1000;
    
    PlanNum = 50; kappa = 1e-4;
    r = zeros(2, SimNum, TotalDuration);
    for MethodID = 1:2
        switch MethodID
            case 1
                display('Simulating Dyna-Q...');
            case 2
                display('Simulating Dyna-Q+...');
        end
        tStart = tic;
        for SimID = 1:SimNum
            Q = ActionValueSet;
            switch MethodID
                case 1
                    ModelObj = DeterministicModel;
                case 2
                    ModelObj = ExploratoryModel(kappa);
            end
            MazeObj = Maze(Height, Width, OldWall, Start, Goal, FinalReward);
            T = 0; SwitchFlag = false;
            while T < TotalDuration
                [~, a_history, ~, Q, ModelObj] = DynaQ(MazeObj, Q, ModelObj, 'PlanNum', PlanNum, 'SwitchTime', SwitchTime - T, 'NewWall', NewWall);
                T = T + length(a_history);
                if ~SwitchFlag && (T >= SwitchTime)
                    MazeObj.Map = sparse(NewWall(:, 2), NewWall(:, 1), ones(size(NewWall, 1), 1), MazeObj.Height, MazeObj.Width);
                    SwitchFlag = true;
                end
                if T <= TotalDuration
                    r(MethodID, SimID, T) = 1;
                end
            end
            if mod(SimID, 10) == 0
                tElapse = toc(tStart);
                display(sprintf('%d/%d processed, elapsed time: %.2fs', SimID, SimNum, tElapse));
            end
        end
    end
    save('BlockingMaze.mat', 'r');
else
    load('BlockingMaze.mat');
    display('Previous result loaded.');
end

figure('Position', [300 200 500 400]);
plot(cumsum(squeeze(mean(r, 2)), 2)');
xlabel('Time steps');
ylabel('Cumulative reward');
title('Blocking Maze');
legend('Dyna-Q', 'Dyna-Q+');
set(gca, 'FontSize', 15);

display('Simulating Figure 8.6...');
if ~exist('ShortcutMaze.mat', 'file')
    Height = 6; Width = 9;
    OldWall = [2, 3; 3, 3; 4, 3; 5, 3; 6, 3; 7, 3; 8, 3; 9, 3];
    NewWall = [2, 3; 3, 3; 4, 3; 5, 3; 6, 3; 7, 3; 8, 3];
    Start = [4; 1]; Goal = [9; 6]; FinalReward = 1;
    TotalDuration = 6000; SwitchTime = 3000;
    
    PlanNum = 50; kappa = 1e-3;
    r = zeros(2, SimNum, TotalDuration);
    for MethodID = 1:2
        switch MethodID
            case 1
                display('Simulating Dyna-Q...');
            case 2
                display('Simulating Dyna-Q+...');
        end
        tStart = tic;
        for SimID = 1:SimNum
            Q = ActionValueSet;
            switch MethodID
                case 1
                    ModelObj = DeterministicModel;
                case 2
                    ModelObj = ExploratoryModel(kappa);
            end
            MazeObj = Maze(Height, Width, OldWall, Start, Goal, FinalReward);
            T = 0; SwitchFlag = false;
            while T < TotalDuration
                [~, a_history, ~, Q, ModelObj] = DynaQ(MazeObj, Q, ModelObj, 'PlanNum', PlanNum, 'SwitchTime', SwitchTime - T, 'NewWall', NewWall);
                T = T + length(a_history);
                if ~SwitchFlag && (T >= SwitchTime)
                    MazeObj.Map = sparse(NewWall(:, 2), NewWall(:, 1), ones(size(NewWall, 1), 1), MazeObj.Height, MazeObj.Width);
                    SwitchFlag = true;
                end
                if T <= TotalDuration
                    r(MethodID, SimID, T) = 1;
                end
            end
            if mod(SimID, 10) == 0
                tElapse = toc(tStart);
                display(sprintf('%d/%d processed, elapsed time: %.2fs', SimID, SimNum, tElapse));
            end
        end
    end
    save('ShortcutMaze.mat', 'r');
else
    load('ShortcutMaze.mat');
    display('Previous result loaded.');
end

figure('Position', [300 200 500 400]);
plot(cumsum(squeeze(mean(r, 2)), 2)');
xlabel('Time steps');
ylabel('Cumulative reward');
title('Shortcut Maze');
legend('Dyna-Q', 'Dyna-Q+');
set(gca, 'FontSize', 15);

display('Simulating Exercise 8.4...');
if ~exist('ShortcutMaze2.mat', 'file')
    Height = 6; Width = 9;
    OldWall = [2, 3; 3, 3; 4, 3; 5, 3; 6, 3; 7, 3; 8, 3; 9, 3];
    NewWall = [2, 3; 3, 3; 4, 3; 5, 3; 6, 3; 7, 3; 8, 3];
    Start = [4; 1]; Goal = [9; 6]; FinalReward = 1;
    TotalDuration = 6000; SwitchTime = 3000;
    
    PlanNum = 50; kappa = 0;
    r = zeros(2, SimNum, TotalDuration);
    for MethodID = 1:2
        switch MethodID
            case 1
                display('Simulating Dyna-Q...');
            case 2
                display('Simulating Dyna-Q+...');
        end
        tStart = tic;
        for SimID = 1:SimNum
            Q = ActionValueSet;
            switch MethodID
                case 1
                    ModelObj = DeterministicModel;
                case 2
                    ModelObj = ExploratoryModel(kappa);
            end
            MazeObj = Maze(Height, Width, OldWall, Start, Goal, FinalReward);
            T = 0; SwitchFlag = false;
            while T < TotalDuration
                [~, a_history, ~, Q, ModelObj] = DynaQ(MazeObj, Q, ModelObj, 'PlanNum', PlanNum, 'SwitchTime', SwitchTime - T, 'NewWall', NewWall);
                T = T + length(a_history);
                if ~SwitchFlag && (T >= SwitchTime)
                    MazeObj.Map = sparse(NewWall(:, 2), NewWall(:, 1), ones(size(NewWall, 1), 1), MazeObj.Height, MazeObj.Width);
                    SwitchFlag = true;
                end
                if T <= TotalDuration
                    r(MethodID, SimID, T) = 1;
                end
            end
            if mod(SimID, 10) == 0
                tElapse = toc(tStart);
                display(sprintf('%d/%d processed, elapsed time: %.2fs', SimID, SimNum, tElapse));
            end
        end
    end
    save('ShortcutMaze2.mat', 'r');
else
    load('ShortcutMaze2.mat');
    display('Previous result loaded.');
end

figure('Position', [300 200 500 400]);
plot(cumsum(squeeze(mean(r, 2)), 2)');
xlabel('Time steps');
ylabel('Cumulative reward');
title('Shortcut Maze');
legend('Dyna-Q', 'Exploring action');
set(gca, 'FontSize', 15);