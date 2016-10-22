function [s_history, a_history, r_history, Q, ModelObj] = DynaQ(MazeObj, Q, ModelObj, varargin)
gamma = 0.95;
epsilon = 0.1;
alpha = 0.7;
PlanNum = 0;
SwitchTime = Inf;
NewWall = [];
for i = 1:2:length(varargin)
    if ismember(varargin{i}, {'gamma', 'epsilon', 'alpha', 'PlanNum', 'SwitchTime', 'NewWall'})
        eval(sprintf('%s = varargin{i + 1};', varargin{i}));
    end
end

s = MazeObj.StateIndex(MazeObj.Start);
s_history = s; a_history = []; r_history = [];
while s > 0
    a_list = MazeObj.ValidActionList(s);
    Q_list = Q.ReadActionValueList(s, a_list);
    a = EpsGreedy(a_list, Q_list, epsilon);
    a_history = cat(2, a_history, a);
    
    [s_next, r] = MazeObj.OneStep(s, a);
    r_history = cat(2, r_history, r);
    ModelObj = ModelObj.UpdateModel(s, a, s_next, r);
    
    Q = Q.QLearning(s, a, s_next, MazeObj.ValidActionList(s_next), r, gamma, alpha);
    s = s_next;
    s_history = cat(2, s_history, s);
        
    for i = 1:PlanNum
        switch class(ModelObj)
            case 'DeterministicModel'
                [s_sim, a_sim, s_next_sim, r_sim] = ModelObj.RandomExperience;
            case 'ExploratoryModel'
                [s_sim, a_sim, s_next_sim, r_sim] = ModelObj.RandomExperience(@(s)MazeObj.ValidActionList(s));
        end
        Q = Q.QLearning(s_sim, a_sim, s_next_sim, MazeObj.ValidActionList(s_next_sim), r_sim, gamma, alpha);
    end
    
    if length(a_history) == SwitchTime
        MazeObj.Map = sparse(NewWall(:, 2), NewWall(:, 1), ones(size(NewWall, 1), 1), MazeObj.Height, MazeObj.Width);
    end
end
end