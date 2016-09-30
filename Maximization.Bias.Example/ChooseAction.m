function a = ChooseAction(a_list, Q_list, Policy)
switch Policy.Name
    case 'EpsGreedy'
        if rand < Policy.eps
            a = a_list(randi(length(a_list)));
        else
            a_opt = a_list(Q_list == max(Q_list));
            a = a_opt(randi(length(a_opt)));
        end
end
end