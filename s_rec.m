% Moment due to rectangle using singularity
% pi is the intial position
% Value is the load value
function x = s_rec(p_i,value)
    syms z ;
    x = (value./2).*sing(z,p_i,2);
end