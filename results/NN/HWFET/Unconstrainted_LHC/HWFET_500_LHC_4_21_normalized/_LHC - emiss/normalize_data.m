%% Normalize
clear; % Then Reload data
load NOx
load MPG
load HC
load DV
load CO

% Also save mean and std for both input and output, so that you can map it
% back later
mean_MPG = mean(MPG);
std_MPG = std(MPG);
mean_HC = mean(HC);
std_HC = std(HC);
mean_CO = mean(CO);
std_CO = std(CO);
mean_NOx = mean(NOx);
std_NOx = std(NOx);
mean_X = mean(X);
std_X =  std(X);

folder = 'Normalized Data HWFET 500 emiss';
mkdir(folder)
cd(folder)
eval(['save(''','std_MPG',''',','''std_MPG'');'])
eval(['save(''','std_X',''',','''std_X'');'])
eval(['save(''','std_NOx',''',','''std_NOx'');'])
eval(['save(''','std_CO',''',','''std_CO'');'])
eval(['save(''','std_HC',''',','''std_HC'');'])

eval(['save(''','mean_MPG',''',','''mean_MPG'');'])
eval(['save(''','mean_X',''',','''mean_X'');'])
eval(['save(''','mean_NOx',''',','''mean_NOx'');'])
eval(['save(''','mean_CO',''',','''mean_CO'');'])
eval(['save(''','mean_HC',''',','''mean_HC'');'])

MPG_norm = bsxfun(@minus, MPG, mean(MPG))/std(MPG);
NOx_norm =  bsxfun(@minus, NOx, mean(NOx))/std(NOx);
HC_norm = bsxfun(@minus, HC, mean(HC))/std(HC);
CO_norm = bsxfun(@minus, CO, mean(CO))/std(CO);
DV_norm = bsxfun(@minus, X, mean(X))/std(X);
 
eval(['save(''','MPG_norm',''',','''MPG_norm'');'])
eval(['save(''','DV_norm',''',','''DV_norm'');'])
eval(['save(''','NOx_norm',''',','''NOx_norm'');'])
eval(['save(''','CO_norm',''',','''CO_norm'');'])
eval(['save(''','HC_norm',''',','''HC_norm'');'])