function [ new_offspring ] = burn_offspring( breeding, offspring )
    global breed_prob
    if breeding == 0
        new_offspring = [offspring(1, 1) sum(offspring(find(offspring(:,1)==offspring(1, 1)), 2))];
        for c=2:size(offspring, 1)
            if find(new_offspring(:,1)==offspring(c, 1))
            else
                new_offspring = [new_offspring; offspring(c, 1) sum(offspring(find(offspring(:,1)==offspring(c, 1)), 2))];
            end
        end
        return
    end
    old_offspring = offspring;
    offspring = [];
    for f=1:size(old_offspring, 1)
        offspring = [offspring; old_offspring(f, 1) old_offspring(f, 2) * breed_prob(1)];
        offspring = [offspring; old_offspring(f, 1) + 1 old_offspring(f, 2) * breed_prob(2)];
        offspring = [offspring; old_offspring(f, 1) + 2 old_offspring(f, 2) * breed_prob(3)];
    end
    new_offspring = burn_offspring(breeding-1, offspring);
end

