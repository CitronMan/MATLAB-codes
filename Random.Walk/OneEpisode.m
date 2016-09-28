function [s_history, a_history, r_history] = OneEpisode(s, N, varargin)
r_left = -1; r_right = 1;
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'r_left'
            r_left = varargin{i + 1};
        case 'r_right'
            r_right = varargin{i + 1};
    end
end

s_history = s;
a_history = [];
r_history = [];
while (s >= 1) && (s <= N)
    a = randi(2) * 2 - 3;
    s = s + a;
    switch s
        case N + 1
            r = r_right;
        case 0
            r = r_left;
        otherwise
            r = 0;
    end
    s_history = cat(1, s_history, s);
    a_history = cat(1, a_history, a);
    r_history = cat(1, r_history, r);
end
end