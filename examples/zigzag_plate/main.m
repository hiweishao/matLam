close all
clear all

include_folder = '../../include';
addpath(genpath(include_folder));

model = modelSetup();

msh   = makeMesh(model);

K = computeGlobalStiffness(model,msh);

% Apply boundary conditions

msh.lhs = find(msh.coords(:,1) < 1e-6);
msh.rhs = find(msh.coords(:,1) > model.Lx - 1e-6);

bnd_left  = [msh.lhs; msh.lhs + msh.nnod; msh.lhs + 2 * msh.nnod; msh.lhs + 3 * msh.nnod; msh.lhs + 4 * msh.nnod; msh.lhs + 5 * msh.nnod; msh.lhs + 6 * msh.nnod];
bnd_right = [msh.rhs; msh.rhs + msh.nnod; msh.rhs + 2 * msh.nnod; msh.rhs + 3 * msh.nnod; msh.rhs + 4 * msh.nnod; msh.rhs + 5 * msh.nnod; msh.rhs + 6 * msh.nnod];

bnd = [bnd_left; bnd_right];

free = 1 : msh.tdof; free(bnd) = [];

% Solve the problem

U1 = zeros(msh.tdof,1); U0 = zeros(msh.tdof,1);

t = 0.0;

for i = 1 : model.timesteps
    
    t = t + model.dt;

    U1(msh.rhs + 2 * msh.nnod) = model.A * sin(model.omega * t);

    U1(free) = K(free,free) \ (-K(free,bnd) * U1(bnd));

    % Plot Solution

    scalar_point.name = 'displacement';
    scalar_point.data = U1(2*msh.nnod + 1: 3*msh.nnod);

    matlab2vtk(strcat(model.vtk_filename_base,int2str(i),'.vtk'),'DMTA', msh, 'quad', [], scalar_point, []);

end

