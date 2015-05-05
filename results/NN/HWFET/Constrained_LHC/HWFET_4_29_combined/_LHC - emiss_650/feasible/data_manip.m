clear;

load NOx_f
load MPG_f
load HC_f
load DV_f
load CO_f
load FAIL_LHC_save
load DV

folder = 'data2';
mkdir(folder)
cd(folder)

eval(['save(''','MPG2',''',','''feasible_MPG'');'])
eval(['save(''','DV2',''',','''feasible_DV'');'])
eval(['save(''','NOx2',''',','''feasible_NOx'');'])
eval(['save(''','CO2',''',','''feasible_CO'');'])
eval(['save(''','HC2',''',','''feasible_HC'');'])
eval(['save(''','FAIL_LHC2',''',','''FAIL_LHC_save'');'])
eval(['save(''','X_save2',''',','''X_save'');'])


