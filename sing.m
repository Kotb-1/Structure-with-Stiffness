% Singularity Function
% z and x are in terms of L
function s = sing(z,x,n)
    m = z-x;
    s = (m).^n.*(sign(m)/2 + 1/2);
end