load group1
load group2
load score1
load score2

estimated_params_group1 = zeros(55, 4);
X0 = [.1, 4, .5, .3];
for ii=1:55
    cost_act_seq = group1(ii,:);
    cost_reward_seq = score1(ii,:);
    objfunc = @(x) objective_func_pvl(x, cost_act_seq, cost_reward_seq);
    [x, fval] = patternsearch(objfunc, X0);
    estimated_params_group1(ii,:) = x;
end

estimated_params_group2 = zeros(23, 4);
X0 = [.1, 4, .5, .3];
for ii=1:23
    cost_act_seq = group2(ii,:);
    cost_reward_seq = score2(ii,:);
    objfunc = @(x) objective_func_pvl(x, cost_act_seq, cost_reward_seq);
    [x, fval] = patternsearch(objfunc, X0);
    estimated_params_group2(ii,:) = x;
end

fprintf('Alpha:\n');
[h,p,ci,stats] = ttest2(estimated_params_group1(:,1), estimated_params_group2(:,1))

fprintf('Lambda:\n');
[h,p,ci,stats] = ttest2(estimated_params_group1(:,2), estimated_params_group2(:,2))

fprintf('A:\n');
[h,p,ci,stats] = ttest2(estimated_params_group1(:,3), estimated_params_group2(:,3))

fprintf('c:\n');
[h,p,ci,stats] = ttest2(estimated_params_group1(:,4), estimated_params_group2(:,4))