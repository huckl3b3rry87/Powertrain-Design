folder = 'US06_5)20_2015_30kW';
mkdir(folder)
cd(folder)

eval(['save(''','MPG_net',''',','''MPG_net'');'])
eval(['save(''','NOx_net',''',','''NOx_net'');'])
eval(['save(''','CO_net',''',','''CO_net'');'])
eval(['save(''','HC_net',''',','''HC_net'');'])
eval(['save(''','constraint_net',''',','''constraint_net'');'])

