function [ new_states3 ] = possible_states_prob( state )
    global H states total_states cow_transition burn_offspring_prob
    sub_states = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    sub_states(1) = [];
    sub_states(2) = [];
    sub_states(3) = [];
    for pos=1:size(state, 2)
        el = state(pos);
        if el==0
            sub_states(pos) = [encode_base_13([0 0 0]), 1];
            continue
        end
        for s=1:total_states
            st = states{s};
            if sum(st) == el
                p = cow_transition(pos,:);
                prob = (p(1)^st(1))*(p(2)^st(2))*(p(3)^st(3));
                prob = prob * nchoosek(el, max(st));
                if prob > 0 
                    sub_states(pos) = [sub_states(pos); encode_base_13(st) prob];
                end
            end
        end
    end
    new_states = [];
    for i=1:size(sub_states(1), 1)
        for j=1:size(sub_states(2), 1)
            for k=1:size(sub_states(3), 1)
                tmp1 = sub_states(1);
                tmp2 = sub_states(2);
                tmp3 = sub_states(3);
                jstate = decode_base_13(tmp1(i,1)) + decode_base_13(tmp2(j,1)) + decode_base_13(tmp3(k,1));
                jprob = tmp1(i,2) * tmp2(j,2) * tmp3(k,2);
                new_states = [new_states; encode_base_13(jstate) jprob];
            end
        end
    end
    new_states2 = [new_states(1, 1) sum(new_states(find(new_states(:,1)==new_states(1, 1)), 2))];
    for s=2:size(new_states, 1)
        if find(new_states2(:,1)==new_states(s, 1))
        else
            new_states2 = [new_states2; new_states(s, 1) sum(new_states(find(new_states(:,1)==new_states(s, 1)), 2))];
        end
    end
    newborns_states = [];
    for s=1:size(new_states2, 1)
        tmp = decode_base_13(new_states2(s, 1));
        %offspring = burn_offspring(tmp(2), [0 1]);
        offspring = burn_offspring_prob(tmp(2));
        for f=1:size(offspring, 1)
            if sum(tmp) + offspring(f, 1) > H
                newborn_cows = tmp(1) + H - sum(tmp);
            else
                newborn_cows = tmp(1) + offspring(f, 1);
            end
            newborns_states = [newborns_states; encode_base_13([newborn_cows tmp(2) tmp(3)]) new_states2(s, 2) * offspring(f, 2)];
        end
    end
    new_states3 = [newborns_states(1, 1) sum(newborns_states(find(newborns_states(:,1)==newborns_states(1, 1)), 2))];
    for s=2:size(newborns_states, 1)
        if find(new_states3(:,1)==newborns_states(s, 1))
        else
            new_states3 = [new_states3; newborns_states(s, 1) sum(newborns_states(find(newborns_states(:,1)==newborns_states(s, 1)), 2))];
        end
    end
end

