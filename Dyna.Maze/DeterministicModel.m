classdef DeterministicModel
    properties
        s, a, s_next, r
    end
    
    methods
        function obj = UpdateModel(obj, s, a, s_next, r)
            Ind = find((obj.s == s) & (obj.a == a), 1, 'first');
            if ~isempty(Ind)
                obj.s_next(Ind) = s_next;
                obj.r(Ind) = r;
            else
                obj.s = cat(1, obj.s, s);
                obj.a = cat(1, obj.a, a);
                obj.s_next = cat(1, obj.s_next, s_next);
                obj.r = cat(1, obj.r, r);
            end
        end
        
        function [s, a, s_next, r] = RandomExperience(obj)
            Ind = randi(length(obj.s));
            s = obj.s(Ind);
            a = obj.a(Ind);
            s_next = obj.s_next(Ind);
            r = obj.r(Ind);
        end
    end
end