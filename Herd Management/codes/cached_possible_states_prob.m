function [ out ] = cached_possible_states_prob( state )
    global cache_possible_states_prob;
    coded_state = encode_base_13(state);
    if cache_possible_states_prob.isKey(coded_state)
        out = cache_possible_states_prob(coded_state);
    else
        out = possible_states_prob( state );
        cache_possible_states_prob(coded_state) = out;
    end
    
end

