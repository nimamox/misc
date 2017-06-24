function [ probs ] = pvl(action_seq, reward_seq, alpha, lambda, A, c)
    E = ones(4,1)/4;
    probs = zeros(100, 4);
    actions = 'ABCD';
    for t=1:100
        if reward_seq(t) >= 0
            u = reward_seq(t) ^ alpha;
        else
            u = -lambda * (abs(reward_seq(t)) ^ alpha);
        end
        sel_act = strfind(actions, action_seq(t));
        for j=1:4
            if sel_act==j
                E(j) = A * E(j) + u;
            else
                E(j) = A * E(j);
            end
        end
        theta = 3 ^ c - 1;
        z = sum(exp(theta * E));
        probs(t,:) = exp(theta * E) / z;
    end
end

