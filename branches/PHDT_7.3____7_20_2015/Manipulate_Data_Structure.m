% Motor
vinf.m_map_trq = dvar.mc_trq_scale*vinf.m_map_trq_orig;
vinf.m_max_trq = dvar.mc_trq_scale*vinf.m_max_trq_orig;
vinf.m_max_gen_trq = dvar.mc_trq_scale*vinf.m_max_gen_trq_orig;
vinf.mc_mass = dvar.mc_trq_scale*vinf.mc_mass_orig;

% Engine
vinf.eng_consum_trq = dvar.fc_trq_scale*vinf.eng_consum_trq_orig;
vinf.eng_max_trq = dvar.fc_trq_scale*vinf.eng_max_trq_orig;
vinf.eng_consum_fuel = dvar.fc_trq_scale*vinf.eng_consum_fuel_orig;
vinf.fc_hc_map = dvar.fc_trq_scale*vinf.fc_hc_map_orig;
vinf.fc_co_map = dvar.fc_trq_scale*vinf.fc_co_map_orig;
vinf.fc_nox_map = dvar.fc_trq_scale*vinf.fc_nox_map_orig;
% vinf.eng_control_trq = [0:RUN_TYPE.trq_size:max(vinf.eng_max_trq),max(vinf.eng_max_trq)]; % If you control it with the given vecotr, you may not need to interpolate!
vinf.eng_control_trq = [0:RUN_TYPE.trq_size:max(vinf.eng_max_trq)]; % in steps, and not including the maximum
vinf.Te_min = dvar.fc_trq_scale*vinf.Te_min_orig;

vinf.fc_max_pwr=(max(vinf.eng_consum_spd_old.*vinf.eng_max_trq)/1000); % kW     peak engine power
fc_base_mass=1.8*fc_max_pwr;            % (kg), mass of the engine block and head (base engine)
                                        %       mass penalty of 1.8 kg/kW from 1994 OTA report, Table 3 
fc_acc_mass=0.8*fc_max_pwr;             % kg    engine accy's, electrics, cntrl's - assumes mass penalty of 0.8 kg/kW (from OTA report)
fc_fuel_mass=0.6*fc_max_pwr;            % kg    mass of fuel and fuel tank (from OTA report)
vinf.fc_mass = fc_base_mass + fc_acc_mass + fc_fuel_mass; % kg  total engine/fuel system mass

% idling
dt = 1;  % note this is also in the drive_cycle function, so it needs to be changed there as well - this needs to be called before that function
% saturate for tables, so you don't get NaNs!!
if vinf.W_gb_is_min < vinf.W_eng_min
    We_fuel = vinf.W_eng_min;
elseif vinf.W_gb_is_min > vinf.W_eng_max
    We_fuel = vinf.W_eng_max;
else
    We_fuel = vinf.W_gb_is_min;
end
vinf.fuel_idle = (interp2(vinf.eng_consum_trq',vinf.eng_consum_spd,vinf.eng_consum_fuel,vinf.Te_min,We_fuel,'linear')*dt)';
vinf.NOx_idle = (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_nox_map,vinf.Te_min,We_fuel,'linear')*dt)';
vinf.CO_idle =  (interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_co_map,vinf.Te_min,We_fuel,'linear')*dt)';
vinf.HC_idle =(interp2(vinf.eng_consum_trq,vinf.eng_consum_spd,vinf.fc_hc_map,vinf.Te_min,We_fuel,'linear')*dt)';
                
% Battery
vinf.ess_r_dis = dvar.module_number*vinf.ess_r_dis_orig;
vinf.ess_r_chg = dvar.module_number*vinf.ess_r_chg_orig;
vinf.ess_voc = dvar.module_number*vinf.ess_voc_orig;
vinf.ess_max_pwr_dis = (vinf.ess_voc.^2)./(4*vinf.ess_r_dis)*0.98;  
vinf.ess_max_pwr_chg = (vinf.ess_voc.^2)./(4*vinf.ess_r_chg)*0.98;
vinf.ess_mass = dvar.module_number*vinf.ess_module_mass_orig;

% Calcualte Total Mass
vinf.m = vinf.mc_mass + vinf.fc_mass + vinf.base_mass + vinf.load + vinf.ess_mass;
