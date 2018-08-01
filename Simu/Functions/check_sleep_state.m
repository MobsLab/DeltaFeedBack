function Data = check_sleep_state (Data);

if Data.S.S1.gamma_power (end) > Data.gamma_treshold
    Data.sleep_state = 'WAKE';
end

if Data.S.S2.ratio_power (end) > Data.ratio_treshold
    Data.sleep_state = 'REM';
else 
    Data.sleep_state = 'SWS';
end

end
