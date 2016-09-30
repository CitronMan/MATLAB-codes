function a_list = ValidActionList(s, Problem)
if s == 0
    a_list = 0;
else
    Label = StateFeature(s);
    switch Label
        case 'A'
            a_list = 1:2;
        case 'B'
            a_list = 1:Problem.N;
    end
end
end