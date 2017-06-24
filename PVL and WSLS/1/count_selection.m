function [ arm_count ] = count_selection( selected_arms )
    arm_count = [sum(selected_arms==1)+sum(selected_arms==2) sum(selected_arms==3)+sum(selected_arms==4)];
end

