% Load all data
load('NOx_net.mat');
load('MPG_net.mat');
load('HC_net.mat');
load('CO_net.mat');
x =[ 4.0895    1.3786    0.4967    0.6012]

MPG = MPG_net(x')
NOx = NOx_net(x')/1000
HC = HC_net(x')/1000
CO = CO_net(x')/1000
