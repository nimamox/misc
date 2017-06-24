function [ output ] = remember_burn_offspring( )
    if(exist('burn_offspring_prob.mat','file'))
        load('burn_offspring_prob.mat');
    else
        burn_offspring_prob = containers.Map('KeyType','uint32','ValueType','any');
        if isempty(burn_offspring_prob)
            for i=0:12
                i
                burn_offspring_prob(i) = burn_offspring(i, [0 1]);
            end
            save('burn_offspring_prob.mat', 'burn_offspring_prob');
        end
    end
    output = burn_offspring_prob;
end

