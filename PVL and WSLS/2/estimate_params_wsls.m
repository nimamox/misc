load group1
load group2
load score1
load score2

estimated_params_wsls_group1 = zeros(55, 2);
X0 = [.3 .6];
for ii=1:55
    cost_act_seq = group1(ii,:);
    cost_reward_seq = score1(ii,:);
    objfunc = @(x) objective_func_wsls(x, cost_act_seq, cost_reward_seq);
    [x, fval] = patternsearch(objfunc, X0);
    estimated_params_wsls_group1(ii,:) = x;
end

estimated_params_wsls_group2 = zeros(23, 2);
X0 = [.3 .6];
for ii=1:23
    cost_act_seq = group2(ii,:);
    cost_reward_seq = score2(ii,:);
    objfunc = @(x) objective_func_wsls(x, cost_act_seq, cost_reward_seq);
    [x, fval] = patternsearch(objfunc, X0);
    estimated_params_wsls_group2(ii,:) = x;
end

fprintf('P_stay_win:\n');
[h,p,ci,stats] = ttest2(estimated_params_wsls_group1(:,1), estimated_params_wsls_group2(:,1))

fprintf('P_shift_stay:\n');
[h,p,ci,stats] = ttest2(estimated_params_wsls_group1(:,2), estimated_params_wsls_group2(:,2))
