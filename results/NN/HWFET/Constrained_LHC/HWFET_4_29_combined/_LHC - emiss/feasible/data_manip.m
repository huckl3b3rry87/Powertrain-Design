clear;

load NOx_f
load MPG_f
load HC_f
load DV_f
load CO_f
load FAIL_LHC_save
load DV

folder = 'data1';
mkdir(folder)
cd(folder)

eval(['save(''','MPG1',''',','''feasible_MPG'');'])
eval(['save(''','DV1',''',','''feasible_DV'');'])
eval(['save(''','NOx1',''',','''feasible_NOx'');'])
eval(['save(''','CO1',''',','''feasible_CO'');'])
eval(['save(''','HC1',''',','''feasible_HC'');'])
eval(['save(''','FAIL_LHC1',''',','''FAIL_LHC_save'');'])
eval(['save(''','X_save1',''',','''X_save'');'])


