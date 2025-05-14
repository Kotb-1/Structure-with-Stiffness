% Class for concentrated Moment
% syntax:
% con_m(Position,Magnitude,direction,plane,Preview)
% - Position:   Coeff of L ; Example: 2 for position 2*L
% - Magnitude:  Coeff of p*L^2 ; Example: 2 for a force of 2*p*L^2
% - direction:  is 'cw' for Clockwise Moment or 'ccw' for
%               Counterclockwise Moment
% - plane:      input (1) for yz plane ; input (2) for xz plane
% - Preview:    (OPTIONAL): input True for plotting on the preview axes
%                              or False to plot on the original axis
classdef con_m
    properties
        p; % Position
        M; % Magnitude
        final_moment; % Final moment due to concentrated moment
        pl; % All plots of the object
        plane; % Index of the plane
        fy; % Resultant force in the upward direction (always = 0) 
        m0; % Moment about z=0
        f; %figure handle
        Sy;
        Nz;
        fx;
        parent;
    end
    methods
        function obj = con_m(parent,pos,m,dir)
            syms z;
            L_member = parent.L;
            if parent.isrev
                pos = L_member-pos;
            end
            obj.p = pos;
            obj.parent=parent;
            if strcmpi(dir,"ccw")
                obj.M = m;
            elseif strcmpi(dir,"cw")
                obj.M = -m;
            end
            x1 =  concentrated_moment(pos,obj.M);
            obj.final_moment = x1;
            obj.fy = 0;
            obj.fx = 0;
            obj.Sy = 0;
            obj.Nz = 0;
            obj.m0 = obj.M;
        end
    end
end