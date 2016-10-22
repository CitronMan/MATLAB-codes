classdef Maze
    properties
        Height, Width, Map
        Start, Goal, FinalReward
    end
    
    methods
        function obj = Maze(Height, Width, Wall, Start, Goal, FinalReward)
            obj.Height = Height;
            obj.Width = Width;
            obj.Start = Start(:);
            obj.Goal = Goal(:);
            obj.FinalReward = FinalReward;
            
            obj.Map = sparse(Wall(:, 2), Wall(:, 1), ones(size(Wall, 1), 1), Height, Width);
        end
        
        function Move = ActionFeature(~, a)
            if ~isrow(a)
                error('Invalid action index format.');
            end
            Move = zeros(2, length(a));
            for i = 1:4
                Ind = find(a == i);
                switch i
                    case 1
                        Move(:, Ind) = repmat([0; 1], [1, length(Ind)]);
                    case 2
                        Move(:, Ind) = repmat([0; -1], [1, length(Ind)]);
                    case 3
                        Move(:, Ind) = repmat([-1; 0], [1, length(Ind)]);
                    case 4
                        Move(:, Ind) = repmat([1; 0], [1, length(Ind)]);
                end
            end
        end
        
        function [s_next, r] = OneStep(obj, s, a)
            Pos = obj.StateFeature(s);
            Move = obj.ActionFeature(a);
            
            Pos_new = Pos + Move;
            if (Pos_new(1) < 1) || (Pos_new(1) > obj.Width) || (Pos_new(2) < 1) || (Pos_new(2) > obj.Height) ...
                    || (obj.Map(Pos_new(2), Pos_new(1)) == 1)
                Pos_new = Pos;
            end
            s_next = obj.StateIndex(Pos_new);
            if s_next == 0
                r = obj.FinalReward;
            else
                r = 0;
            end
        end
        
        function Pos = StateFeature(obj, s)
            if ~isrow(s)
                error('Invalid state index format.');
            end
            [y, x] = ind2sub([obj.Height, obj.Width], s);
            Pos = [x; y];
        end
        
        function s = StateIndex(obj, Pos)
            if ~ismatrix(Pos) || (size(Pos, 1) ~= 2)
                error('Invalid position format.');
            end
            x = Pos(1, :); y = Pos(2, :);
            s = sub2ind([obj.Height, obj.Width], y, x);
            s((Pos(1, :) == obj.Goal(1)) & (Pos(2, :) == obj.Goal(2))) = 0;
        end
        
        function a_list = ValidActionList(~, s)
            if s ~= 0
                a_list = 1:4;
            else
                a_list = 0;
            end
        end
    end
end