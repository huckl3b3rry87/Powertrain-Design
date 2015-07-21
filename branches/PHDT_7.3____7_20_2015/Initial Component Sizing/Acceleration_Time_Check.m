function [ PASS_1, Final_Velocity ] = Acceleration_Time_Check( Sim_Variables, V_0, V_f, dt_req )
% this function is a basic acceleration test check, i.e. 0-60 in 12 seconds

if Sim_Variables.in == 1
       % find the time where the intial velocity is closest to V_0
       [~,I_start] = min(abs(Sim_Variables.V_sim - V_0)); 
       
       % extract the closest time to this "initial velocity time"
       time_start = Sim_Variables.time_sim(I_start);
       
       % offset the required time by time_start 
       time_check = dt_req + time_start;
       
       % at the final time, interpolate back onto the velocity for an
       % approximation of velocity
       Final_Velocity = interp1(Sim_Variables.time_sim, Sim_Variables.V_sim, time_check);
       
        if isempty(Final_Velocity)
            Final_Velocity = 0;
        end
        
        if Final_Velocity < V_f
            PASS_1 = 0;            % failed
        else
            PASS_1 = 1;
        end
else
    PASS_1 = 0;                   % failed, did not simulate for more than 0.5 s
    Final_Velocity = 100; 
end

end

