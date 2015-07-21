clear;
clf;
close all;
C = jet;
h = 14;
r=6;
t = 10;
q = 7;  % For colors
start = 1;
stop = 10;
for i = [1,2,3,4,5,6,7,8];
    if i == 1
        load SOC_grid_0_1_trq_1_Nm;
        c = 'SOC grid size = 0.1';
    elseif i == 2
        load SOC_grid_0_2_trq_1_Nm;
        c = 'SOC grid size = 0.2';
    elseif i == 3
        load SOC_grid_0_05_trq_1_Nm;
        c = 'SOC grid size = 0.05';
    elseif i == 4
        load SOC_grid_0_025_trq_1_Nm;
        c = 'SOC grid size = 0.025';
    elseif i == 5
        load SOC_grid_0_0125_trq_1_Nm;
        c = 'SOC grid size = 0.0125';
    elseif i == 6
        load SOC_grid_0_00625_trq_1_Nm;
        c = 'SOC grid size = 0.00625';
    elseif i == 7
        load SOC_grid_0_005_trq_1_Nm;
        c = 'SOC grid size = 0.005';
    elseif i == 8
        load SOC_grid_0_003125_trq_1_Nm;
        c = 'SOC grid size = 0.003125';
    elseif i == 9
        load SOC_grid_005_interp_cubic;
        c = '0.005 cubic interp.';
    elseif i == 10
        load SOC_grid_0005_interp_cubic;
        c = '0.0005 cubic. interp.';
    elseif i == 11;
        load SOC_grid_005_interp_full_cyc;
        c = '0.005 line. interp FULL';
    elseif i == 12;
        load SOC_grid_005_interp_lower_weights;
        c = '0.005 line. interp Lower weights';
    elseif i == 13;
        load SOC_grid_005_interp_full_cyc_smooth;
        c = '0.005 line. interp Full CYC Smoothed Data';
    else
        load SOC_grid_001_interp_full_cyc_smooth;
        c = '0.001 line. interp Full CYC Smoothed Data';
    end
    
    if i == start
        leg = {c};
        a = 1;
    else
        leg = {leg{1:a}, c};
        a = a+1;
    end
%     
%     if i ==4
%     s =  1000/10.2567;
%     else
%         s= 1;
%     end
s=1;
    figure(1)
    plot(result.NOx(1,:)*s,result.mpg(1,:),'-ko',...
        'LineWidth',0.5,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',C(a+(a-1)*q,:),...
        'MarkerSize',r)
    grid on
    ylabel('MPG')
    xlabel('NOx (g)')
    legend(leg{1:a})
    set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')
    hold on
    
    figure(2)
    plot(result.CO(2,:)*s,result.mpg(2,:),'-ko',...
        'LineWidth',0.5,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',C(a+(a-1)*q,:),...
        'MarkerSize',r)
    grid on
    ylabel('MPG')
    xlabel('CO (g)')
    legend(leg{1:a})
    set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')
    hold on
    
    figure(3)
    plot(result.HC(3,:)*s,result.mpg(3,:),'-ko',...
        'LineWidth',0.5,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',C(a+(a-1)*q,:),...
        'MarkerSize',r)
    grid on
    ylabel('MPG')
    xlabel('HC (g)')
    legend(leg{1:a})
    set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')
    hold on
    
    figure(4)
    plot(result.SE(4,:),result.mpg(4,:),'-ko',...
        'LineWidth',0.5,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',C(a+(a-1)*q,:),...
        'MarkerSize',r)
    grid on
    ylabel('MPG')
    xlabel('Total Shift Events')
    legend(leg{1:a})
    set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')
    hold on
    
    figure(5)
    plot(result.EE(5,:),result.mpg(5,:),'-ko',...
        'LineWidth',0.5,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',C(a+(a-1)*q,:),...
        'MarkerSize',r)
    grid on
    ylabel('MPG')
    xlabel('Total Engine Events')
    legend(leg{1:a})
    set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')
    hold on
    
    figure(6)
    plot(result.CE(6,:),result.mpg(6,:),'-ko',...
        'LineWidth',0.5,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',C(a+(a-1)*q,:),...
        'MarkerSize',r)
    grid on
    ylabel('MPG')
    xlabel('Total Idle Events')
    legend(leg{1:a})
    set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')
    hold on
end

hold off
set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')

