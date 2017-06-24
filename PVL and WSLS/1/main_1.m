clear;
AAR_eps_1 = zeros(100, 1);
AAR_eps_2 = zeros(100, 1);
AAR_eps_3 = zeros(100, 1);
AAR_eps_4 = zeros(100, 1);
AAR_eps_5 = zeros(100, 1);
AAR_eps_6 = zeros(100, 1);


selections = zeros(1, 2);
alpha_expression = '1';
for j=1:100
    run_1_a_eps_greedy;
    AAR_eps_1 = AAR_eps_1 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_eps_1 = AAR_eps_1 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '0.9^i';
for j=1:100
    run_1_a_eps_greedy;
    AAR_eps_2 = AAR_eps_2 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_eps_2 = AAR_eps_2 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '1/(2^i)';
for j=1:100
    run_1_a_eps_greedy;
    AAR_eps_3 = AAR_eps_3 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_eps_3 = AAR_eps_3 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '1/i';
for j=1:100
    run_1_a_eps_greedy;
    AAR_eps_4 = AAR_eps_4 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_eps_4 = AAR_eps_4 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '.3';
for j=1:100
    run_1_a_eps_greedy;
    AAR_eps_5 = AAR_eps_5 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_eps_5 = AAR_eps_5 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '5/(5+i)';
for j=1:100
    run_1_a_eps_greedy;
    AAR_eps_6 = AAR_eps_6 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_eps_6 = AAR_eps_6 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

figure (1)
hFig = figure(1);
set(gcf,'PaperPositionMode','auto')
set(hFig, 'Position', [0 0 1000 600])

x_axis = 0:99;
plot(x_axis, AAR_eps_1, 'c-', x_axis, AAR_eps_2, 'b-', x_axis, AAR_eps_3, 'g-', x_axis, AAR_eps_4, 'm-', ...
    x_axis, AAR_eps_5, 'r-', x_axis, AAR_eps_6, 'k-');
title('Epsilon-greedy strategy');
legend('1','0.9^k', '1/(2^k)', '1/k', '.3', '5/(5+k)');
ylabel('AR');
xlabel('trials');
