function [ lever ] = select_arm_softmax(values, temperature)
    z = sum(exp(values/temperature));
    probs = exp(values/temperature) / z;
    rr = rand;
    for cc=1:4
        if rr <= sum(probs(1:cc))
            lever = cc;
            return
        end
    end
    [~, lever] = max(values);
end