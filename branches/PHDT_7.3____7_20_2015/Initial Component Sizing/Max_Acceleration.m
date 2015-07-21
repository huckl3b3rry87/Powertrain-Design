function [ PASS_2, V_fail] = Max_Acceleration(V_0,V_f, Acc_Final, Sim_Variables)

% require that the acceleration requirement be met at the lower velocity
% (V_0)

A =  isnan(Sim_Variables.V_sim);  % if there is a one then there is a NaN
I = find(A==0);                    % if A is all 1's then I will be empty

if isempty(I)            % failed
    PASS_2= 0;
    V_fail = NaN;
else
    V_max = Sim_Variables.V_sim(I(end));
    
    if V_max > V_f(end)  % the max vehicle speed is meet
        
        % find the acceleration required at the test velocites
        acc_needed = interp1(V_0,Acc_Final,Sim_Variables.V_sim);
        
        acc_needed(isnan(acc_needed)) = 0;
        
        % check to make sure that the actual acceleration is greater than
        % the needed acceleration
        temp = (acc_needed <= Sim_Variables.acc_sim);
        I = find(temp == 0);
        
        if any(temp ~= 1) % failed
            PASS_2 = 0;
            V_fail = Sim_Variables.V_sim(I);
        else
            PASS_2 = 1;
            V_fail = NaN;
        end
        
    else
        PASS_2 = 0;
        V_fail = NaN;
    end
end
return





