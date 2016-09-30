function Q_dict = UpdateQValue(s, a, dQ, Q_dict)
Ind = find((Q_dict.s == s) & (Q_dict.a == a), 1);
if isempty(Ind)
    Q_dict.s = cat(1, Q_dict.s, s);
    Q_dict.a = cat(1, Q_dict.a, a);
    Q_dict.Val = cat(1, Q_dict.Val, Q_dict.Q0 + dQ);
    Q_dict.Count = cat(1, Q_dict.Count, 1);
else
    Q_dict.Val(Ind) = Q_dict.Val(Ind) + dQ;
    Q_dict.Count(Ind) = Q_dict.Count(Ind) + 1;
end
end