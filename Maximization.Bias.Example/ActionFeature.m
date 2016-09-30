function Move = ActionFeature(Label, a)
switch Label
    case 'A'
        switch a
            case 1
                Move = 'Left';
            case 2
                Move = 'Right';
        end
    case 'B'
        Move = a;
end
end