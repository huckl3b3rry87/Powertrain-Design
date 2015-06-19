figure(2232)

n = 25;
h= 15;
q = 2;
GRAPH =  plot(cyc_data.cyc_time,sim.Wis_gb*rads2rpm, 'kx-',cyc_data.cyc_time,sim.W_eng*rads2rpm, 'rx-','LineWidth',2,'markersize', 3); grid on;
set(GRAPH,'marker','.', 'markersize', n, 'markerf','b','linewidth',q);
H = legend('Input Shaft of Transmission','Engine Speed');set(H,'fontsize', h)
ylabel({'Speed', '(RPM)'},'fontWeight','bold','fontSize',y)
set(gca,'fontSize',y,'fontWeight','bold');   
xlabel('time (sec)');