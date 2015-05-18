folder = 'UDDS_5_17_2015_600_large';
mkdir(folder)
cd(folder)

eval(['save(''','MPG_net',''',','''MPG_net'');'])
eval(['save(''','NOx_net',''',','''NOx_net'');'])
eval(['save(''','CO_net',''',','''CO_net'');'])
eval(['save(''','HC_net',''',','''HC_net'');'])
eval(['save(''','constraint_net',''',','''constraint_net'');'])

