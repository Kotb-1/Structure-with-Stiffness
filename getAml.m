function [Aml,mem] = getAml(mem)
DOFS = mem.DOFS;
syms z Y1 Y2 Y3;
L = mem.L;
cr = mem.crosssec;
E = cr.E;
G = cr.G;
I = cr.I;
A = cr.A;
Aeq = cr.Aeq;
d = cr.d;
pre = mem.pre;
F_t = mem.Tav*mem.alpha*E*A;
M_t = E*I*mem.alpha*mem.Tdif/d;
F_pre = E*A*pre/L;
Loads = mem.loads;
Cx = mem.Cx;
Cy = mem.Cy;
Rt = mem.Rt;
mdofs = mem.mdofs;
Mx = 0;
Sy = 0;
Nz = 0;
m0_sum = 0;
fx_sum = 0;
fy_sum = 0;
for i = 1:length(Loads)
    c_l = Loads{i};
    if strcmpi(c_l.laxis,"l")
        Mx = Mx + c_l.final_moment;
        Sy = Sy + c_l.Sy;
        Nz = Nz + c_l.Nz;
        m0_sum = m0_sum + c_l.m0;
        fx_sum = fx_sum + c_l.fx;
        fy_sum = fy_sum + c_l.fy;
    elseif strcmpi(c_l.laxis,"g")
        if isa(c_l,"con_m")
            Mx = Mx + abs(Cx)*c_l.final_moment;
            m0_sum = m0_sum + c_l.m0;
        else
            Mx = Mx + c_l.final_moment;
            Sy = Sy + c_l.Sy;
            Nz = Nz + c_l.Nz;
            fx_c = c_l.fx ;
            fy_c = c_l.fy ;
            m0_sum = m0_sum + c_l.m0;
            fx_sum = fx_sum + fx_c;
            fy_sum = fy_sum + fy_c;
        end
    end
end

if isequal(DOFS,[1,1,1])
    R1 = -Y1 - fx_sum;
    R2 = -Y2 - fy_sum;
    R3 = -Y3 - Y2*L - m0_sum;
    Mx = Mx - R2*z + R3;
    Sy = Sy - R2;
    Nz = Nz + R1;
    MxY1 = dY(Mx,z,L,Y1); MxY2 = dY(Mx,z,L,Y2); MxY3 = dY(Mx,z,L,Y3);
    SyY1 = dY(Sy,z,L,Y1); SyY2 = dY(Sy,z,L,Y2); SyY3 = dY(Sy,z,L,Y3);
    NzY1 = dY(Nz,z,L,Y1); NzY2 = dY(Nz,z,L,Y2); NzY3 = dY(Nz,z,L,Y3);
    dUdY1 = MxY1/E/I + SyY1/G/Aeq + NzY1/E/A;
    dUdY2 = MxY2/E/I + SyY2/G/Aeq + NzY2/E/A;
    dUdY3 = MxY3/E/I + SyY3/G/Aeq + NzY3/E/A;
    eq1 = dUdY1==0;
    eq2 = dUdY2==0;
    eq3 = dUdY3==0;
    solns = solve([eq1,eq2,eq3],[Y1,Y2,Y3]);
    Y1ans = solns.Y1; Y2ans = solns.Y2; Y3ans = solns.Y3;
    R1ans = subs(R1,Y1,Y1ans); R2ans = subs(R2,Y2,Y2ans); R3ans = subs(subs(R3,Y2,Y2ans),Y3,Y3ans);
elseif isequal(DOFS,[0,1,1]) || isequal(DOFS,[1,0,1])
    R1 = 0;
    R2 = -Y2 - fy_sum;
    R3 = -Y3 - Y2*L - m0_sum;
    Mx = Mx - R2*z + R3;
    Sy = Sy - R2;
    MxY2 = dY(Mx,z,L,Y2); MxY3 = dY(Mx,z,L,Y3);
    SyY2 = dY(Sy,z,L,Y2); SyY3 = dY(Sy,z,L,Y3);
    dUdY2 = MxY2/E/I + SyY2/G/Aeq;
    dUdY3 = MxY3/E/I + SyY3/G/Aeq;
    eq2 = dUdY2==0;
    eq3 = dUdY3==0;
    solns = solve([eq2,eq3],[Y2,Y3]);
    Y1ans = 0; Y2ans = solns.Y2; Y3ans = solns.Y3;
    R1ans = 0; R2ans = subs(R2,Y2,Y2ans); R3ans = subs(subs(R3,Y2,Y2ans),Y3,Y3ans);
elseif isequal(DOFS,[1,1,0])
    R1 = -fx_sum-Y1;
    R2 = -fy_sum-Y2;
    R3 = 0;
    Mx = Mx - R2*z;
    Sy = Sy - R2;
    Nz = Nz + R1;
    NzY1 = dY(Nz,z,L,Y1);
    dUdY1 = NzY1/E/A;
    eq1 = dUdY1==0;
    eq2 = Y2*L + m0_sum==0;
    solns = solve([eq1,eq2],[Y1,Y2]);
    Y1ans = solns.Y1; 
    Y2ans = solns.Y2; Y3ans = 0;
    R1ans = subs(R1,Y1,Y1ans); 
    R2ans = subs(R2,Y2,Y2ans); R3ans=0;
end
ys = double([Y1ans-F_t+F_pre,Y2ans,Y3ans+M_t]);
rs = double([R1ans+F_t-F_pre,R2ans,R3ans-M_t]);
if Cx>0
    Ai = [rs,ys].';
elseif Cx<0
    Ai = [ys,rs].';
elseif Cy>0
    Ai = [rs,ys].';
elseif Cy<0
    Ai = [ys,rs].';
end
Aml = Rt*Ai([DOFS,DOFS]);
mem.Aml = Ai([DOFS,DOFS]);
mem.Aall = Ai;
mem.Mx = Mx;
mem.Sy = Sy;
mem.Nz = Nz;
end



function out = dY(Mx,z,L,X)
syms dumdum
dd = diff(Mx,X);
if Mx~=0
    Mx = Mx + dumdum;
    Mx = children(Mx);
else
    out =0;
    return;
end
Mx1i = int(dd.*Mx,z,[0,L]);
Mx1 = sum([Mx1i(:)]);
out = subs(Mx1,dumdum,0);
end
