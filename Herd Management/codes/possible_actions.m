function [ actions ] = possible_actions( state )
    actions = [];
    for i=0:state(1)
        for j=0:state(2)
            for k=0:state(3)
                actions = [actions; i j k];
            end
        end
    end
end

