%clear
epsilon = 1;
%alpha = 1;
counts = zeros(4, 1);
%values = zeros(4, 1);
values = ones(4, 1) * 100;

load_dataset;
steps = 100;
selected_arms = zeros(steps, 1);
received_rewards = zeros(steps, 1);
AR = zeros(steps, 1);

for i=1:100
    alpha = eval(alpha_expression);
    chosen_arm = select_arm_eps_greedy(values, epsilon);
    counts(chosen_arm) = counts(chosen_arm) + 1;
    reward = net_rewards(chosen_arm, counts(chosen_arm));
    selected_arms(i) = chosen_arm;
    received_rewards(i) = reward;
    AR(i) = mean(received_rewards(1:i));
    values = update_qval(chosen_arm, reward, alpha, values);
    epsilon = epsilon - .01;
end
