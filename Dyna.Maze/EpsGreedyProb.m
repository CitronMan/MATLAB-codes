function P = EpsGreedyProb(a, a_list, Q_list, epsilon)
a_opt = a_list(Q_list == max(Q_list));
if ismember(a, a_opt)
    P = epsilon / length(a_list) + (1 - epsilon) / length(a_opt);
else
    P = epsilon / length(a_list);
end
end