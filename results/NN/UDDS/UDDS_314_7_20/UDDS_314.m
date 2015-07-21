clear;
% ran with version 7.3

% TO RUN THE LATIN HYPERCUBE script %
addpath('/home/febbo/UDDS_314/Optimization/Latin Hypercube/')

n = 750;
weight_LHC = 0;            % No variable emissions weights
RUN_TYPE.emiss_on = 1;     % Emissions at nominal values
RUN_TYPE.battery = 1;      % Flag to turn on and off the battery as a DV
cyc_name = 'UDDS';

RUN_TYPE.soc_size = 0.005;
RUN_TYPE.trq_size = 5;     % Nm

data_universal;

% define components
cd('Components');
Engine_102_kW;
Motor_30_kW;
Vehicle_Parameters_Truck;
Battery_ADVISOR;
cd ..

% put all the data into structures and cells
data;

% define weighing parameters for DP
weight.shift = 1;
weight.engine_event = 10*vinf.fc_max_pwr_initial_kW/41;  % also scaled by dvar.fc_trq, can do inside DP or at each evaluation...
weight.clutch_event = 2;
weight.infeasible = 200;
weight.CS = 91000;
weight.SOC_final = 500;

% define the center of the design space
dvar.FD = 8.45;
dvar.G = 1.7;
dvar.fc_trq_scale = 0.97;
dvar.mc_trq_scale = 1;
dvar.module_number = 19;

% big DV range
% x_L=[    0.2*dvar.FD, 0.1*dvar.G, 0.15*dvar.fc_trq_scale, 0.15*dvar.mc_trq_scale,floor(0.15*dvar.module_number)]';
% x_U=[    2.5*dvar.FD, 2*dvar.G,     2*dvar.fc_trq_scale, 2*dvar.mc_trq_scale,floor(2*dvar.module_number)]';

% small DV range
x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.25*dvar.mc_trq_scale,floor(0.25*dvar.module_number)]';
x_U=[    2*dvar.FD, 2*dvar.G,     1.5*dvar.fc_trq_scale, 1.75*dvar.mc_trq_scale,floor(1.75*dvar.module_number)]';

LHC;