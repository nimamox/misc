function [ V, iters ] = value_iteration( gamma, theta, sweeps )

global H states total_states cow_transition breed_prob utility payoff burn_offspring_prob;

V = containers.Map('KeyType', 'int32', 'ValueType', 'any');

for c=1:total_states
    inds = encode_base_13(states{c});
    V(inds) = 0;
end

burn_offspring_prob = remember_burn_offspring();

sweep = 0;
iters = 0;
while true
    iters = iters + 1;
    sweep = sweep + 1;
    delta = 0;
    for s=1:total_states
        s
        inds = encode_base_13(states{s});
        v = V(inds);
        [a, v] = best_action(states{s}, V, gamma);
        V(inds) = v;
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
end

