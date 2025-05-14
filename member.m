classdef member
    properties
        Aml;
        DOFS;
        Aall;
        Amlf;
        D;
        Mx;
        Sy;
        Nz;
        S;
        n1;
        n2;
        mdofs;
        Cx;
        Cy
        Rt;
        loads;
        L;
        crosssec;
        Sg;
        Sl;
        Tav;
        Tdif;
        alpha;
        figtitle;
        isrev;
        pre;
    end

    methods
        function obj = member(node1,node2,crosssec,vars)
            arguments
                node1
                node2
                crosssec
                vars.Tu = 0
                vars.Tl = 0
                vars.alpha = 1
                vars.pre = 0
            end
            obj.Tav = (vars.Tu+vars.Tl)/2;
            obj.Tdif = vars.Tu-vars.Tl;
            obj.alpha = vars.alpha;
            obj.pre = vars.pre;
            if node2.x < node1.x
                nnn = node1;
                node1 = node2;
                node2 = nnn;
                obj.isrev = true;
            else
                obj.isrev = false;
            end
            obj.loads={};
            obj.figtitle = "Member "+node1.n+"-"+node2.n;
            obj.n1 = node1;
            obj.n2 = node2;
            global DOFS;
            if isequal(DOFS,[0,1,1]) && node1.hin==1
                obj.mdofs = [node1.dof_inds([1,3]),node2.dof_inds];
            elseif isequal(DOFS,[0,1,1]) && node2.hin==1
                obj.mdofs = [node1.dof_inds,node2.dof_inds([1,2])];
            elseif isequal(DOFS,[0,1,1]) && node1.hin==1 && node2.hin==1
                obj.mdofs = [node1.dof_inds([1,3]),node2.dof_inds([1,2])];
            else
                obj.mdofs = [node1.dof_inds,node2.dof_inds];
            end
            obj.DOFS = DOFS;
            nDOFS = sum(DOFS);
            xs = [node1.x,node2.x];%%i love you
            ys = [node1.y,node2.y];
            dx = xs(2)-xs(1);
            dy = ys(2)-ys(1);
            L = sqrt(dx^2 + dy^2);
            obj.L = L;
            obj.Cx = dx/L;
            obj.Cy = dy/L;
            obj.crosssec = crosssec;
            I = crosssec.I;
            k = crosssec.k;
            E = crosssec.E;
            A = crosssec.A;
            useless = 1:6;
            Aeq = crosssec.Aeq;
            loc_stiff_ind = useless([DOFS,DOFS]);
            G = crosssec.G;
            C = E*I*k/G/A/L^2;
            C1 = 1/(1+12*C);
            C2 = (1+3*C)*C1;
            C3 = (1-6*C)*C1;
            k11 = A*obj.Cx^2/L + C1*12*I*obj.Cy^2/L^3;
            k21 = (A/L - C1*12*I/L^3)*obj.Cx*obj.Cy;
            k22 = A*obj.Cy^2/L + 12*I*C1*obj.Cx^2/L^3;
            k31 = -C1*obj.Cy*6*I/L^2;
            k32 = 6*I*C1*obj.Cx/L^2;
            k33 = 4*I*C2/L;
            k63 = 2*I*C3/L;
            Si = E.*[k11,k21,k31,-k11,-k21,k31;k21,k22,k32,-k21,-k22,k32;k31,k32,k33,-k31,-k32,k63;-k11,-k21,-k31,k11,k21,-k31;-k21,-k22,-k32,k21,k22,-k32;k31,k32,k63,-k31,-k32,k33];
            obj.Sg  = Si(loc_stiff_ind,loc_stiff_ind);
            Rti = [obj.Cx,-obj.Cy,0;obj.Cy,obj.Cx,0;0,0,1];
            ze = zeros(3);
            Rti2 = [Rti,ze;ze,Rti];
            obj.Rt = Rti2(loc_stiff_ind,loc_stiff_ind);
            obj.Sl = obj.Rt*obj.Sg*(obj.Rt.');
        end
    end
end