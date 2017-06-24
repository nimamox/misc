function [ lever ] = select_arm_eps_greedy(values, epsilon)
    if (rand > epsilon)
        [~, i] = max(values);
        lever = i;
    else
        lever = randi(size(values, 1));
    end
end

