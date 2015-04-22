clear;
% TO RUN THE LATIN HYPERCUBE script %
 addpath('/home/febbo/LHC_5/Optimization/Latin Hypercube/')

 n = 500;
RUN_TYPE.emiss_on = 0; %off
% cyc_name = 'UDDS';
% cyc_name = 'US06';
cyc_name = 'AA_final';

% cyc_name = 'SHORT_CYC_HWFET';
LHC;