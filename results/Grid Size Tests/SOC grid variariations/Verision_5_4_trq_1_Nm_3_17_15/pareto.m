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
for i = [start,2,3,4,5,6,7];
    if i == 1
        load SOC_grid_05_trq_1_NM_HWFET;
        c = 'SOC grid size = 0.05';
    elseif i == 2
        load SOC_grid_01_trq_1_NM_HWFET;
        c = 'SOC grid size = 0.01';
    elseif i == 3
        load SOC_grid_005_trq_1_NM_HWFET;
        c = 'SOC grid size = 0.005';
    elseif i == 4
        load SOC_grid_001_trq_1_NM_HWFET;
        c = 'SOC grid size = 0.001';
    elseif i == 5
        load SOC_grid_0005_trq_1_NM_HWFET;
        c = 'SOC grid = 0.0005';
    elseif i == 6
        load SOC_grid_00025_trq_1_NM_HWFET;
        c = 'SOC grid = 0.00025';
    elseif i == 7
        load SOC_grid_000125_trq_1_NM_HWFET;
        c = 'SOC grid = 0.000125';
    elseif i == 8
        load SOC_grid_0005_interp;
        c = '0.0005 lin. interp.';
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
    figure(2)
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
    
    figure(3)
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
    
    figure(4)
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
    
    figure(5)
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
    
    figure(6)
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
end

hold off
set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')

