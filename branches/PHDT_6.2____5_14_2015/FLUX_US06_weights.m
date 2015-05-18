clear;
% TO RUN THE LATIN HYPERCUBE script %
addpath('/home/febbo/LHC3/Optimization/Latin Hypercube/')

n = 1000;
weight_LHC = 1;            % Variable Emissions weights on!!
RUN_TYPE.emiss_on = 1;     % This setting does not matter for this script
cyc_name = 'US06';
LHC;