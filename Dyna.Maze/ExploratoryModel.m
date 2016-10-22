classdef ExploratoryModel < DeterministicModel
    properties
        t, kappa, time
    end
    
    methods
        function obj = ExploratoryModel(kappa)
            obj.kappa = kappa;
            obj.time = 0;
        end
        
        function obj = UpdateModel(obj, s, a, s_next, r)
            obj = UpdateModel@DeterministicModel(obj, s, a, s_next, r);
            obj.time = obj.time + 1;
            
            Ind = find((obj.s == s) & (obj.a == a), 1, 'first');
            if Ind <= length(obj.t)
                obj.t(Ind) = obj.time;
            else
                obj.t = cat(1, obj.t, obj.time);
            end
        end
        
        function [s, a, s_next, r] = RandomExperience(obj, a_list_handle)
            s = obj.s(randi(length(obj.s)));
            a_list = a_list_handle(s);
            a = a_list(randi(length(a_list)));
            
            Ind = find((obj.s == s) & (obj.a == a), 1, 'first');
            if ~isempty(Ind)
                s_next = obj.s_next(Ind);
                r = obj.r(Ind) + obj.kappa * (obj.time - obj.t(Ind))^0.5;
            else
                s_next = s;
                r = obj.kappa * (obj.time - 1)^0.5;
            end
        end
    end
end