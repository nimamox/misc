function [ sa ] = afterstate(state, a)
    global H
    sa = state - a;
    assert(sum(state) <= H, 'INVALID STATE');
    assert(sum(a) <= H, 'INVALID STATE');
    assert(sum(sa) <= H, 'INVALID STATE');
    assert(sum(sa) >= 0 , 'INVALID STATE');
end

