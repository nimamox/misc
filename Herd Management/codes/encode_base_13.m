function [ encoded ] = encode_base_13( s )
    encoded = s(1) * 169 + s(2) * 13 + s(3);
end

