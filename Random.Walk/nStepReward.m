function R_n = nStepReward(r, gamma, n)
if ~isvector(r)
    error('Reward history should be a vector.');
else
    if iscolumn(r)
        Type = 'Column';
        r = r';
    else
        Type = 'Row';
    end
end

R_n = conv(r, gamma.^((n - 1):-1:0));
R_n = R_n(n:end);
if strcmp(Type, 'Column')
    R_n = R_n';
end
end