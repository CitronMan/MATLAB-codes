classdef SARSA
    properties
        Q_Dict, R_Base
        epsilon, alpha, beta
        T_Inf, T_DisplayGap
    end
    
    methods
        function obj = SARSA(varargin)
            obj.Q_Dict = struct('s', [], 'a', [], 'Val', [], 'Count', []);
            obj.R_Base = 0;
            obj.epsilon = 0.1;
            obj.alpha = 0.01;
            obj.beta = 0.01;
            obj.T_Inf = 2000000; obj.T_DisplayGap = 500000;
            for i = 1:2:length(varargin)
                switch varargin{i}
                    case 'epsilon'
                        obj.epsilon = varargin{i + 1};
                    case 'alpha'
                        obj.alpha = varargin{i + 1};
                    case 'beta'
                        obj.beta = varargin{i + 1};
                end
            end
        end
        
        function a = ChooseAction(obj, s, a_List, varargin)
            Th = obj.epsilon;
            if ~isempty(varargin)
                Th = varargin{1};
            end
            if rand < Th
                a = a_List(randi(length(a_List)));
            else
                Q_List = zeros(1, length(a_List));
                for a = a_List
                    Q_List(a_List == a) = obj.ActionValue(s, a);
                end
                a_opt = a_List(Q_List == max(Q_List));
                a = a_opt(randi(length(a_opt)));
            end
        end
        
        function Q = ActionValue(obj, s, a)
            Ind = find((obj.Q_Dict.s == s) & (obj.Q_Dict.a == a), 1, 'first');
            if ~isempty(Ind)
                Q = obj.Q_Dict.Val(Ind);
            else
                Q = 0;
            end
        end
        
        function [obj, s_history, a_history, r_history, T] = Learn(obj, TaskObj, s0)
            s = s0;
            a = obj.ChooseAction(s, TaskObj.ValidActionList(s));
            s_history = s; a_history = a; r_history = [];
            tStart = tic;
            while (s ~= 0) && (length(s_history) <= obj.T_Inf)
                [s_next, r] = TaskObj.OneStep(s, a);
                a_next = obj.ChooseAction(s_next, TaskObj.ValidActionList(s_next));
                if isempty(TaskObj.gamma)
                    delta = r - obj.R_Base + obj.ActionValue(s_next, a_next) - obj.ActionValue(s, a);
                    obj.R_Base = obj.R_Base + obj.beta * delta;
                else
                    delta = r + TaskObj.gamma * obj.ActionValue(s_next, a_next) - obj.ActionValue(s, a);
                end
                obj = obj.UpdateActionValue(s, a, obj.alpha * delta);
                s = s_next; a = a_next;
                s_history = cat(2, s_history, s); a_history = cat(2, a_history, a); r_history = cat(2, r_history, r);
                if mod(length(s_history), obj.T_DisplayGap) == 1
                    tElapse = toc(tStart);
                    fprintf('%d steps, %.1fs elapsed...\n', length(s_history) - 1, tElapse);
                end
            end
            T = length(s_history) - 1;
        end
        
        function obj = UpdateActionValue(obj, s, a, dQ)
            Ind = find((obj.Q_Dict.s == s) & (obj.Q_Dict.a == a), 1, 'first');
            if ~isempty(Ind)
                obj.Q_Dict.Val(Ind) = obj.Q_Dict.Val(Ind) + dQ;
                obj.Q_Dict.Count(Ind) = obj.Q_Dict.Count(Ind) + 1;
            else
                obj.Q_Dict.s = cat(1, obj.Q_Dict.s, s);
                obj.Q_Dict.a = cat(1, obj.Q_Dict.a, a);
                obj.Q_Dict.Val = cat(1, obj.Q_Dict.Val, dQ);
                obj.Q_Dict.Count = cat(1, obj.Q_Dict.Count, 1);
            end
        end
    end
end