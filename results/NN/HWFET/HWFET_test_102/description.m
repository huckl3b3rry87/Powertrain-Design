Test# 102
addpath('/home/febbo/LHC_HWFET_10kW/Optimization/Latin Hypercube/')

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

Motor_10_kW;

Vehicle_Parameters_small_car;

dvar.FD = 5.495;
dvar.G = 1.4;
dvar.fc_trq_scale = 0.77;
dvar.mc_trq_scale = 1.2;
% mc_max_pwr_kW =  dvar.mc_trq_scale*vinf.mc_max_pwr_kW;
% dvar.module_number = ceil(4*mc_max_pwr_kW*1000*Rint_size/(Voc_size^2));
dvar.module_number = 8;

  x_L=[    0.4*dvar.FD, 0.4*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale,floor(0.5*dvar.module_number)]';
  x_U=[    2*dvar.FD, 2*dvar.G,     1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale,floor(1.5*dvar.module_number)]';
