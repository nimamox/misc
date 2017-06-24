%clear
%alpha = .01;
counts = zeros(4, 1);
%values = zeros(4, 1);
values = ones(4, 1) * 100;

temperature = 10.0;

load_dataset;
steps = 100;
selected_arms = zeros(steps, 1);
received_rewards = zeros(steps, 1);
AR = zeros(steps, 1);

for i=1:steps
    alpha = eval(alpha_expression);
    chosen_arm = select_arm_softmax(values, temperature);
    counts(chosen_arm) = counts(chosen_arm) + 1;
    reward = net_rewards(chosen_arm, counts(chosen_arm));
    selected_arms(i) = chosen_arm;
    received_rewards(i) = reward;
    AR(i) = mean(received_rewards(1:i));
    values = update_qval(chosen_arm, reward, alpha, values);
    temperature = temperature - .1; 
end