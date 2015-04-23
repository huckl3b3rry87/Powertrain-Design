clear;
% TO RUN THE LATIN HYPERCUBE script %
addpath('/home/febbo/LHC6/Optimization/Latin Hypercube/')

n = 1000;
weight_LHC = 1;            % This is the variable weight script
RUN_TYPE.emiss_on = 1;     % This setting does not matter here
cyc_name = 'HWFET';
LHC;