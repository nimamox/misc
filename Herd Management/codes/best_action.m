function [ a, v ] = best_action( state, V, gamma )
    a = [0 0 0];
    v = 0;
    acts = possible_actions(state);
    for i=1:size(acts, 1)
        sa = afterstate(state, acts(i,:));
        if sum(sa) < 0
            sa
        end
        rew = get_reward(state, acts(i,:));
        vn = calculate_state_value(sa, rew, V, gamma);
        if vn > v
            v = vn;
            a = acts(i,:);
        end
    end
end

