function Data = hilbert_process (Data)

        Data.S.S1.hilbert_gamma = abs(hilbert(Data.S.S1.gamma_temp_filtered));
        Data.S.S1.gamma_power = [Data.S.S1.gamma_power log10(mean(Data.S.S1.hilbert_gamma))];

        Data.S.S2.hilbert_theta = abs(hilbert(Data.S.S2.theta_temp_filtered));
        Data.S.S2.theta_power = [Data.S.S2.theta_power log10(mean(Data.S.S2.hilbert_theta))];

        Data.S.S2.hilbert_delta = abs(hilbert(Data.S.S2.delta_temp_filtered));
        Data.S.S2.delta_power = [Data.S.S2.delta_power log10(mean(Data.S.S2.hilbert_delta))];

        Data.S.S2.ratio_power = [Data.S.S2.ratio_power log10(mean(Data.S.S2.hilbert_theta))/log10(mean(Data.S.S2.hilbert_delta))];

end