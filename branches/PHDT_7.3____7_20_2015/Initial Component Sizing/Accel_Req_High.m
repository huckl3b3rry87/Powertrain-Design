function [ V_0, V_f,  Acc_Final, leg] = Accel_Req_High( S, dt_2, graph )
SSS = 1;
dt = 1;
mph_mps = 1/2.237;
C = [[1 1 0];[1 0 1];[0 1 1];[1 0 0];[0 1 0];[0 0 1]]; % Cell array of colros.

for n = 1:5
    cd('Drive_Cycle')
    if n == 1
        load CYC_HWFET; cyc_name1 = 'HWFET';
    elseif n == 2
        load CYC_UDDS; cyc_name2 = 'UDDS';
    elseif n == 3
        load CYC_US06; cyc_name3 = 'US06';
    elseif n == 4
        load CYC_COMMUTER; cyc_name5 = 'COMMUTER';
    else
        load CYC_LA92; cyc_name4 = 'LA92';
    end
    cd ..
    
    v = cyc_mph(:,2)*mph_mps;  % Cycle Speed in (m/s)
    time_cyc = length(v);
    cyc_time = 1:time_cyc;
    
    % Need to define the a(t) of the profile
    z = 1;
    for i = 2:size(v)   % Backwards difference omits first point
        if v(i) > v(i-1)  % only do acceleration
            a(z) = (v(i) - v(i-1))/dt;
            v_n(z) = v(i);
            z = z+1;
        end
    end
    
    % sort velocities
    [V_sorted,I] = sort(v_n);
    V_sorted = [0,V_sorted(1:(end-1))];
    Acc_sorted = [a(I)];
    
    V_max = 85*mph_mps;
    low = linspace(0,5,13)*mph_mps;
    V_test = [low,linspace(low(end)+0.5,V_max,S-length(low))];
    
    num = min(S,z);
    for i = 1:num-1
        Index = find(V_test(i) <= V_sorted & V_sorted <= V_test(i + 1));
        
        if ~isempty(Index)
            a_req(i) = abs(max(Acc_sorted(Index)));
        elseif i~=1 && (V_test(i+1) < max(V_sorted))
            a_req(i)=a_req(i-1); % If there is no speed in the drive cycle between the selected points, assume that the vehicle has to opperate at an acceleration that is the same as the speed just below it ( that is for the next higher speed)
        else
            a_req(i)=0;
        end
    end
    if n~=3 && n~= 4 && n~=5 % Exclude US06 and LA92
        a_save(SSS,:) = a_req;
        SSS = SSS + 1;
    end
    
    if graph == 1
        figure(101);
        plot(V_test(2:end)/mph_mps,a_req,'color',C(n,:),'linewidth',5)
        hold on
    end
    
end
r =1;
max_a = max(a_save,[],1)*1.15;
for z = 1:length(max_a)
    if max_a(z+1) < max_a(z)
        stop = z;
        break;
    end
end
index = zeros(size(max_a));
for i = (S-1):-1:stop  % Starts decreasing at 3
    if any(max_a(i) < max_a(i+1:S-1))  % Find the next maximum headed backwards and interpolate - except if there is no next maximum - like at the start
        index(i) = 1;
    end
    r = r+1;
end

i = find(index==0);
for g = 1:length(i)
    a_plot(g) = max_a(i(g));
    v_plot(g) = V_test(i(g)+1);
end

Acc_Final = interp1(v_plot,a_plot,V_test(2:end));

if graph == 1
    plot(V_test(2:end)/mph_mps,Acc_Final,'k','linewidth',5);
    leg = {cyc_name1,cyc_name2,cyc_name3, cyc_name4,cyc_name5,'Required Acceleration'};
    legend(leg)
    xlabel('Velocity (mph)')
    ylabel('Acceleration (m/s^2)')
    set(gca,'fontSize',12,'fontWeight','bold')
    set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold'),grid
    hold on
end

V_Initial =  V_test(1:end-1);
V_Final = (V_Initial + Acc_Final*dt_2);

V_0 = V_Initial;  % m/s
V_f = V_Final;

end

