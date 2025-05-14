classdef NODES
    % f has two elements [magnitude,angle with +ve x axis]
    % m is +ve CCW and -ve CW

    properties
        dof_inds;
        x;
        y;
        An;
        Anf;
        iscons;
        supp;
        n;
        D;
        hin;
    end

    methods
        function obj = NODES(ind,xi,yi,vars)
            arguments
                ind
                xi
                yi
                vars.f (1,2) =[0,0]
                vars.fx = 0
                vars.fy = 0
                vars.m = 0
                vars.constraint = "free"
                vars.dx = 0
                vars.dy = 0
                vars.dRz = 0
                vars.Hinges = []
                vars.isRlhinges =[0,0]
                vars.Drhinge=[0,0]
            end
            if isempty(vars.Hinges) || length(vars.Hinges)<ind
                Hinges = zeros([1,ind]);
            else
                Hinges = vars.Hinges;
            end
            obj.hin = Hinges(ind);
            f = vars.f;
            m = vars.m;
            constraint = vars.constraint;
            D = [vars.dx,vars.dy,vars.dRz];
            global DOFS;
            if ind > 1
                n_prevhinges = sum(Hinges(1:ind-1));
            else
                n_prevhinges = 0;
            end
            nDOFS = sum(DOFS);
            if strcmpi(constraint,"fixed")
                iscons_i = [1,1,1];
            elseif strcmpi(constraint,"simple")
                iscons_i = [1,1,0];
            elseif strcmpi(constraint,"hroller")
                iscons_i = [1,0,0];
            elseif strcmpi(constraint,"vroller")
                iscons_i = [0,1,0];
            elseif strcmpi(constraint,"free")
                iscons_i = [0,0,0];
            elseif strcmpi(constraint,"hslider")
                iscons_i = [1,0,1];
            elseif strcmpi(constraint,"vslider")
                iscons_i = [0,1,1];
            end
            obj.x = xi;
            obj.y = yi;
            obj.n = ind;
            obj.dof_inds = (ind-1)*nDOFS+1+n_prevhinges:1:ind*nDOFS+n_prevhinges+Hinges(ind);
            fy  = f(1)*sind(f(2))+vars.fy;
            fx = f(1)*cosd(f(2))+vars.fx;
            obj.An  = [fx,fy,m].';
            obj.iscons = zeros(size(obj.Anf));
            if length(obj.An)==3
                obj.Anf = obj.An(DOFS);
                obj.iscons = iscons_i(DOFS);
                obj.D = D(DOFS).';
            else
                obj.Anf = [obj.An(DOFS(1:2)),m].';
                obj.iscons = [iscons_i(DOFS(1:2)),vars.isRlhinges];
                obj.D = [D(DOFS(1:2)),vars.Drhinge].';
            end
        end
    end
end