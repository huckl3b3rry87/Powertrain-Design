%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%--------------------------Genetic Algorithm------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clear;     % Clear the workspace
close all; % Close all windows
clc
tic
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Define the Run Type-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
RUN_TYPE.sim = 1;  % RUN_TYPE = 1 - for DIRECT     &    RUN_TYPE = 0 - for DP only
RUN_TYPE.emiss_data = 1; % RUN_TYPE.emiss = 1 - maps have emissions  &   RUN_TYPE.emiss = 0 - maps do not have emissions
RUN_TYPE.emiss_on = 1;  % This is to turn of and on emissions
RUN_TYPE.plot = 0;  % RUN_TYPE.plot = 1 - plots on  &   RUN_TYPE.plot = 0 - plots off
RUN_TYPE.soc_size = 0.001;
RUN_TYPE.trq_size = 5;  % Nm
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Weighing Parameters for DP------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
weight.fuel = 1*1.4776/1.4776;  % These are for a specific engine, we need to change this!
if RUN_TYPE.emiss_data == 1  % This is just saying wheither or not the engine maps have emissions data
    if RUN_TYPE.emiss_on == 0
        weight.NOx = 0*1.4776/0.0560;
        weight.CO = 0*1.4776/0.6835;
        weight.HC = 0*1.4776/0.0177;
        RUN_TYPE.folder_name = '_GA-no emiss_';
    else 
        weight.NOx = 2*1.4776/0.0560;
        weight.CO = 0.6*1.4776/0.6835;
        weight.HC = 4*1.4776/0.0177;
        RUN_TYPE.folder_name = '_GA-emiss_';  
    end
end

RUN_names = fieldnames(RUN_TYPE);
RUN_data = struct2cell(RUN_TYPE);

weight.shift = 1;
weight.engine_event = 10;
weight.infeasible = 200;
weight.CS = 91000;
weight.SOC_final = 500;

weight_names = fieldnames(weight);
weight_data = struct2cell(weight);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%----------------------------Load All Data--------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
cd('Components');
%                              ~~ Engine ~~
% Engine_30_kW;
Engine_41_kW_manip;
% Engine_41_kW_smooth;
% Engine_50_kW;
% Engine_73_kW;
% Engine_95_kW;
% Engine_102_kW;
% Engine_186_kW;
% Engine_224_kW;

%                              ~~ Motor ~~
% Motor_int;
% Motor_75_kW;
% Motor_30_kW;
Motor_49_kW;
% Motor_10_kW;
% Motor_8_kW;
% Motor_16_kW;

%                             ~~ Battery ~~
% Battery_int;  % No variation with the number of modules in this battery!!
Battery_ADVISOR;

%                              ~~ Vehicle ~~
Vehicle_Parameters_small_car;
% Vehicle_Parameters_4_HI_AV;
% Vehicle_Parameters_4_HI;
% Vehicle_Parameters_8_HI_AV;
% Vehicle_Parameters_8_HI;

% Low Speed
% Vehicle_Parameters_4_low_AV;
% Vehicle_Parameters_4_low;
% Vehicle_Parameters_1_low_AV;
% Vehicle_Parameters_1_low;

cd ..
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-------------Put all the data into structures and cells------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
data;
param_names = fieldnames(param);
param_data = struct2cell(param);
vinf_names = fieldnames(vinf);
vinf_data = struct2cell(vinf);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Update the Design Variables-------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~d%
dvar.FD = 5.495;
dvar.G = 1.4;
dvar.fc_trq_scale = 0.78;
dvar.mc_trq_scale = 1.2;
mc_max_pwr_kW =  dvar.mc_trq_scale*vinf.mc_max_pwr_kW;
dvar.module_number = ceil(4*mc_max_pwr_kW*1000*Rint_size/(Voc_size^2));
dvar.module_number = 38;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Update the Data-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
Manipulate_Data_Structure;  % May not have to do this here
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Select Drive Cycle----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                              ~~ Standard ~~
cyc_name = 'HWFET';
% cyc_name = 'UDDS';
% cyc_name = 'US06';
% cyc_name = 'SHORT_CYC_HWFET';
% cyc_name = 'RAMP';
% cyc_name = 'LA92';
% cyc_name = 'CONST_65';
% cyc_name = 'CONST_45';
% cyc_name = 'COMMUTER';

% City
% cyc_name = 'INDIA_URBAN';
% cyc_name = 'MANHATTAN';
% cyc_name = 'Nuremberg';
% cyc_name = 'NYCC';
% cyc_name = 'AA_final';
%                              ~~ AV~~

% cyc_name = 'US06_AV';
% cyc_name = 'HWFET_AV';
% cyc_name = 'AA_final_AV';

[cyc_data] = Drive_Cycle(param, vinf, cyc_name);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Run Optimization------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Identify the Design Variables and their ranges    
dv_names = { 'FD', 'G','fc_trq_scale','mc_trq_scale'};
x_L = [    0.5*dvar.FD, 0.5*dvar.G, 0.5*dvar.fc_trq_scale, 0.5*dvar.mc_trq_scale]';
x_U = [    1.5*dvar.FD, 1.5*dvar.G, 1.5*dvar.fc_trq_scale, 1.5*dvar.mc_trq_scale]';
nvars = length(x_L); % Number of Deisgn Variables

ini=[dvar.FD,dvar.G,dvar.fc_trq_scale,dvar.mc_trq_scale]; % Use GOOD and FEASIBLE Initial Guess

% Objective Function
vfun=@(dvar)objective(dvar,param_names, param_data, vinf_names, vinf_data, cyc_name, RUN_names, RUN_data, weight_names, weight_data);

% Constraint Function
nonlcon=@(dvar)constraint(dvar,param_names, param_data, vinf_names, vinf_data, cyc_name, RUN_names, RUN_data, weight_names, weight_data );

% To Check Feasibility
% [gineq,geq] = nonlcon(ini);  


%% GA Option Settings
populations=10; % Population Size
generations=30; % Number of Generations
time = 60;    % Time in (s)
stall_gen = 150;
tol = 1e-3; % Average Change in the Spread of Pareto Solutions ( termination criteria )
options = gaoptimset('Vectorized','off','InitialPopulation',ini,'TolFun',tol,'PopulationSize',populations,'Generations',generations,'StallGenLimit', stall_gen,'TimeLimit',time,'PlotFcns',{@gaplotbestf});

% Run The Optimization
[x,fval,exitflag,output] = ga(vfun,nvars,[],[],[],[],x_L,x_U,nonlcon,options);
fprintf('The number of generations was : %d\n', output.generations);
fprintf('The number of function evaluations was : %d\n', output.funccount);
fprintf('The best function value found was : %g\n', fval);


% Save the Results
t = datetime;
t.Format = 'eeee, MMMM d, yyyy';
name = strcat(RUN_TYPE.folder_name,char(t));

cd('results')  % The Folder that has all of the results
mkdir(name)
cd(name)
eval(['save(''','output',''',','''output'');'])
eval(['save(''','dv',''',','''x'');'])
eval(['save(''','obj',''',','''fval'');'])
cd ..
toc
