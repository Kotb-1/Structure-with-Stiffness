% Moment due to concentrated moment using singularity
% M is the value moment
% P is the moment position 
function x = concentrated_moment(p,M)
    syms z;
    if p == 0   
        x = M;
    else
        x = M.*sing(z,p,0);
    end
end