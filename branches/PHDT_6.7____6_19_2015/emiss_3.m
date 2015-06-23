clear
close all
clc
tic
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Define the Run Type-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
RUN_TYPE.sim = 0;        % RUN_TYPE = 1 - for DIRECT     &    RUN_TYPE = 0 - for DP only
RUN_TYPE.emiss_data = 1; % RUN_TYPE.emiss = 1 - maps have emissions  &   RUN_TYPE.emiss = 0 - maps do not have emissions
RUN_TYPE.emiss_on = 1;   % to turn of and on emissions
RUN_TYPE.plot = 0;       % RUN_TYPE.plot = 1 - plots on  &   RUN_TYPE.plot = 0 - plots off
RUN_TYPE.soc_size = 0.00005;
RUN_TYPE.trq_size = 0.05;   % Nm
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------Weighing Parameters for DP------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
weight.fuel = 1*1.4776/1.4776;  % these are for a specific engine; NEED to change this!!
if RUN_TYPE.emiss_data == 1     % whether or not the engine maps have emissions data
    if RUN_TYPE.emiss_on == 0
        weight.NOx = 0*1.4776/0.0560;
        weight.CO = 0*1.4776/0.6835;
        weight.HC = 0*1.4776/0.0177;
        RUN_TYPE.folder_name = 'main - no emiss';
    else
        weight.NOx = 2*1.4776/0.0560;
        weight.CO = 0.6*1.4776/0.6835;
        weight.HC = 4*1.4776/0.0177;
        RUN_TYPE.folder_name = 'main - emiss';
    end
else
    RUN_TYPE.folder_name = 'main - no emiss data';
end

RUN_names = fieldnames(RUN_TYPE);
RUN_data = struct2cell(RUN_TYPE);

weight.shift = 1;
weight.engine_event = 10;
weight.clutch_event = 4;
weight.infeasible = 200;  
weight.CS = 91000;
weight.SOC_final = 500;

weight_names = fieldnames(weight);
weight_data = struct2cell(weight);
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
% Engine_102_kW;
% Engine_186_kW;
% Engine_224_kW;

%                              ~~ Motor ~~
% Motor_int;
% Motor_75_kW;
% Motor_30_kW;
% Motor_49_kW;
% Motor_10_kW;
% Motor_8_kW;
% Motor_16_kW;
Motor_25_kW;

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
dvar.FD = 5.65;
dvar.G = 1.1;
dvar.fc_trq_scale = 1.065;
dvar.mc_trq_scale = 0.9;
dvar.module_number = 15;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Update the Data-------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
Manipulate_Data_Structure;
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

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%----------------Simulate-------------------------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[FAIL, MPG, emission, delta_SOC, sim] = Dynamic_Programming_func(param, vinf, dvar, cyc_data, RUN_TYPE, weight);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%-----------------------Final Plots ect.----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%%

if RUN_TYPE.plot == 1 || RUN_TYPE.save == 1
    cd('Plots')
    Main_Plot;
    Engine_Plot;
    Torque_Check;
    Speed_Check;
    Motor_Plot;
    Cost_Plot;
    Battery_Plot;
    if RUN_TYPE.emiss_on == 1
        Engine_NOx_Plot;
        Engine_HC_Plot;
        Engine_CO_Plot;
    end
    cd ..
    if RUN_TYPE.save == 1
        cd('temp')
        if Matlab_ver >= 2015
            t = datetime;
            t.Format = 'eeee, MMMM d, yyyy';
            name = strcat(RUN_TYPE.folder_name,char(t));
        else
            name = strcat(RUN_TYPE.folder_name);
        end
        
        check_exist = exist(fullfile(cd,name),'dir');
        if check_exist == 7
            rmdir(name,'s')                 % Delete any left over info
        end
        mkdir(name)
        cd(name)
        
        eval(['save(''','MPG',''',','''MPG'');'])
        eval(['save(''','emission',''',','''emission'');'])
        eval(['save(''','FAIL',''',','''FAIL'');'])
        eval(['save(''','sim',''',','''sim'');'])
        eval(['save(''','delta_SOC',''',','''delta_SOC'');'])
        
        savefig(h1, 'main.fig')
        savefig(h2, 'fuel.fig')
        savefig(h3, 'torque_check.fig')
        savefig(h4, 'speed_check.fig')
        savefig(h5, 'motor.fig')
        savefig(h6, 'cost.fig')
        savefig(h7, 'battery.fig')
        savefig(h8, 'NOx.fig')
        savefig(h9, 'HC.fig')
        savefig(h10, 'NOx.fig')
        cd ..
        cd ..  % Back in the main folder
    end
end

MPG
delta_SOC
if RUN_TYPE.emiss_data == 1
    emission
end
FAIL.final