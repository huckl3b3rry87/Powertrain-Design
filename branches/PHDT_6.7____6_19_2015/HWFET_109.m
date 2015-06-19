clear;
% ran with version 6.4

% TO RUN THE LATIN HYPERCUBE script %
addpath('/home/febbo/HWFET_109/Optimization/Latin Hypercube/')

n = 1000;
weight_LHC = 0;            % No variable emissions weights
RUN_TYPE.emiss_on = 1;     % Emissions at nominal values
RUN_TYPE.battery = 1;      % Flag to turn on and off the battery as a DV
cyc_name = 'HWFET';

RUN_TYPE.soc_size = 0.001;
RUN_TYPE.trq_size = 5;     % Nm
weight.shift = 1;
weight.engine_event = 10;
weight.infeasible = 200;
weight.CS = 91000;
weight.SOC_final = 500;
data_universal;
cd('Components');
Motor_25_kW;
Vehicle_Parameters_small_car_plus;
cd ..

dvar.FD = 5.665;
dvar.G = 1.1;
dvar.fc_trq_scale = 1.095;
dvar.mc_trq_scale = 1.4;
dvar.module_number = 23;
% big DV range
% x_L=[    0.2*dvar.FD, 0.1*dvar.G, 0.15*dvar.fc_trq_scale, 0.15*dvar.mc_trq_scale,floor(0.15*dvar.module_number)]';
% x_U=[    2.5*dvar.FD, 2*dvar.G,     2*dvar.fc_trq_scale, 2*dvar.mc_trq_scale,floor(2*dvar.module_number)]';

% small DV range
x_L=[    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale,floor(0.5*dvar.module_number)]';
x_U=[    2*dvar.FD, 2*dvar.G,     1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale,floor(1.5*dvar.module_number)]';

LHC;