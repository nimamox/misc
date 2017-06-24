function [ probs ] = wsls(action_seq, reward_seq, p_stay_win, p_shift_loss)
    probs = zeros(100, 4);
    actions = 'ABCD';
    r_t_1 = -50;
    act_t_1 = 1;
    for t=1:100
        if r_t_1>=0
            for j=1:4
                if act_t_1==j
                    probs(t, j) = p_stay_win;
                else
                    probs(t, j) = (1-p_stay_win)/3;
                end
            end
        else
            for j=1:4
                if act_t_1==j
                    probs(t, j) = 1 - p_shift_loss;
                else
                    probs(t, j) = p_shift_loss/3;
                end
            end
        end
        r_t_1 = reward_seq(t);
        act_t_1 = strfind(actions, action_seq(t));
    end
end

