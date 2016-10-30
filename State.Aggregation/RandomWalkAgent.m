classdef RandomWalkAgent
    properties
        StateNum, LeftReward, RightReward
        StepSize
        V_true
    end
    
    methods
        function obj = RandomWalkAgent(StateNum, StepSize)
            obj.StateNum = StateNum;
            obj.StepSize = StepSize;
            obj.LeftReward = -1;
            obj.RightReward = 1;
            obj.V_true = obj.DPPrediction;
        end
        
        function a_list = ValidAction(obj, ~)
            a_list = [-obj.StepSize:-1, 1:obj.StepSize];
        end
        
        function [s_next, r] = OneStep(obj, s, a)
            s_next = s + a;
            if s_next < 1
                s_next = 0;
                r = obj.LeftReward;
                return;
            end
            if s_next > obj.StateNum
                s_next = 0;
                r = obj.RightReward;
                return;
            end
            r = 0;
        end
        
        function V = DPPrediction(obj)
            V = zeros(obj.StateNum + 2, 1);
            V(1) = obj.LeftReward; V(obj.StateNum + 2) = obj.RightReward;
            P = zeros(obj.StateNum + 2);
            for i = 1:(obj.StateNum + 2)
                if (i == 1) || (i == obj.StateNum + 2)
                    P(i, i) = 1;
                else
                    s = i - 1;
                    if s - obj.StepSize >= 1
                        P((i - obj.StepSize):(i - 1), i) = 1 / 2 / obj.StepSize;
                    else
                        P(2:(i - 1), i) = 1 / 2 / obj.StepSize;
                        P(1, i) = (obj.StepSize - s + 1) / obj.StepSize / 2;
                    end
                    if s + obj.StepSize <= obj.StateNum
                        P((i + 1):(i + obj.StepSize), i) = 1 / 2 / obj.StepSize;
                    else
                        P((i + 1):(obj.StateNum + 1), i) = 1 / 2 / obj.StepSize;
                        P(obj.StateNum + 2, i) = (s + obj.StepSize - obj.StateNum) / obj.StepSize / 2;
                    end
                end
            end
            
            max_dV = Inf;
            while max_dV > 1e-5
                V_new = P' * V;
                max_dV = max(abs(V_new - V));
                V = V_new;
            end
            V = V(2:(end - 1));
        end
    end
end