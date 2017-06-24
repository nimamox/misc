function [ rew ] = get_reward(s, a)
    global utility payoff;
    rew = sum((s - a) .* utility + a .* payoff);
end

