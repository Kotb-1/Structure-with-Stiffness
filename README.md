# Structure Analysis MATLAB Tool

A comprehensive MATLAB-based tool for structural analysis using the stiffness method. Model 2D beams, trusses, and frames under various loads and support conditions, compute bending moments, shear forces, axial forces, and deflections, and generate clear graphical outputs.

## Features

* **Object-Oriented Design**: Classes for nodes (`NODES.m`), members (`member.m`), and truss members (`truss_member.m`).
* **Load Representations**: Support for concentrated forces, concentrated moments, rectangular distributed loads, triangular and reverse triangular loads (files: `con_fm.m`, `con_m.m`, `rec.m`, `n_tri.m`, `rev_tri.m`).
* **Singularity Functions**: Utilities for load calculations (`sing.m`, `s_rec.m`, `s_tri.m`).
* **Analysis Engine**: Assembles global stiffness matrix, solves for reactions and displacements using Castigliano’s energy method (`getAml.m`, `Final_Solver.m`).
* **Visualization**: Automated plotting of bending moment, shear, and axial force diagrams (`mem_plot.m`).
* **Examples**: Pre-built examples for continuous beams, trusses, frames, and frames with truss members.

## Prerequisites

* MATLAB R2019a or later
* Symbolic Math Toolbox



## Usage

1. **Define Global Degrees of Freedom (DOFS)**

   ```matlab
   % Continuous beam example
   global DOFS;
   DOFS = [false, true, true];  % [Fx, Fy, Rz]
   ```
2. **Create Nodes**

   ```matlab
   % Node(index, x, y, 'constraint', 'fixed', 'f', [magnitude, angle]);
   n1 = NODES(1, 0, 0, 'constraint','fixed');
   n2 = NODES(2, 5, 0, 'constraint','simple');
   ```
3. **Define Cross-Sections**

   ```matlab
   % tempcross(E, A, 'I', I, 'Aeq', Aeq)
   cs = tempcross(80e9, 7.7, 'I', 131.14e-6, 'Aeq', 2.8356);
   ```
4. **Create Members**

   ```matlab
   m1 = member(n1, n2, cs);
   ```
5. **Apply Loads**

   ```matlab
   % Concentrated force at 2 m, magnitude 100 N upward in global axes
   lf = con_fm(m1, 2, 100, 'up', 'g');
   m1.loads{end+1} = lf;
   ```
6. **Run Solver and Plot Results**

   ```matlab
   [Ar, D_allowed, D_all, members] = Final_Solver({m1}, {n1, n2}, m1.loads);
   for k = 1:length(members)
       mem_plot(members{k}, D_all);
   end
   ```

## File Structure

```
├── NODES.m               % Node class definition
├── member.m              % General member class
├── truss_member.m        % Truss-only member class
├── sing.m                % Singularity base function
├── s_rec.m               % Rectangular load singularity
├── s_tri.m               % Triangular load singularity
├── con_fm.m              % Concentrated force class
├── con_m.m               % Concentrated moment class
├── rec.m                 % Rectangular distributed load class
├── n_tri.m               % Triangular distributed load class
├── rev_tri.m             % Reverse triangular load class
├── getAml.m              % Reaction solver (Castigliano’s method)
├── Final_Solver.m        % Main analysis engine
├── mem_plot.m            % Post-processing and plotting
├── tempcross.m           % Cross-section class
└── examples/             % Example scripts for various problem types
```

## Examples

* **Continuous Beam**: `continuous_beam_example.mlx`
* **Truss**: `truss_example.mlx`
* **Frame**: `frame_example.mlx`
* **Frame with Truss Member**: `frame_truss_example.mlx`

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a pull request.

