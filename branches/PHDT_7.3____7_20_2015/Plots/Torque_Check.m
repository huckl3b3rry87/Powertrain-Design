Te = sim.T_eng.*vinf.gear(sim.GEAR)*dvar.FD;
Tm = sim.T_mot*dvar.FD*dvar.G;
T_total = Te + Tm + sim.T_brake;
cyc_time=1:1:cyc_data.time_cyc;
h3=figure;clf;
plot(cyc_time,sim.T_brake,'color','k','LineWidth',2);
hold on 
plot(cyc_time,Te,'color','g','LineWidth',2);
hold on 
plot(cyc_time,Tm,'LineWidth',3);
hold on
plot(cyc_time,cyc_data.Tw,'color','y','LineWidth',6);
hold on
plot(cyc_time,T_total,'r--','LineWidth',2)
legend('Brake Torque','Engine (at road)','Motor (at road)','T required','Motor + Engine + Brake')
ylabel('Torque (Nm)','fontWeight','bold','fontSize',20);grid
xlabel('time (sec)','fontWeight','bold','fontSize',20);
set(gca,'fontSize',20,'fontWeight','bold')
hold off    
% magnifyOnFigure;