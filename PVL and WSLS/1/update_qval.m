function [ new_values ] = update(arm, reward, alpha, values)
    val = values(arm);
    new_value = val + alpha * (reward - val);
    new_values = values;
    new_values(arm) = new_value;
end
