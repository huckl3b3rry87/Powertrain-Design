
co_temp = fc_co_map_gpkWh(fc_co_map_gpkWh~=0);
num1_2 = 20;
num2_3 = 6;
BSFC_L1 = linspace(min(co_temp),2.3*min(co_temp),16);
BSFC_L2_temp = linspace(2.3*min(co_temp),15*min(co_temp),num1_2);
BSFC_L2  = BSFC_L2_temp(2:num1_2);
BSFC_U_temp  = linspace(1.5*min(co_temp),max(max(co_temp),1.9*min(co_temp)),num2_3);
BSFC_U  = BSFC_U_temp(2:num2_3);

BSFC = [BSFC_L1, BSFC_L2, BSFC_U];

h10=figure; clf;
[C,h] = contourf(vinf.eng_consum_spd*rads2rpm, vinf.eng_consum_trq, fc_co_map_gpkWh',BSFC);
axis([0 5500 0 max(vinf.eng_max_trq+5)]);
hold on;
plot(vinf.eng_consum_spd_old*rads2rpm, vinf.eng_max_trq, 'k', 'linewidth', 8);
hold on 
plot(sim.W_eng*rads2rpm,sim.T_eng, 'mo', 'markersize', 10, 'markerf', 'k','linewidth',2),grid
xlabel('Speed (RPM)');
ylabel('Torque (Nm)');
set(gca,'FontSize',14,'fontWeight','bold')
set(findall(gcf,'type','text'),'FontSize',16,'fontWeight','bold')
legend('CO (g/kWh)','Maximum Torque','Opperating Points')   

% colorbar('FontSize',16,'fontWeight','bold','YDir','reverse')
h = gcf;
load('EngineColorMap','mycmap')
set(h,'Colormap',mycmap)
colorbar('FontSize',14,'fontWeight','bold','YDir','reverse')

% set(h,'Colormap',flipud(mycmap))
% colorbar('FontSize',16,'fontWeight','bold',)
%% To save
% h = gcf;
% mycmap = get(h,'Colormap');
% save('Engine_CO_ColorMap','mycmap');
