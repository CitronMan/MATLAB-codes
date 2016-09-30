function [s_history, a_history, r_history, Agent] = OneEpisode(s0, Problem, Policy, Agent)
s = s0;
s_history = s0; a_history = zeros([0, 1]); r_history = zeros([0, 1]);
while s ~= 0
    a_list = ValidActionList(s, Problem);
    Q_list = zeros(size(a_list));
    switch Agent.LearningMethod
        case {'Q-learning', 'Expected SARSA'}
            for a = a_list
                Q_list(a_list == a) = ExtractQValue(s, a, Agent.Q_dict);
            end
        case {'Double Q-learning', 'Double expected SARSA'}
            Q1_list = zeros(size(Q_list));
            Q2_list = zeros(size(Q_list));
            for a = a_list
                Q1_list(a_list == a) = ExtractQValue(s, a, Agent.Q1_dict);
                Q2_list(a_list == a) = ExtractQValue(s, a, Agent.Q2_dict);
            end
            Q_list = 0.5 * (Q1_list + Q2_list);
    end
    a = ChooseAction(a_list, Q_list, Policy);
    a_history = cat(1, a_history, a);
    
    
    [s_next, r] = OneStep(s, a, Problem);
    r_history = cat(1, r_history, r);
    
    switch Agent.LearningMethod
        case 'Q-learning'
            a_next_list = ValidActionList(s_next, Problem);
            Q_next_list = zeros(size(a_next_list));
            for a_next = a_next_list
                Q_next_list(a_next_list == a_next) = ExtractQValue(s_next, a_next, Agent.Q_dict);
            end
            delta = r + max(Q_next_list) * Problem.gamma - ExtractQValue(s, a, Agent.Q_dict);
            Agent.Q_dict = UpdateQValue(s, a, Agent.alpha * delta, Agent.Q_dict);
        case 'Double Q-learning'
            a_next_list = ValidActionList(s_next, Problem);
            Q_next_list = zeros(size(a_next_list));
            UpdateDict = randi(2);
            for a_next = a_next_list
                switch UpdateDict
                    case 1
                        Q_next_list(a_next_list == a_next) = ExtractQValue(s_next, a_next, Agent.Q1_dict);
                    case 2
                        Q_next_list(a_next_list == a_next) = ExtractQValue(s_next, a_next, Agent.Q2_dict);
                end
            end
            a_max = ChooseAction(a_next_list, Q_next_list, struct('Name', 'EpsGreedy', 'eps', 0));
            switch UpdateDict
                case 1
                    delta = r + ExtractQValue(s_next, a_max, Agent.Q2_dict) * Problem.gamma - ExtractQValue(s, a, Agent.Q1_dict);
                    Agent.Q1_dict = UpdateQValue(s, a, Agent.alpha * delta, Agent.Q1_dict);
                case 2
                    delta = r + ExtractQValue(s_next, a_max, Agent.Q1_dict) * Problem.gamma - ExtractQValue(s, a, Agent.Q2_dict);
                    Agent.Q2_dict = UpdateQValue(s, a, Agent.alpha * delta, Agent.Q2_dict);
            end
        case 'Expected SARSA'
            a_next_list = ValidActionList(s_next, Problem);
            Q_next_list = zeros(size(a_next_list));
            for a_next = a_next_list
                Q_next_list(a_next_list == a_next) = ExtractQValue(s_next, a_next, Agent.Q_dict);
            end
            p_next_list = ActionProbability(a_next_list, Q_next_list, Policy);
            delta = r + sum(Q_next_list .* p_next_list) * Problem.gamma - ExtractQValue(s, a, Agent.Q_dict);
            Agent.Q_dict = UpdateQValue(s, a, Agent.alpha * delta, Agent.Q_dict);
        case 'Double expected SARSA'
            a_next_list = ValidActionList(s_next, Problem);
            Q1_next_list = zeros(size(a_next_list));
            Q2_next_list = zeros(size(a_next_list));
            for a_next = a_next_list
                Q1_next_list(a_next_list == a_next) = ExtractQValue(s_next, a_next, Agent.Q1_dict);
                Q2_next_list(a_next_list == a_next) = ExtractQValue(s_next, a_next, Agent.Q2_dict);
            end
            UpdateDict = randi(2);
            switch UpdateDict
                case 1
                    p_next_list = ActionProbability(a_next_list, Q1_next_list, Policy);
                    delta = r + sum(Q2_next_list .* p_next_list) * Problem.gamma - ExtractQValue(s, a, Agent.Q1_dict);
                    Agent.Q1_dict = UpdateQValue(s, a, Agent.alpha * delta, Agent.Q1_dict);
                case 2
                    p_next_list = ActionProbability(a_next_list, Q2_next_list, Policy);
                    delta = r + sum(Q1_next_list .* p_next_list) * Problem.gamma - ExtractQValue(s, a, Agent.Q2_dict);
                    Agent.Q2_dict = UpdateQValue(s, a, Agent.alpha * delta, Agent.Q2_dict);
            end
    end
    
    s = s_next;
    s_history = cat(1, s_history, s);
end
end