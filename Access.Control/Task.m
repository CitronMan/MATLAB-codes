classdef Task
    properties
        Reward_List, ServerNum, ExitRate
        gamma
    end
    
    methods
        function obj = Task(Reward_List, ServerNum, ExitRate)
            obj.Reward_List = Reward_List;
            obj.ServerNum = ServerNum;
            obj.ExitRate = ExitRate;
        end
        
        function [s_next, r] = OneStep(obj, s, a)
            [Priority, FreeServerNum] = obj.StateParam(s);
            switch a
                case 1
                    r = 0;
                case 2
                    FreeServerNum = FreeServerNum - 1;
                    r = obj.Reward_List(Priority);
            end
            Priority = randi(length(obj.Reward_List));
            FreeServerNum = FreeServerNum + ...
                sum(double(rand(1, obj.ServerNum - FreeServerNum) < obj.ExitRate));
            s_next = obj.StateIndex(Priority, FreeServerNum);
        end
        
        function [Priority, FreeServerNum] = StateParam(obj, s)
            [Priority, FreeServerNum] = ind2sub([length(obj.Reward_List), obj.ServerNum + 1], s);
            FreeServerNum = FreeServerNum - 1;
        end
        
        function s = StateIndex(obj, Priority, FreeServerNum)
            s = sub2ind([length(obj.Reward_List), obj.ServerNum + 1], Priority, FreeServerNum + 1);
        end
        
        function a_List = ValidActionList(obj, s)
            [~, FreeServerNum] = obj.StateParam(s);
            if FreeServerNum > 0
                a_List = [1, 2];
            else
                a_List = 1;
            end
        end
    end
end