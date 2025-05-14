% Class for Rectangle distriputed load
% syntax:
% rec(p_i,p_f,v,plane,isprev)
% - p_i:    initial position; Coeff of L ; Example: 2 for position 2*L
% - p_f:    final position; Coeff of L ; Example: 4 for position 4*L
% - v:      value is the Coeff of p ; Example: 2 for load of 2*p
% - plane:  input (1) for yz plane ; input (2) for xz plane
% - isprev:    (OPTIONAL): True (to plot original load only) or 
%                          False (to plot original & correction load)
classdef rec
    properties
        start; % Starting Position of Rectangle
        ending_beam; % Length of the beam
        value; % Value of the distributed load
        corr_start; % Starting position of the correction
        plane;% Index of the plane
        final_moment;% Final moment due to concentrated moment
        % plotting stuff
        y_value;%numerical value for load
        domain;% z domain for original load
        domain_corr1;% z domain for correction1 load
        domain_corr2;% z domain for correction2 load
        pl;% All plots of the object
        fy;% Resultant force in the upward direction
        m0;% Moment about z=0
        laxis;
        fx;
        Sy;
        Nz;
        parent;
    end
    methods
        function obj = rec(parent,p_i,pf,v,dir,laxis)
            eb = parent.L;
            if parent.isrev
                ppp = p_i;
                p_i = eb-pf;
                pf = eb-ppp;
            end
            obj.laxis=laxis;
            Cx = parent.Cx;
            Cy = parent.Cy;
            syms Li z;
            obj.start = p_i;
            obj.ending_beam = eb;
            obj.corr_start = pf;
            obj.value = v;
            ran = pf-p_i;
            obj.parent = parent;
            if strcmpi(laxis,"l")
                if strcmpi(dir,"up")
                    obj.fy = v*ran;
                    obj.fx = 0;
                elseif strcmpi(dir,"down")
                    obj.fy = -v*ran;
                    obj.fx = 0;
                elseif strcmpi(dir,"right")
                    obj.fy = 0;
                    obj.fx = v*ran;
                elseif strcmpi(dir,"left")
                    obj.fy = 0;
                    obj.fx = -v*ran;
                end
            elseif strcmpi(laxis,"g")
                if strcmpi(dir,"up")
                    obj.fy = v*ran*abs(Cx);
                    obj.fx = Cy*v*ran;
                elseif strcmpi(dir,"down")
                    obj.fy = -v*ran*Cx;
                    obj.fx = -v*ran*Cy;
                elseif strcmpi(dir,"right")
                    obj.fy = -v*ran*Cy;
                    obj.fx = v*ran*Cx;
                elseif strcmpi(dir,"left")
                    obj.fy = v*ran*Cy;
                    obj.fx = -v*ran*Cx;
                end
            end
            Ry = -obj.fy/ran;
            Rx = obj.fx/ran;
            x1 = s_rec(p_i,Ry);
            x2 = s_rec(pf,Ry);
            x3 = s_rec(p_i,Rx);
            x4 = s_rec(pf,Rx);
            obj.final_moment = x1-x2;
            obj.Sy = diff(obj.final_moment,z);
            obj.Nz = diff(x3-x4,z);
            obj.m0 = obj.fy*(p_i+0.5*ran);
        end
    end
end