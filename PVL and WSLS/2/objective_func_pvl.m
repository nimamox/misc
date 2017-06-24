function [ score ] = objective_func_pvl(x, cost_act_seq, cost_reward_seq)
    if (x(1) <= 0) || (x(1) >= 1)
        score = inf;
        return
    end
    if (x(2) <= 0) || (x(2) >= 5)
        score = inf;
        return 
    end
    if (x(3) <= 0) || (x(3) >= 1)
        score = inf;
        return
    end
    if (x(4) <= 0) || (x(4) >= 5)
        score = inf;
        return
    end
    pvl_probs = pvl(cost_act_seq, cost_reward_seq, x(1), x(2), x(3), x(4));
    score = 0;
    actions = 'ABCD';
    for t=1:100
        score = score + log(pvl_probs(t, strfind(actions, cost_act_seq(t))));
    end
    score = -score;
end

