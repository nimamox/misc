function [ V, pi, iters ] = policy_iteration(gamma, theta, sweeps)

global H states total_states cow_transition breed_prob utility payoff burn_offspring_prob;

V = containers.Map('KeyType', 'int32', 'ValueType', 'any');
pi = containers.Map('KeyType', 'int32', 'ValueType', 'any');
for c=1:total_states
    inds = encode_base_13(states{c});
    V(inds) = 0;
    pi(inds) = [0 0 0];
end

burn_offspring_prob = remember_burn_offspring();

iters = 0;
policy_stable = false;
while ~policy_stable
    iters = iters + 1;
    % Policy evaluation
    sweep = 0;
    while true
        sweep = sweep + 1;
        delta = 0;
        for s=1:total_states
            inds = encode_base_13(states{s});
            v = V(inds);
            sa = afterstate(states{s}, pi(inds));
            rew = get_reward(states{s}, pi(inds));
            V(inds) = calculate_state_value(sa, rew, V, gamma);
            delta = max(delta, abs(v - V(inds)));
        end
        sweep
        delta
        if theta > delta
            break
        end
        if sweeps > 0 && sweep == sweeps
            break
        end
    end
    %Policy Improvement
    policy_stable = true;
    for s=1:total_states
        inds = encode_base_13(states{s});
        b = pi(inds);
        [a, v] = best_action(states{s}, V, gamma);
        pi(inds) = a;
        if b ~= pi(inds)
            policy_stable = false;
        end
    end

end
end
