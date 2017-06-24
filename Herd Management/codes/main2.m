clear
global H states total_states cow_transition breed_prob utility payoff burn_offspring_prob cache_possible_states_prob;

H = 12;
utility = [.3 .4 .2];
payoff = [2. 6. 4.];
cow_transition = [.9 .1 0; 0 .75 .25; 0 .15 .85];
breed_prob = [.05 .8 .15];

total_states = 455;
states{total_states} = [];
c = 1;
for i=0:H
    for j=0:H-i
        for k=0:H-i-j
            states{c} = [i, j, k];
            c = c + 1;
        end
    end
end

cache_possible_states_prob = containers.Map('KeyType', 'int32', 'ValueType', 'any');


theta = .1;
gamma = .9;
sweeps = -1;
[V_vi_9, iter_vi_9] = value_iteration(gamma, theta, sweeps);

V1 = [];
S = [];
for i=1:encode_base_13([12 12 12])
    if V_vi_9.isKey(i)
        V1(end+1) = V_vi_9(i);
        S(end+1) = i;
    end
end

figure (1)
hFig = figure(1);
set(gcf,'PaperPositionMode','auto')
set(hFig, 'Position', [0 0 1000 600])
plot(S, V1, '-b')
legend('opt');
title('Optimal value function for value iteration method');
xlabel('States (base 13 representation)');
ylabel('Value function');