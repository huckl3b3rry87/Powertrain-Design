function [ F_max, V_max] = Max_Speed( Force_Veh, F_Road_L, V )

A =  isnan(Force_Veh);  % if there is a one then there is a NaN
I = find(A==0);         % if A is all 1's then I will be empty

if isempty(I)            % failed
    F_max = 0;    
    V_max = 0;
else
    F_max = Force_Veh(I(end));
    FRL_C = F_Road_L(I(end));
    
    if FRL_C > F_max      % could be case # 1 or case # 3
        P = InterX([V';F_Road_L'],[V';Force_Veh']);
        if isempty(P)     % the engine force was never larger than F_RL - case # 1
            F_max = 0;
            V_max = 0;
        else               % then they intersected.. - case # 3
            V_max = P(1);
            F_max = P(2);
        end
    else                    % case # 2 || case # 4 || case # 5
        V_max = V(I(end));  % this is the maximum speed that the engine can attain
    end
end
end

