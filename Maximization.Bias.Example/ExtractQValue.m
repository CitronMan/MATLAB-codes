function Q = ExtractQValue(s, a, Q_dict)
Ind = find((Q_dict.s == s) & (Q_dict.a == a), 1);
if isempty(Ind)
    Q = Q_dict.Q0;
else
    Q = Q_dict.Val(Ind);
end
end