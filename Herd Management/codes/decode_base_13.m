function [ d ] = decode_base_13( num )
    d1 = floor(num/169);
    d2 = floor(mod(num, 169)./13);
    d3 = mod(num,13);
    d = [d1 d2 d3];
end

