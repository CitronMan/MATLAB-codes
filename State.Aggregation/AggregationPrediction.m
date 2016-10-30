classdef AggregationPrediction
    properties
        GroupSize, GroupNum, Param
        alpha
    end
    
    methods
        function obj = AggregationPrediction(GroupSize, GroupNum, alpha)
            obj.GroupSize = GroupSize;
            obj.GroupNum = GroupNum;
            obj.Param = zeros(GroupNum, 1);
            obj.alpha = alpha;
        end
        
        function V = StateValue(obj, s)
            if s == 0
                V = 0;
            else
                V = obj.Param(ceil(s / obj.GroupSize));
            end
        end
        
        function obj = Update(obj, s, U)
            delta = obj.alpha * (U - obj.StateValue(s));
            obj.Param(ceil(s / obj.GroupSize)) = obj.Param(ceil(s / obj.GroupSize)) + delta;
        end
    end
end