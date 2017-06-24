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
gamma = .3;

sweeps = 1;
[V_1_sweep, pi_1_sweep, iter_1_sweep] = policy_iteration(gamma, theta, sweeps);
sweeps = 10;
[V_10_sweep, pi_10_sweep, iter_10_sweep] = policy_iteration(gamma, theta, sweeps);
sweeps = -1;
[V_opt, pi_opt, iter_opt] = policy_iteration(gamma, theta, sweeps);

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
plot(S, V1, '-b', S, V2, '-r', S, V3, '--g')
legend('sweeps=1', 'sweeps=10', 'opt');
title('V_k for policy iteration with sweep 1, sweep 10, and optimal value function with gamma=.3');
xlabel('States (base 13 representation)');
ylabel('Value function');

state = [4 7 1]
best_action(state, V_opt, gamma)

state = [1 3 6]
best_action(state, V_opt, gamma)

state = [9 2 1]
best_action(state, V_opt, gamma)