AIC_val = zeros(55+23, 2);
actions = 'ABCD';
for ii=1:55
    cost_act_seq = group1(ii,:);
    cost_reward_seq = score1(ii,:);
    params = estimated_params_wsls_group1(ii, :);
    wsls_probs = wsls(cost_act_seq, cost_reward_seq, params(1), params(2));
    score = 1;
    for t=1:100
        score = score * log(wsls_probs(t, strfind(actions, cost_act_seq(t))));
    end
    AIC_val(ii, 1) = -2*log(score) + 4;
    params = estimated_params_group1(ii, :);
    pvl_probs = pvl(cost_act_seq, cost_reward_seq, params(1), params(2), params(3), params(4));
    score = 1;
    for t=1:100
        score = score * log(wsls_probs(t, strfind(actions, cost_act_seq(t))));
    end
    AIC_val(ii, 2) = -2*log(score) + 8;
end

for ii=1:23
    cost_act_seq = group2(ii,:);
    cost_reward_seq = score2(ii,:);
    params = estimated_params_wsls_group2(ii, :);
    wsls_probs = wsls(cost_act_seq, cost_reward_seq, params(1), params(2));
    score = 1;
    for t=1:100
        score = score * log(wsls_probs(t, strfind(actions, cost_act_seq(t))));
    end
    AIC_val(55+ii, 1) = -2*log(score) + 4;
    params = estimated_params_group2(ii, :);
    pvl_probs = pvl(cost_act_seq, cost_reward_seq, params(1), params(2), params(3), params(4));
    score = 1;
    for t=1:100
        score = score * log(wsls_probs(t, strfind(actions, cost_act_seq(t))));
    end
    AIC_val(55+ii, 2) = -2*log(score) + 8;
end

