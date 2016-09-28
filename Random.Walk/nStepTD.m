function V = nStepTD(s_history, r_history, gamma, V, n, alpha, Mode)
T = length(r_history);

R_n = nStepReward(r_history, gamma, min([n, T]));
if n < Inf
    gamma_n = gamma^n;
else
    if gamma == 1
        gamma_n = 1;
    else
        gamma_n = 0;
    end
end
if strcmp(Mode, 'Offline')
    dV = zeros(size(V));
end
for t = 1:T
    if t + n <= T
        G = R_n(t) + V(s_history(t + n)) * gamma_n;
    else
        G = R_n(t);
    end
    switch Mode
        case 'Online'
            V(s_history(t)) = V(s_history(t)) + alpha * (G - V(s_history(t)));
        case 'Offline'
            dV(s_history(t)) = dV(s_history(t)) + alpha * (G - V(s_history(t)));
    end
end
if strcmp(Mode, 'Offline')
    V = V + dV;
end
end