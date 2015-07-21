clear;
% ran with version 7.3

% TO RUN THE LATIN HYPERCUBE script %
addpath('/home/febbo/UDDS_316/Optimization/Latin Hypercube/')

n = 800;
weight_LHC = 0;            % No variable emissions weights
RUN_TYPE.emiss_on = 1;     % Emissions at nominal values
RUN_TYPE.battery = 1;      % Flag to turn on and off the battery as a DV
cyc_name = 'UDDS';

RUN_TYPE.soc_size = 0.001;
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
weight.shift = 1.5;
weight.engine_event = 10*vinf.fc_max_pwr_initial_kW/41;  % also scaled by dvar.fc_trq, can do inside DP or at each evaluation...
weight.clutch_event = 0.5;
weight.infeasible = 200;
weight.CS = 91000;
weight.SOC_final = 500;

% define the center of the design space
dvar.FD = 8.45;
dvar.G = 1.7;
dvar.fc_trq_scale = 0.97;
dvar.mc_trq_scale = 1;
dvar.module_number = 19;

% small DV range
x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale,floor(0.5*dvar.module_number)]';
x_U=[    2*dvar.FD, 2*dvar.G,     1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale,floor(1.5*dvar.module_number)]';

LHC;