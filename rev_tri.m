% Reverse triangle class
% syntax:
% rev_tri(p_i,p_f,v_i,plane,isprev)
% - p_i:    initial position; Coeff of L ; Example: 2 for position 2*L
% - p_f:    final position; Coeff of L ; Example: 4 for position 4*L
% - v_i:    initial value is the Coeff of p ; Example: 2 for load of 2*p
% - plane:  input (1) for yz plane ; input (2) for xz plane
% - isprev:    (OPTIONAL): True (to plot original load only) or 
%                          False (to plot original & correction load)
classdef rev_tri
    properties
        start; % strating position
        ending_tri; % ending position
        ending_beam; % beam length
        value_tri_y; % value of correction's large triangle
        value_rec_y; % correction rectangle value
        value_tri2_y; % value of correction's small triangle
        value_tri_x; % value of correction's large triangle
        value_rec_x; % correction rectangle value
        value_tri2_x; % value of correction's small triangle
        corr_start; % strating position of the small triangle correction
        plane;% Index of the plane
        final_moment;% Final moment due to concentrated moment
        pl;% All plots of the object
        fy;% Resultant force in the upward direction
        m0;% Moment about z=0
        vy;
        vx;
        fx;
        Sy;
        Nz;
        laxis;
        parent;
    end
    methods
        function obj = rev_tri(parent,p_i,pf,vf,laxis,vars)
            arguments
                parent
                p_i
                pf
                vf
                laxis
                vars.skp = false
            end
            obj.parent = parent;
            skp = vars.skp;
            eb = parent.L;
            obj.laxis=laxis;
            Cx = parent.Cx;
            Cy = parent.Cy;
            syms p Li;
            if parent.isrev && ~skp
                altern = n_tri(parent,eb-pf,eb-p_i,vf,laxis,skp=true);
                obj.final_moment = altern.final_moment;
                obj.fy = altern.fy;
                obj.m0 = altern.m0;
                obj.vy = altern.vy;
                obj.vx = altern.vx;
                obj.fx = altern.fx;
                obj.Sy = altern.Sy;
                obj.Nz = altern.Nz;
                return
            end
            obj.start = p_i;
            obj.plane = plane;
            obj.ending_tri = pf;
            obj.ending_beam = eb;
            if strcmpi(laxis,"l")
                if strcmpi(dir,"up")
                    obj.vy = vf;
                    obj.vx = 0;
                elseif strcmpi(dir,"down")
                    obj.vy = -vf;
                    obj.vx = 0;
                elseif strcmpi(dir,"right")
                    obj.vy = 0;
                    obj.vx = vf;
                elseif strcmpi(dir,"left")
                    obj.vy = 0;
                    obj.vx = -vf;
                end
            elseif strcmpi(laxis,"g")
                if strcmpi(dir,"up")
                    obj.vy = vf*Cx;
                    obj.vx = Cy*vf;
                elseif strcmpi(dir,"down")
                    obj.vy = -vf*Cx;
                    obj.vx = -vf*Cy;
                elseif strcmpi(dir,"right")
                    obj.vy = -vf*Cy;
                    obj.vx = vf*Cx;
                elseif strcmpi(dir,"left")
                    obj.vy = vf*Cy;
                    obj.vx = -vf*Cx;
                end
            end
            vy = -obj.vy;
            vx = obj.vx;
            obj.corr_start = p_i;
            obj.value_tri_y = (vy./(-p_i+pf)).*(eb-p_i);
            obj.value_rec_y = vy;
            obj.value_tri2_y = obj.value_tri_y-vy;

            obj.value_tri_x = (vx./(-p_i+pf)).*(eb-p_i);
            obj.value_rec_x = vx;
            obj.value_tri2_x = obj.value_tri_x-vx;

            x1 = s_tri(p_i,obj.value_tri_y,eb);
            x2 = s_tri(pf,obj.value_tri2_y,eb);
            x3 = s_rec(obj.corr_start,obj.value_rec_y);
            obj.final_moment = -x1+x2+x3;

            x4 = s_tri(p_i,obj.value_tri_x,eb);
            x5 = s_tri(pf,obj.value_tri2_x,eb);
            x6 = s_rec(obj.corr_start,obj.value_rec_x);
            m_dummy = -x4+x5+x6;

            obj.Sy = diff(obj.final_moment,z);
            obj.Nz = diff(m_dummy,z);

            obj.fy = -0.5*(pf-p_i)*vy;
            obj.fx = 0.5*(pf-p_i)*vx;
            obj.m0 = obj.fy*(p_i+(pf-p_i)/3);

        end
    end
end