function [s, r] = OneStep(s, a, Problem)
Label = StateFeature(s);
switch Label
    case 'A'
        Move = ActionFeature(Label, a);
        switch Move
            case 'Left'
                s = StateIndex('B');
                r = 0;
            case 'Right'
                s = 0;
                r = 0;
        end
    case 'B'
        Choice = ActionFeature(Label, a);
        s = 0;
        r = Problem.Mean(Choice) + randn * Problem.STD(Choice);
end
end