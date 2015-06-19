Test # 203.a
n = 1000;
weight_LHC = 0;            % No variable emissions weights
RUN_TYPE.emiss_on = 1;     % Emissions at nominal values
RUN_TYPE.battery = 1;      % Flag to turn on and off the battery as a DV

Motor_10_kW;
Vehicle_Parameters_small_car;
dvar.FD = 5.495;
dvar.G = 1.4;
dvar.fc_trq_scale = 0.77;
dvar.mc_trq_scale = 1.2;
dvar.module_number = 8;

 x_L=[    0.4*dvar.FD, 0.4*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale,floor(0.5*dvar.module_number)]';
 x_U=[    2*dvar.FD, 2*dvar.G,     1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale,floor(1.5*dvar.module_number)]';
