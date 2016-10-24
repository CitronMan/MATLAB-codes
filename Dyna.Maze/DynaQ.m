function [s_history, a_history, r_history, Q, ModelObj] = DynaQ(MazeObj, Q, ModelObj, varargin)
gamma = 0.95;
epsilon = 0.1;
alpha = 0.7;
nStep = 1;
PlanNum = 0;
SwitchTime = Inf;
NewWall = [];
for i = 1:2:length(varargin)
    if ismember(varargin{i}, {'gamma', 'epsilon', 'alpha', 'nStep', 'PlanNum', 'SwitchTime', 'NewWall'})
        eval(sprintf('%s = varargin{i + 1};', varargin{i}));
    end
end

s0 = MazeObj.StateIndex(MazeObj.Start);
a_list = MazeObj.ValidActionList(s0);
Q_list = Q.ReadActionValueList(s0, a_list);
a0 = EpsGreedy(a_list, Q_list, epsilon);

s_history = s0; a_history = a0; r_history = [];
T = Inf; t = 0;
while true
    if t < T
        s = s_history(t + 1);
        a = a_history(t + 1);
        [s_next, r] = MazeObj.OneStep(s, a);
        s_history = cat(2, s_history, s_next);
        r_history = cat(2, r_history, r);
        if s_next == 0
            T = t + 1;
        else
            a_list = MazeObj.ValidActionList(s_next);
            Q_list = Q.ReadActionValueList(s_next, a_list);
            a = EpsGreedy(a_list, Q_list, epsilon);
            a_history = cat(2, a_history, a);
        end
    end
    
    tau = t - nStep + 1;
    if tau >= 0
        Q = Q.QLearning(s_history((tau:min([tau + nStep, T])) + 1), a_history((tau:min([tau + nStep - 1, T - 1])) + 1), ...
            r_history((tau:min([tau + nStep - 1, T - 1])) + 1), @(s)MazeObj.ValidActionList(s), gamma, alpha, nStep, epsilon);
    end
    
    for i = 1:PlanNum
        switch class(ModelObj)
            case 'DeterministicModel'
                [s_sim, a_sim, s_next_sim, r_sim] = ModelObj.RandomExperience;
            case 'ExploratoryModel'
                [s_sim, a_sim, s_next_sim, r_sim] = ModelObj.RandomExperience(@(s)MazeObj.ValidActionList(s));
        end
        Q = Q.QLearning([s_sim, s_next_sim], a_sim, r_sim, @(s)MazeObj.ValidActionList(s), gamma, alpha, 1, epsilon);
    end
    
    if length(a_history) == SwitchTime
        MazeObj.Map = sparse(NewWall(:, 2), NewWall(:, 1), ones(size(NewWall, 1), 1), MazeObj.Height, MazeObj.Width);
    end
    
    if tau == T - 1
        break;
    end
    t = t + 1;
end
end