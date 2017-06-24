%VV = zeros(encode_base_13([12 12 12]), 1);
%S = 1:encode_base_13([12 12 12]);
V1 = [];
V2 = [];
V3 = [];
S = [];
for i=1:encode_base_13([12 12 12])
    if V_1_sweep.isKey(i)
        V1(end+1) = V_1_sweep(i);
        V2(end+1) = V_10_sweep(i);
        V3(end+1) = V_opt(i);
        S(end+1) = i;
    end
end

figure (1)
hFig = figure(1);
set(gcf,'PaperPositionMode','auto')
set(hFig, 'Position', [0 0 1000 600])
plot(S, V1, '-b', S, V2, '-r', S, V3, '-g')
legend('sweeps=1', 'sweeps=10', 'opt');
title('V_k for policy iteration with sweep 1, sweep 10, and optimal value function');
xlabel('States (base 13 representation)');
ylabel('Value function');