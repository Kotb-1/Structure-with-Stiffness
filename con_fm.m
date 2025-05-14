% Class for Concenterated Forces
% syntax:
% con_f(Position,Magnitude,direction,plane,Preview)
% - Position:   Coeff of L ; Example: 2 for position 2*L
% - Magnitude:  Coeff of p*L ; Example: 2 for a force of 2*p*L
% - direction:  is "down" for downward force or "up" for upward force
% - plane:      input (1) for yz plane ; input (2) for xz plane
% - Preview:    (OPTIONAL): input True for plotting on the preview axes
%                              or False to plot on the original axis
classdef con_fm
    properties
        p; % Position
        R; % Magnitude
        final_moment; % Final moment due to concentrated force
        fy; % Resultant force in the upward direction 
        m0; % Moment about z=0
        plane; % Index of the plane
        fx;
        laxis;
        Nz;
        Sy;
        parent;
    end
    methods
        function obj = con_fm(parent,pos,R,dir,laxis)
            syms Li z;
            obj.laxis=laxis;
            L_member = parent.L;
            Cx = parent.Cx;
            Cy = parent.Cy;
            obj.parent=parent;
            if parent.isrev
                pos = L_member-pos;
            end
            if strcmpi(laxis,"l")
                if strcmpi(dir,"up")
                    obj.fy = R;
                    obj.fx = 0;
                elseif strcmpi(dir,"down")
                    obj.fy = -R;
                    obj.fx = 0;
                elseif strcmpi(dir,"right")
                    obj.fy = 0;
                    obj.fx = R;
                elseif strcmpi(dir,"left")
                    obj.fy = 0;
                    obj.fx = -R;
                end
            elseif strcmpi(laxis,"g")
                if strcmpi(dir,"up")
                    obj.fy = R*Cx;
                    obj.fx = Cy*R;
                elseif strcmpi(dir,"down")
                    obj.fy = -R*Cx;
                    obj.fx = -R*Cy;
                elseif strcmpi(dir,"right")
                    obj.fy = -R*Cy;
                    obj.fx = R*Cx;
                elseif strcmpi(dir,"left")
                    obj.fy = R*Cy;
                    obj.fx = -R*Cx;
                end
            end
            R = -obj.fy;
            obj.p = pos;
            obj.R = R;
            x1 =  concentrated_force(pos,obj.R);
            x2 = concentrated_force(pos,obj.fx);
            obj.Nz = diff(x2,z);
            obj.Sy = diff(x1,z);
            obj.final_moment = x1;
            obj.m0 = obj.fy*pos;
            
        end
    end
end