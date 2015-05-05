S = size(FAIL_LHC_save,1);

for n = 1:S
    if FAIL_LHC_save(n) == 0
        FAIL_LHC_save(n) = -1;
    end
end

eval(['save(''','FAIL_LHC_save',''',','''FAIL_LHC_save'');'])