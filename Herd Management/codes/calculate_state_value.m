function [ v ] = calculate_state_value( s, r, V, gamma )
    v = 0;
    %states_probs = possible_states_prob(s);
    states_probs = cached_possible_states_prob(s);
    for q=1:size(states_probs, 1)
        v = v + states_probs(q, 2) * (r + gamma * V(states_probs(q, 1)));
    end
end

