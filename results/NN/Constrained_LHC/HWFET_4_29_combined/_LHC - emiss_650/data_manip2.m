clear;

load NOx
load MPG
load HC
load DV
load CO
load FAIL_LHC

folder = 'data2';
mkdir(folder)
cd(folder)

eval(['save(''','MPG2',''',','''MPG_save'');'])
eval(['save(''','DV2',''',','''X_save'');'])
eval(['save(''','NOx2',''',','''NOx_save'');'])
eval(['save(''','CO2',''',','''CO_save'');'])
eval(['save(''','HC2',''',','''HC_save'');'])
eval(['save(''','FAIL_LHC2',''',','''FAIL_LHC_save'');'])

