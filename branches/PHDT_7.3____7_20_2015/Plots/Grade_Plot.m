C = [[1 1 0];[1 0 1];[0 1 1];[1 0 0];[0 1 0];[0 0 1]]; % Cell array of colros.

Engine_Tractive_Effort = Sim_Grade.Eng_Tractive_Effort;
Max_Eng_Tractive_Effort = Sim_Grade.Max_Eng_Tractive_Effort;
Motor_Tractive_Effort = Sim_Grade.Motor_Tractive_Effort;
Force_PM = Sim_Grade.Force;
F_RL = Sim_Grade.F_RL;
V = test.Vsim;
V_max_t = Sim_Grade.V_max_t;
F_max_t = Sim_Grade.F_max_t;

figure(11);clf
for i = 1:1:n
    
    figure(11);
    plot(V/mph_mps,Engine_Tractive_Effort(:,i)/1000,'color',C(i,:),'linewidth',5)
    hold on 
%     figure(2);
%     plot(V/mph_mps,Eng_Power(:,x3)/1000,'color',C(x3,:),'linewidth',3)
%     hold on
 
end

% Hybrid 
Max_Tractive_Effort = Max_Eng_Tractive_Effort + Motor_Tractive_Effort;
figure(11);
% plot(V/mph_mps,Max_Eng_Tractive_Effort/1000,'k*','markersize',8)
% hold on
plot(V/mph_mps,Motor_Tractive_Effort/1000,'k--','linewidth',3)
hold on
plot(V/mph_mps,Max_Tractive_Effort/1000,'k-*','linewidth',3)
hold on
% plot(V/mph_mps,Force_PM/1000,'r-*','linewidth',3)
% hold on
plot(V_max_t/mph_mps,F_max_t/1000,'k*','markersize',28)
hold on
plot(V_max_6/mph_mps,F_max_6/1000,'ro','markersize',28)
hold on

for i = 1:1:RR
    figure(11);
    plot(V/mph_mps,F_RL(:,i)/1000,'-ko',...
        'LineWidth',0.5,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',C(i,:),...
        'MarkerSize',3)
    hold on
end

hold on
set(gca,'FontSize',20,'fontWeight','bold')
set(findall(gcf,'type','text'),'FontSize',25,'fontWeight','bold')

if length(vinf.gear) == 6
    legend('Gear 1', 'Gear 2', 'Gear 3','Gear 4', 'Gear 5', 'Gear 6','motor only','hybrid','Max. Spd.','Sixth Gear','Zero Slope Road Load','4 Degree Slope Road Load');
elseif length(vinf.gear) == 4
    legend('Gear 1', 'Gear 2', 'Gear 3','Gear 4','motor only','hybrid','Max. Spd.','Fourth Gear','Zero Slope Road Load','5 Degree Slope Road Load');
else
    fprintf('The legend is currently configured for 6 and 4 speed transmissions!!\n')
end
% legend('Gear 1', 'Gear 2', 'Gear 3','Gear 4', 'Gear 5', 'Gear 6','Motor Max','Hybrid','Max. Spd.','Zero Slope Road Load','5 Degree Slope Road Load');
xlabel('Vehicle Speed (MPH)');
ylabel('Tractive Effort (kN)');
% title('Road Load for Road Slopes of: 0 and 5 degrees')
grid; hold off


% figure(2);
% plot(V/mph_mps,Peng1,'k','linewidth',3)
% hold on
% plot(V/mph_mps,Peng2,'k--','linewidth',3)
% set(gca,'FontSize',20,'fontWeight','bold')
% set(findall(gcf,'type','text'),'FontSize',25,'fontWeight','bold')
% legend('Gear 1', 'Gear 2', 'Gear 3','Gear 4', 'Gear 5', 'Gear 6','Flat Road','5% Road Grade') 
% xlabel('Vehicle Speed (MPH)');
% ylabel('Engine Power (kW)');
% grid; hold off