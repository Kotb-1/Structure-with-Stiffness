function [Ar,D,Df,members] = final_solver(members,nodes,loads)
n_members = length(members);
n_nodes   = length(nodes);
for i = 1:n_members
    m_i = members{i};
    loads_c={};
    for k = 1:length(loads)
        loadi = loads{k};
        if isequal(loadi.parent,m_i)
            loads_c = {loads_c{:},loadi};
        end
    end
    m_i.loads=loads_c;
    members{i}=m_i;
end
all_dofs = [];
    for i=1:n_nodes
        n_i = nodes{i};
        ndofs = n_i.dof_inds;
        all_dofs = [all_dofs,ndofs];
    end
nsize = length(all_dofs);
inds = 1:nsize;
Anl = zeros([nsize,1]);
iscons = Anl;
Dn = Anl;
Df = Dn;
Aml = Anl;
Sall = zeros(nsize);

    for i=1:n_nodes
        n_i = nodes{i};
        ndofs = n_i.dof_inds;
        Anl(ndofs) = Anl(ndofs)+n_i.Anf;
        iscons(ndofs) = n_i.iscons;
        Dn(ndofs) = n_i.D;
    end
    for i = 1:n_members
        m_i = members{i};
        mdofs = m_i.mdofs;
        [Aml_c,m_i] = getAml(m_i);
        Aml(mdofs) = Aml(mdofs)+Aml_c;
        members{i} = m_i;
        Sall(mdofs,mdofs) = Sall(mdofs,mdofs)+m_i.Sg;
    end
    allowed = inds(~iscons);
    cons = inds(~~iscons);
    Ae = -Aml;
    Ac = Anl+Ae;
    Ad = Ac(allowed);
    Arl = -Ac(cons);
    Dr = Dn(cons);
    Sdd = Sall(allowed,allowed);
    Sdr = Sall(allowed,cons);
    Srd = Sall(cons,allowed);
    Srr = Sall(cons,cons);
    Df(cons) = Dr;
    D = Sdd\(Ad-Sdr*Dr);
    Df(allowed)=D;
    Ard = Srd*D + Srr*Dr;
    Ar = Arl+Ard;
    for i = 1:n_members
        m_i = members{i};
        m_i = mem_plot(m_i,Df);
        members{i} = m_i;
    end
    disp("Deflections:")
    disp(D)
    disp("Reactions:")
    disp(Ar)
end