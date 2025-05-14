classdef tempcross

    properties
        E;
        I;
        A;
        Aeq;
        G;
        k;
        d;
    end

    methods
        function obj = tempcross(E,A,vars)
            arguments
                E
                A
                vars.I = 0
                vars.Aeq = 0
                vars.v = 0.3
                vars.d = 1
            end
            I = vars.I;
            if vars.Aeq ~=0
                Aeq = vars.Aeq;
            else
                Aeq = A;
            end
            v = vars.v;
            obj.E = E;
            obj.I = I;
            obj.A = A;
            obj.Aeq = Aeq;
            obj.G = E/2/(1+v);
            obj.k = A/Aeq;
            obj.d = vars.d;
        end
    end
end