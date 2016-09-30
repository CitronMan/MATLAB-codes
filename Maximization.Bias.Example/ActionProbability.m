function p_list = ActionProbability(a_list, Q_list, Policy)
switch Policy.Name
    case 'EpsGreedy'
        p_list = ones(size(a_list)) * Policy.eps / length(a_list);
        a_opt = a_list(Q_list == max(Q_list));
        p_list(ismember(a_list, a_opt)) = p_list(ismember(a_list, a_opt)) + (1 - Policy.eps) / length(a_opt);
end