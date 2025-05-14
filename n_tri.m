% Class for normal triangle
% syntax:
% n_tri(p_i,p_f,v_f,plane,isprev)
% - p_i:    initial position; Coeff of L ; Example: 2 for position 2*L
% - p_f:    final position; Coeff of L ; Example: 4 for position 4*L
% - v_f:    final value is the Coeff of p ; Example: 2 for load of 2*p
% - plane:  input (1) for yz plane ; input (2) for xz plane
% - isprev:    (OPTIONAL): True (to plot original load only) or 
%                          False (to plot original & correction load)
classdef n_tri
    properties
        start; % Starting Position
        ending_tri; % Ending Position of Original Load
        ending_beam; % Length of the beam
        value_tri_y; % Value of Correction's large triangle
        value_rec_y; % Value of Correction's rectangle
        value_tri2_y; % Value of Correction's small triangle
        value_tri_x; % Value of Correction's large triangle
        value_rec_x; % Value of Correction's rectangle
        value_tri2_x; % Value of Correction's small triangle
        corr_start; % Starting Position of Correction's small triangle
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
        function obj = n_tri(parent,p_i,pf,vf,dir,laxis,vars)
            arguments
                parent
                p_i
                pf
                vf
                dir
                laxis
                vars.skp = false;
            end
            obj.parent = parent;
            skp = vars.skp;
            eb = parent.L;
            obj.laxis=laxis;
            Cx = parent.Cx;
            Cy = parent.Cy;
            syms p Li z;
            if parent.isrev && ~skp
                altern = rev_tri(parent,eb-pf,eb-p_i,vf,laxis,skp=true);
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
            obj.value_tri_y = (-obj.vy./(pf-p_i)).*(eb-p_i);
            obj.corr_start = pf;
            obj.value_rec_y = obj.vy;
            obj.value_tri2_y = -(obj.value_tri_y+obj.vy);
            obj.value_tri_x = (obj.vx./(pf-p_i)).*(eb-p_i);
            obj.corr_start = pf;
            obj.value_rec_x = -obj.vx;
            obj.value_tri2_x = -(obj.value_tri_x-obj.vx);
            if pf~=eb
                x1 = s_tri(p_i,obj.value_tri_y,eb);
                x2 = s_tri(obj.corr_start,obj.value_tri2_y,eb);
                x3 = s_rec(obj.corr_start,obj.value_rec_y);
                obj.final_moment = x1+x2+x3;
                x4 = s_tri(p_i,obj.value_tri_x,eb);
                x5 = s_tri(obj.corr_start,obj.value_tri2_x,eb);
                x6 = s_rec(obj.corr_start,obj.value_rec_x);
                m_dummy = x4+x5+x6;
            else 
                x1 = s_tri(p_i,-obj.vy,eb);
                obj.final_moment = x1;
                x2 = s_tri(p_i,obj.vx,eb);
                m_dummy = x2;
            end
            obj.Sy = diff(obj.final_moment,z);
            obj.Nz = diff(m_dummy,z);
            obj.fy = 0.5*(pf-p_i)*obj.vy;
            obj.fx = 0.5*(pf-p_i)*obj.vx;
            obj.m0 = obj.fy*(p_i+2*(pf-p_i)/3);
        end
    end
end