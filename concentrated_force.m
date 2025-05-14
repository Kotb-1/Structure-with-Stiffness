% Moment due to concentrated force using singularity
% R is the value force
% P is the force position 
function x = concentrated_force(p,R)
    syms z;
    if p == 0   
        x = R.*z;
    else
        x = R.*sing(z,p,1);
    end
end