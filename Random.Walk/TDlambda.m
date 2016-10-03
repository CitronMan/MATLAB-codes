function V = TDlambda(s_history, r_history, gamma, V, lambda, alpha, Mode)
T = length(r_history);
R_n = zeros(T, T);
for n = 1:T
    R_n(:, n) = nStepReward(r_history, gamma, n);
end
if strcmp(Mode, 'Offline')
    dV = zeros(size(V));
end
lambda_list = [(1 - lambda) * lambda.^(0:(T - 2)), lambda^(T - 1)];
for t = 1:T
    G_n = R_n(t, 1:(T - t + 1));
    G_n(1:(T - t)) = G_n(1:(T - t)) + V(s_history((t + 1):T)) .* (gamma.^(1:(T - t)));
    G_lambda = sum(G_n(1:(T - t)) .* lambda_list(1:(T - t))) + G_n(end) * sum(lambda_list((T - t + 1):end));
    switch Mode
        case 'Online'
            V(s_history(t)) = V(s_history(t)) + alpha * (G_lambda - V(s_history(t)));
        case 'Offline'
            dV(s_history(t)) = dV(s_history(t)) + alpha * (G_lambda - V(s_history(t)));
    end
end
if strcmp(Mode, 'Offline')
    V = V + dV;
end
end