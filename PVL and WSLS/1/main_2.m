clear;
AAR_softmax_1 = zeros(100, 1);
AAR_softmax_2 = zeros(100, 1);
AAR_softmax_3 = zeros(100, 1);
AAR_softmax_4 = zeros(100, 1);
AAR_softmax_5 = zeros(100, 1);
AAR_softmax_6 = zeros(100, 1);

selections = zeros(1, 2);
alpha_expression = '1';
for j=1:100
    run_1_b_softmax;
    AAR_softmax_1 = AAR_softmax_1 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_softmax_1 = AAR_softmax_1 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100


selections = zeros(1, 2);
alpha_expression = '0.9^i';
for j=1:100
    run_1_b_softmax;
    AAR_softmax_2 = AAR_softmax_2 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_softmax_2 = AAR_softmax_2 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '1/(2^i)';
for j=1:100
    run_1_b_softmax;
    AAR_softmax_3 = AAR_softmax_3 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_softmax_3 = AAR_softmax_3 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '1/i';
for j=1:100
    run_1_b_softmax;
    AAR_softmax_4 = AAR_softmax_4 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_softmax_4 = AAR_softmax_4 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '.3';
for j=1:100
    run_1_b_softmax;
    AAR_softmax_5 = AAR_softmax_5 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_softmax_5 = AAR_softmax_5 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

selections = zeros(1, 2);
alpha_expression = '5/(5+i)';
for j=1:100
    run_1_b_softmax;
    AAR_softmax_6 = AAR_softmax_6 + AR;
    selections = selections + count_selection(selected_arms(60:100));
end
AAR_softmax_6 = AAR_softmax_6 / 100;
fprintf('Alpha: [%s]\n', alpha_expression);
selections / sum(selections) * 100

figure (1)
hFig = figure(1);
set(gcf,'PaperPositionMode','auto')
set(hFig, 'Position', [0 0 1000 600])

x_axis = 0:99;
plot(x_axis, AAR_softmax_1, 'c-', x_axis, AAR_softmax_2, 'b-', x_axis, AAR_softmax_3, 'g-', x_axis, AAR_softmax_4, 'm-', ...
    x_axis, AAR_softmax_5, 'r-', x_axis, AAR_softmax_6, 'k-');
title('Softmax strategy');
legend('1','0.9^k', '1/(2^k)', '1/k', '.3', '5/(5+k)');
ylabel('AR');
xlabel('trials');
