function a = FixedPolicy(s, Type)
switch Type
    case 'Random'
        a = randi(2);
    case 'Risky'
        [Sum, ~, ~] = StateFeature(s);
        if Sum < 20
            a = ActionIndex('hit');
        else
            a = ActionIndex('stick');
        end
end
end