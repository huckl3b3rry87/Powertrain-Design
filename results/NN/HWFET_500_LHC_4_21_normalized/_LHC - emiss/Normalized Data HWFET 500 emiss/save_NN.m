
clear; % Then Reload data
load NOx_norm
load MPG_norm
load HC_norm
load DV_norm
load CO_norm

folder = 'NN HWFET 500 emiss normalized';
mkdir(folder)
cd(folder)

eval(['save(''','MPG_net',''',','''MPG_net'');'])
eval(['save(''','NOx_net',''',','''NOx_net'');'])
eval(['save(''','CO_net',''',','''CO_net'');'])
eval(['save(''','HC_net',''',','''HC_net'');'])

