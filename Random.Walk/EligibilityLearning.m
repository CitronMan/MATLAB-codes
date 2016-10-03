function V = EligibilityLearning(s_history, r_history, gamma, V, E, lambda, alpha, Mode, TraceType)
T = length(r_history);
if strcmp(Mode, 'Offline')
    dV = zeros(size(V));
end
for t = 1:T
    if t < T
        delta = r_history(t) + gamma * V(s_history(t + 1)) - V(s_history(t));
    else
        delta = r_history(t) - V(s_history(t));
    end
    switch TraceType
        case 'Accumulating'
            E(s_history(t)) = E(s_history(t)) + 1;
        case 'Dutch'
            E(s_history(t)) = (1 - alpha) * E(s_history(t)) + 1;
        case 'Replacing'
            E(s_history(t)) = 1;
    end
    
    switch Mode
        case 'Online'
            V = V + alpha * delta * E;
        case 'Offline'
            dV = dV + alpha * delta * E;
    end
    E = gamma * lambda * E;
end
if strcmp(Mode, 'Offline')
    V = V + dV;
end
end