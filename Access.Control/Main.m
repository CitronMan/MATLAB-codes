clear;
close all;

Reward_List = [1, 2, 4, 8];
ServerNum = 10;
ExitRate = 0.06;

TaskObj = Task(Reward_List, ServerNum, ExitRate);
TrainerObj = SARSA;

s0 = TaskObj.StateIndex(randi(length(Reward_List)), randi(ServerNum + 1) - 1);
[TrainerObj, s_history, a_history, r_history, T] = TrainerObj.Learn(TaskObj, s0);

Action_Table = zeros(length(Reward_List), ServerNum + 1);
for Priority = 1:length(Reward_List)
    for FreeServerNum = 0:ServerNum
        s = TaskObj.StateIndex(Priority, FreeServerNum);
        Action_Table(Priority, FreeServerNum + 1) = TrainerObj.ChooseAction(s, TaskObj.ValidActionList(s), 0);
    end
end

figure('Position', [300 200 500 200]);
imagesc([0, ServerNum], [1, length(Reward_List)], Action_Table); axis('equal');

figure('Position', [300 200 500 300]); hold on;
for Priority = 1:length(Reward_List)
    Q_List = zeros(1, ServerNum + 1);
    for FreeServerNum = 0:ServerNum
        Q_List(FreeServerNum + 1) = TrainerObj.ActionValue(TaskObj.StateIndex(Priority, FreeServerNum), Action_Table(Priority, FreeServerNum + 1));
    end
    plot(0:FreeServerNum, Q_List);
end
xlabel('Free Sever Number');
ylabel('Q(s,a^*)');