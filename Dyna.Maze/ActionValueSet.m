classdef ActionValueSet
    properties
        s, a, Q
        Q_default
    end
    
    methods
        function obj = ActionValueSet
            obj.s = 0;
            obj.a = 0;
            obj.Q = 0;
            obj.Q_default = 0;
        end
        
        function obj = QLearning(obj, s_history, a_history, r_history, a_list_handle, gamma, alpha, nStep, epsilon)
            rho = 1;
            for i = 2:min([nStep, length(s_history) - 1])
                Q_list = obj.ReadActionValueList(s_history(i), a_list_handle(s_history(i)));
                rho = rho * EpsGreedyProb(a_history(i), a_list_handle(s_history(i)), Q_list, 0) ...
                    / EpsGreedyProb(a_history(i), a_list_handle(s_history(i)), Q_list, epsilon);
            end
            G = 0;
            for i = 1:min([nStep, length(s_history) - 1])
                G = G + gamma^(i - 1) * r_history(i);
            end
            if nStep < length(s_history)
                G = G + gamma^nStep * max(obj.ReadActionValueList(s_history(nStep + 1), a_list_handle(s_history(nStep + 1))));
            end
            dQ = alpha * rho * (G - obj.ReadActionValue(s_history(1), a_history(1)));
            obj = obj.UpdateActionValue(s_history(1), a_history(1), dQ);
        end
        
        function Val = ReadActionValue(obj, s, a)
            Ind = find((obj.s == s) & (obj.a == a), 1, 'first');
            if ~isempty(Ind)
                Val = obj.Q(Ind);
            else
                Val = obj.Q_default;
            end
        end
        
        function Q_list = ReadActionValueList(obj, s, a_list)
            Q_list = zeros(size(a_list));
            for a_current = a_list
                Q_list(a_list == a_current) = obj.ReadActionValue(s, a_current);
            end
        end
        
        function obj = UpdateActionValue(obj, s, a, dQ)
            if dQ ~= 0
                Ind = find((obj.s == s) & (obj.a == a), 1, 'first');
                if ~isempty(Ind)
                    if (obj.Q(Ind) + dQ ~= obj.Q_default)
                        obj.Q(Ind) = obj.Q(Ind) + dQ;
                    else
                        obj.s = [obj.s(1:(Ind - 1)); obj.s((Ind + 1):end)];
                        obj.a = [obj.a(1:(Ind - 1)); obj.a((Ind + 1):end)];
                        obj.Q = [obj.Q(1:(Ind - 1)); obj.Q((Ind + 1):end)];
                    end
                else
                    obj.s = cat(1, obj.s, s);
                    obj.a = cat(1, obj.a, a);
                    obj.Q = cat(1, obj.Q, obj.Q_default + dQ);
                end
            end
        end
    end
end