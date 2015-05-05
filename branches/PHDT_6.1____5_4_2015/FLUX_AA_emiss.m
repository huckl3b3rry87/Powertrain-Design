clear;
% TO RUN THE LATIN HYPERCUBE script %
addpath('/home/febbo/LHC8/Optimization/Latin Hypercube/')

n = 1000;
weight_LHC = 0;            % No variable emissions weights
RUN_TYPE.emiss_on = 1;     % Emissions at nominal values
cyc_name = 'AA_final';
LHC;