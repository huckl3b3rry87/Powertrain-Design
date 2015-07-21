clear
close all
clc
tic
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Check Matlab Version------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
version -release;
Matlab_ver = str2num(ans(1:4)); %#ok<NOANS,ST2NM>
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Define the Run Type-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
RUN_TYPE.sim = 0;        % RUN_TYPE = 1 - for DIRECT     &    RUN_TYPE = 0 - for DP only
RUN_TYPE.emiss_data = 1; % RUN_TYPE.emiss = 1 - maps have emissions  &   RUN_TYPE.emiss = 0 - maps do not have emissions
RUN_TYPE.emiss_on = 1;   % to turn of and on emissions
RUN_TYPE.plot = 0;       % RUN_TYPE.plot = 1 - plots on  &   RUN_TYPE.plot = 0 - plots off
RUN_TYPE.save = 1;       % to save results
RUN_TYPE.FLUX = 0;       % if it is running on flux, there is no display
if RUN_TYPE.FLUX == 1; RUN_TYPE.sim = 1; end % do not want to continuously print the current time to an output file
RUN_TYPE.soc_size = 0.001;
RUN_TYPE.trq_size = 5;   % Nm
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%----------------------------Load All Data--------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
data_universal;
cd('Components');
%                              ~~ Engine ~~
% Engine_30_kW;
Engine_41_kW_manip;
% Engine_41_kW_low_spd;
% Engine_41_kW_smooth;
% Engine_50_kW;
% Engine_73_kW;
% Engine_95_kW;
% Engine_103_kW;
% Engine_186_kW;
% Engine_224_kW;

%                              ~~ Motor ~~
% Motor_int;
% Motor_75_kW;
Motor_30_kW;
% Motor_49_kW;
% Motor_10_kW;
% Motor_8_kW;
% Motor_16_kW;
% Motor_25_kW;

%                             ~~ Battery ~~
% Battery_int;  % No variation with the number of modules in this battery!!
Battery_ADVISOR;

%                              ~~ Vehicle ~~
% Vehicle_Parameters_small_car;
% Vehicle_Parameters_small_car_1_gear;
Vehicle_Parameters_small_car_plus;
% Vehicle_Parameters_Truck;
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
%-------------------Put all the data into structures----------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
data;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Update the Design Variables-------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
dvar.FD = 5.445;
dvar.G = 1.3;
dvar.fc_trq_scale = 1.065;
dvar.mc_trq_scale = 1.05;
dvar.module_number = 20;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Update the Data-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
Manipulate_Data_Structure;         % run before drive cycle to get new vehicle mass
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Select Drive Cycle----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                             ~~ Standard ~~
% cyc_name = 'HWFET';
cyc_name = 'UDDS';
% cyc_name = 'US06';
% cyc_name = 'SHORT_CYC_HWFET';
% cyc_name = 'RAMP_slower';
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
%                             ~~ Other ~~
% cyc_name = 'accel_1';

[cyc_data] = Drive_Cycle(param, vinf, cyc_name);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Weighing Parameters for DP------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
weight.fuel = 1;  
if RUN_TYPE.emiss_data == 1     % whether or not the engine maps have emissions data
    if RUN_TYPE.emiss_on == 0
        weight.NOx = 0;
        weight.CO = 0;
        weight.HC = 0;
        RUN_TYPE.folder_name = 'main - no emiss';
    else
        weight.NOx = 2*vinf.ave_fuel/vinf.ave_NOx;
        weight.CO = 0.6*vinf.ave_fuel/vinf.ave_CO;
        weight.HC = 4*vinf.ave_fuel/vinf.ave_HC;
   
        RUN_TYPE.folder_name = 'main- nominal';
    end
else
    RUN_TYPE.folder_name = 'main - no emiss data';
end

RUN_names = fieldnames(RUN_TYPE);
RUN_data = struct2cell(RUN_TYPE);

weight.shift = 1;
weight.engine_event = 10*vinf.fc_max_pwr_initial_kW/41;  % also scaled by dvar.fc_trq, can do inside DP or at each evaluation...
weight.clutch_event = 0.3;
weight.infeasible = 200;
weight.CS = 91000;
weight.SOC_final = 500;

weight_names = fieldnames(weight);
weight_data = struct2cell(weight);
%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%----------------Simulate-------------------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[FAIL, MPG, emission, delta_SOC, sim] = Dynamic_Programming_func(param, vinf, dvar, cyc_data, RUN_TYPE, weight);

%% final plots and save
Final_Plots;