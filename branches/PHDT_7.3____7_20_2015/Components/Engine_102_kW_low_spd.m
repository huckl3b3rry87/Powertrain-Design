% ADVISOR Data file:  FC_SI102_emis.m
%
% Data source: Dill Murrell, JDM Associates, under contract to 
% Argonne National Laboratory. FTP Revision Project. 
%
% Data confidence level:  
%
% Notes: 
% This file loads the variables associated with a Dodge Caravan engine,
% a 3.0 L, 6-cyl., 136 hp, 1991 model year.
% Maximum Power 102 kW @ 4875 rpm
% Peak Torque 217 Nm @ 4143 rpm
%
% WARNING:  This data comes from transient testing on the FTP and is
% only appropriate to model transient-operation engines.
%
% Created on:  06/23/98
% By:  Tony Markel, National Renewable Energy Laboratory, Tony_Markel@nrel.gov
%
% Revision history at end of file.
a = 1.05;
fig_on = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPEED & TORQUE RANGES over which data is defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (rad/s), speed range of the engine
eng_consum_spd =[0 128.8 190.7 249 310.5 338.7 366.9 433.9 471.8 510.5];
eng_consum_spd_old = eng_consum_spd;
% (N*m), torque range of the engine
eng_consum_trq =  [0 27.1 40.6 54.2 67.7 81.3 94.8 108.4 122 135.5 149.1 162.6 176.2 ...
      189.7 203.3 216.9];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUEL USE AND EMISSIONS MAPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (g/s), fuel use map indexed vertically by fc_map_spd and 
% horizontally by fc_map_trq
eng_bsfc = [
436.14	421.94	407.74	393.54	393.54	393.54	393.54	393.54	393.54	393.54	393.54	393.54	393.54	393.54	393.54
400.86	386.66	372.46	358.26	344.07	329.87	315.67	301.47	301.47	301.47	301.47	301.47	301.47	301.47	301.47
363.32	363.32	352.92	347.72	342.52	332.13	326.93	321.73	311.33	306.13	300.93	288.46	288.46	288.46	288.46
384.94	384.94	384.94	368.08	351.22	337.93	333.63	329.33	323.58	321.79	320   	319.91	319.83	401.06	401.06
395.25	395.25	395.25	370.95	346.65	325.11	319.32	313.54	311.03	314.14	317.25	328.48	339.71	412.22	412.22
405.56	405.56	405.56	373.82	342.08	312.28	305.02	297.75	298.49	306.49	314.5 	337.04	359.59	423.38	423.38
406.85	406.85	406.85	394.57	382.3	   371.68	369.71	367.74	370.48	375.2  	379.91	391.39	402.87	420.29	437.71
592.04	592.04	554.46	516.87	460.66	442.04	423.41	413.32	403.23	410.21	423.18	436.14	488.45	488.45	488.45
731.92	731.92	572.15	539.11	506.07	477.45	472.51	467.57	468.93	470.29	476.89	483.5 	483.5 	483.5 	483.5];

eng_bsfc = [a*ones(size(eng_bsfc(:,1)))*max(max(eng_bsfc)), eng_bsfc];  % add in a column for zero torque
eng_bsfc = [a*ones(size(eng_bsfc(1,:)))*max(max(eng_bsfc)); eng_bsfc];  % add in a column for zero speed


% (g/s), engine out HC emissions indexed vertically by fc_map_spd and
% horizontally by fc_map_trq
fc_hc_map_gpkWh = [
6.12	5.92	5.72	5.52	5.52	5.52	5.52	5.52	5.52	5.52	5.52	5.52	5.52	5.52	5.52
5.68	5.48	5.27	5.07	4.87	4.67	4.47	4.27	4.27	4.27	4.27	4.27	4.27	4.27	4.27
3.76	3.76	3.76	3.76	3.76	3.76	3.76	3.76	3.76	3.76	3.76	3.44	3.44	3.44	3.44
4.07	4.07	4.07	4  	3.93	3.83	3.78	3.73	3.63	3.585	3.54	3.5	3.46	4.4	4.4
4.23	4.23	4.23	4.035	3.84	3.63	3.56	3.49	3.41	3.405	3.4	3.46	3.52	4.24	4.24
4.39	4.39	4.39	4.07	3.75	3.43	3.335	3.24	3.19	3.23	3.27	3.425	3.58	4.07	4.07
3.53	3.53	3.53	3.645	3.76	3.8	3.795	3.79	3.76	3.76	3.76	3.82	3.88	4.06	4.24
3.86	3.86	2.11	0.36	1.07	1.64	2.21	2.885	3.56	4.26	4.445	4.63	4.63	4.63	4.63
1.66	1.66	2.13	2.36	2.59	3.06	3.29	3.52	3.83	4.14	4.45	4.76	4.76	4.76	4.76];

fc_hc_map_gpkWh = [a*ones(size(fc_hc_map_gpkWh(:,1)))*max(max(fc_hc_map_gpkWh)), fc_hc_map_gpkWh];
fc_hc_map_gpkWh = [a*ones(size(fc_hc_map_gpkWh(1,:)))*max(max(fc_hc_map_gpkWh)); fc_hc_map_gpkWh];  % add in a column for zero speed

% (g/s), engine out CO emissions indexed vertically by fc_map_spd and
% horizontally by fc_map_trq
fc_co_map_gpkWh = [
30.88	31.6	32.32	33.04	 33.04 33.04  33.04	33.04	 33.04	33.04	  33.04	33.04	 33.04  33.04   33.04
27.19	27.91	28.62	29.34  30.06 30.78  31.5	32.21	 32.21	32.21	  32.21	32.21	 32.21  32.21   32.21
49.9	49.9	48.09	46.825 45.56 42.31  40.32	38.33	 33.63	30.92	  28.21	20.76	 20.76  20.76   20.76
29.83	29.83	29.83	33.35	 36.87 34.51  30.87	27.23	 17.93	15.455  12.98	30.53	 48.08  361.62  361.62
40.07	40.07	40.07	43.235 46.4	 36.39  29.895	23.4	 16.84	22.35	  27.86	64.495 101.13 359.17  359.17
50.32	50.32	50.32	53.125 55.93 38.27  28.92	19.57	 15.75	29.245  42.74	98.46	 154.18 356.71  356.71
23.36	23.36	23.36	29.575 35.79 57.71  74.075	90.44	 133.98	161.145 188.31	232.94 277.57 331.805 386.04
42.98	42.98	34.9	26.82  23.41 28.08  32.75	48.89	 65.03	402.14  402.14	402.14 402.14 402.14  402.14
34.8	34.8	26.82	25.115 23.41 100.74 174.64	248.54 337.135	425.73  456.71	487.69 487.69 487.69  487.69];

fc_co_map_gpkWh = [a*ones(size(fc_co_map_gpkWh(:,1)))*max(max(fc_co_map_gpkWh)), fc_co_map_gpkWh];
fc_co_map_gpkWh  = [a*ones(size(fc_co_map_gpkWh(1,:)))*max(max(fc_co_map_gpkWh)); fc_co_map_gpkWh];  % add in a column for zero speed

% (g/s), engine out NOx emissions indexed vertically by fc_map_spd and
% horizontally by fc_map_trq
fc_nox_map_gpkWh = [
16.82	16.85	16.88	 16.91	16.91	16.91	 16.91	16.91	16.91	16.91	 16.91 16.91  16.91	16.91	16.91
18	   18.08	18.15	 18.23	18.3	18.38	 18.45	18.53	18.53	18.53	 18.53 18.53  18.53	18.53	18.53
10.66	10.66	16.54	 18.71	20.88	23.69	 24.325	24.96	24.7	23.8	 22.9	 18.71  18.71	18.71	18.71
21.61	21.61	21.61	 24.37	27.13	29.08	 29.11	29.14	27.33	25.485 23.64 19.715 15.79	5.88	5.88
22.05	22.05	22.05	 24.275	26.5	27.85	 27.67	27.49	25.44	23.565 21.69 17.86  14.03	4.56	4.56
22.48	22.48	22.48	 24.17	25.86	26.61	 26.23	25.85	23.55	21.645 19.74 16.01  12.28	3.25	3.25
26.75	26.75	26.75	 26.915	27.08	27.33	 27.44	27.55	27.73	17.27	 6.81	 4.845  2.88	2.97	3.06
27.63	27.63	27.255 26.88	26.13	25.745 25.36	24.82	24.28	6.72	 4.84	 2.96	  3.02	3.02	3.02
17.05	17.05	16.09	 15.42	14.75	13.03	 11.975	10.92	9.22	7.52	 5.485 3.45	  3.45	3.45	3.45];

fc_nox_map_gpkWh  = [a*ones(size(fc_nox_map_gpkWh(:,1)))*max(max(fc_nox_map_gpkWh)), fc_nox_map_gpkWh];
fc_nox_map_gpkWh  = [a*ones(size(fc_nox_map_gpkWh(1,:)))*max(max(fc_nox_map_gpkWh)); fc_nox_map_gpkWh];  % add in a column for zero speed

% (g/s), engine out PM emissions indexed vertically by fc_map_spd and
% horizontally by fc_map_trq
fc_pm_map_gpkWh=zeros(size(eng_bsfc));

% (g/s), engine out O2 indexed vertically by fc_map_spd and
% horizontally by fc_map_trq
fc_o2_map=zeros(size(eng_bsfc));

% convert g/kWh to g/s
[T,w]=meshgrid(eng_consum_trq, eng_consum_spd);
fc_map_kW = T.*w/1000;   % To kW
eng_consum_fuel=  eng_bsfc.*fc_map_kW/3600;
eng_consum_fueleng_consum_fuel_raw = eng_consum_fuel;
fc_co_map=  fc_co_map_gpkWh.*fc_map_kW/3600;
fc_nox_map= fc_nox_map_gpkWh.*fc_map_kW/3600;
fc_hc_map= fc_hc_map_gpkWh.*fc_map_kW/3600;
fc_pm_map= fc_pm_map_gpkWh.*fc_map_kW/3600;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIMITS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (N*m), max torque curve of the engine indexed by fc_map_spd
eng_max_trq= [67.8 67.8 122.0 187.1 214.2 214.2 214.2 216.9 199.3 199.3];
eng_map_spd = eng_consum_spd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STUFF THAT SCALES WITH TRQ & SPD SCALES (MASS AND INERTIA)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fc_max_pwr=(max(eng_map_spd.*eng_max_trq)/1000); % kW     peak engine power

fc_base_mass=1.8*fc_max_pwr;            % (kg), mass of the engine block and head (base engine)
                                        %       mass penalty of 1.8 kg/kW from 1994 OTA report, Table 3 
fc_acc_mass=0.8*fc_max_pwr;             % kg    engine accy's, electrics, cntrl's - assumes mass penalty of 0.8 kg/kW (from OTA report)
fc_fuel_mass=0.6*fc_max_pwr;            % kg    mass of fuel and fuel tank (from OTA report)
fc_mass=fc_base_mass+fc_acc_mass+fc_fuel_mass; % kg  total engine/fuel system mass

fc_max_pwr_initial_kW = 102;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OTHER DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fc_fuel_den=0.749*1000; % (g/l), density of the fuel 
% fc_fuel_lhv=42.6*1000; % (J/g), lower heating value of the fuel

% figure; clf;
% [C,h] = contourf(eng_consum_spd*rads2rpm, eng_consum_trq, eng_bsfc', [216 300:10:350, 275, 350:25:800]);
% clabel(C,h, 'fontsize', 8);
% hold on;
% plot(eng_map_spd*rads2rpm, eng_max_trq, 'k', 'linewidth', 2);

% plot(We_optbsfc*rads2rpm, Te_optbsfc, 'ro-', 'markersize', 3, 'markerf', 'r');

%% ==============================
% figure; clf;
% mesh(eng_consum_spd, eng_consum_trq, eng_bsfc');
% xlabel('Spd');
% ylabel('Trq')
% zlabel('BSFC (g/kWh)');

%% ==============================
% figure; clf;
% mesh(eng_consum_spd, eng_consum_trq, eng_consum_fuel_raw');
% xlabel('Spd');
% ylabel('Trq')
% zlabel('Fuel Rate (g/s)');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Define all Variables for DP
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
W_eng_min = 0;  % changed to let the engine opperate at low speeds
W_eng_max = max(eng_consum_spd); 
Te_min =  eng_consum_trq(1); % careful here..
ave_fuel = mean(mean(eng_bsfc));
ave_NOx = mean(mean(fc_nox_map_gpkWh));
ave_HC = mean(mean(fc_hc_map_gpkWh));
ave_CO = mean(mean(fc_co_map_gpkWh));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Define all Variables for DP
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

if fig_on == 1
    %% ==============================
    figure; clf;
    mesh(eng_consum_spd, eng_consum_trq, eng_bsfc');
    xlabel('Spd');
    ylabel('Trq')
    zlabel('BSFC (g/kWh)');
    
    %% ==============================
    figure; clf;
    mesh(eng_consum_spd, eng_consum_trq,fc_hc_map_gpkWh');
    xlabel('Spd');
    ylabel('Trq')
    zlabel('HC(g/kWh)');
    
    %% ==============================
    figure; clf;
    mesh(eng_consum_spd, eng_consum_trq,fc_co_map_gpkWh');
    xlabel('Spd');
    ylabel('Trq')
    zlabel('CO(g/kWh)');
    %% ==============================
    figure; clf;
    mesh(eng_consum_spd, eng_consum_trq,fc_nox_map_gpkWh');
    xlabel('Spd');
    ylabel('Trq')
    zlabel('N0_x(g/kWh)');
    
end