function [s_history, a_history, r_history] = OneEpisode(s0, Agent)
s_history = s0; a_history = []; r_history = [];

s = s0;
while s ~= 0
    a_list = Agent.ValidAction(s);
    a = a_list(randi(length(a_list)));
    a_history = cat(2, a_history, a);
    
    [s_next, r] = Agent.OneStep(s, a);
    r_history = cat(2, r_history, r);
    
    s = s_next;
    s_history = cat(2, s_history, s);
end
end