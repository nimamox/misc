function [ score ] = objective_func_wsls(x, cost_act_seq, cost_reward_seq)
    if (x(1) <= 0) || (x(1) >= 1)
        score = inf;
        return
    end
    if (x(2) <= 0) || (x(2) >= 1)
        score = inf;
        return 
    end
    wsls_probs = wsls(cost_act_seq, cost_reward_seq, x(1), x(2));
    score = 0;
    actions = 'ABCD';
    for t=1:100
        score = score + log(wsls_probs(t, strfind(actions, cost_act_seq(t))));
    end
    score = -score;
end

