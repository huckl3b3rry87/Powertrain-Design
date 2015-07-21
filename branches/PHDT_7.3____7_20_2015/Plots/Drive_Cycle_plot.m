%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%---------------------Select Drive Cycle----------------------------------%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%%                              ~~ Standard ~~

cyc_name = 'HWFET';
% cyc_name = 'UDDS';
% cyc_name = 'US06';
% cyc_name = 'SHORT_CYC_HWFET';
% cyc_name = 'RAMP';
% cyc_name = 'LA92';
% cyc_name = 'CONST_65';
% cyc_name = 'CONST_45';
% cyc_name = 'COMMUTER';

% City
% cyc_name = 'INDIA_URBAN';
% cyc_name = 'MANHATTAN';
% cyc_name = 'Nuremberg';
% cyc_name = 'NYCC';
% cyc_name = 'AA_final';
%                              ~~ AV~~

% cyc_name = 'US06_AV';
% cyc_name = 'HWFET_AV';
% cyc_name = 'AA_final_AV';

cd('Drive_Cycle')
switch cyc_name
    % ---- Standard Cycles -=---
    case 'HWFET'  % user selects HWFET
        load CYC_HWFET;
    case 'UDDS'
        load CYC_UDDS;
    case 'US06'
        load CYC_US06;
    case 'LA92'
        load CYC_LA92;
    case 'FTP75'     % Get this cycle
        load FTP75;
    case 'COMMUTER'
        load CYC_COMMUTER;
    case 'SHORT_CYC_HWFET'
        load SHORT_CYC_HWFET;
        
        % City Cycles
    case'INDIA_URBAN'
        load CYC_INDIA_URBAN_SAMPLE;
    case 'MANHATTAN';
        load CYC_MANHATTAN;
    case 'Nuremberg'
        load CYC_NurembergR36;
    case 'NYCC'
        load CYC_'NYCC';
    case 'AA_final'
        load AA_final;
        
        % ----  AV Cycles -------
    case 'US06_AV'
        load CYC_US06_AV;
    case 'HWFET_AV'
        load CYC_HWFET_AV;
    case 'AA_final_AV'
        load AA_final_AV;
        
end
cd ..

v = cyc_mph(:,2); 
time_cyc = length(v);
cyc_time = 1:time_cyc;
figure()
plot(cyc_time,v','LineWidth',2)
ylabel('Speed (mph)','fontWeight','bold','fontSize',12)
xlabel('time (sec)','fontWeight','bold','fontSize',12);
set(gca,'fontSize',12,'fontWeight','bold'),grid
title(cyc_name,'fontWeight','bold','fontSize',16)



v = cyc_mph(:,2)*param.mph_mps;  % Cycle Speed in (m/s)
time_cyc = length(v);
cyc_time = 1:time_cyc;
% Need to define the a(t) of the profile
for i = 2:size(v)   % Backwards difference omits first point
    a(i) = (v(i) - v(i-1))/dt;
end

figure()
plot(cyc_time,a)
xlabel('time (s)')
ylabel('acceleration (m/s^2)')