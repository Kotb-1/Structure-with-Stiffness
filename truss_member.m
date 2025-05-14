classdef truss_member
    properties
        Aml;
        Aall;
        Amlf;
        D;
        Mx;
        Sy;
        Nz;
        S;
        n1;
        n2;
        DOFS;
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
        function obj = truss_member(node1,node2,crosssec,vars)
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
            obj.DOFS = [true,true,false];
            obj.loads={};
            obj.figtitle = "Member "+node1.n+"-"+node2.n;
            obj.n1 = node1;
            obj.n2 = node2;
            obj.mdofs = [node1.dof_inds(1:2),node2.dof_inds(1:2)];
            xs = [node1.x,node2.x];
            ys = [node1.y,node2.y];
            dx = xs(2)-xs(1);
            dy = ys(2)-ys(1);
            L = sqrt(dx^2 + dy^2);
            obj.L = L;
            obj.Cx = dx/L;
            obj.Cy = dy/L;
            obj.crosssec = crosssec;
            E = crosssec.E;
            A = crosssec.A;
            Stiny = [obj.Cx^2,obj.Cx*obj.Cy;obj.Cx*obj.Cy,obj.Cy^2];
            obj.Sg = E.*A.*[Stiny,-Stiny;-Stiny,Stiny]./L;
            Rti = [obj.Cx,-obj.Cy;obj.Cy,obj.Cx];
            ze = zeros(2);
            obj.Rt = [Rti,ze;ze,Rti];
            obj.Sl = obj.Rt*obj.Sg*(obj.Rt.');
        end
    end
end