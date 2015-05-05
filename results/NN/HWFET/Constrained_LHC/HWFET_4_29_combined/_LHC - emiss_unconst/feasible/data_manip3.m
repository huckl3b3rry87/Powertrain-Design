clear;

load NOx_f
load MPG_f
load HC_f
load DV_f
load CO_f
load FAIL_LHC_save

feasible_HC =feasible_HC/1000;
feasible_CO = feasible_CO/1000;
feasible_NOx = feasible_NOx/1000;

folder = 'data3';
mkdir(folder)
cd(folder)
eval(['save(''','MPG3',''',','''feasible_MPG'');'])
eval(['save(''','DV3',''',','''feasible_DV'');'])
eval(['save(''','NOx3',''',','''feasible_NOx'');'])
eval(['save(''','CO3',''',','''feasible_CO'');'])
eval(['save(''','HC3',''',','''feasible_HC'');'])
eval(['save(''','FAIL_LHC3',''',','''FAIL_LHC'');'])
eval(['save(''','X_save3',''',','''feasible_DV'');'])


