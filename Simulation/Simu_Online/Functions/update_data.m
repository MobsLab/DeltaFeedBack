%% updata_data
%This function updates Datas each period of timer object 
function Data = update_data (Data,Interface,Filter)
    
%Updating 
    Data.S.S1.gamma_temp = Data.S.S1.gamma(Data.subscripts);
    Data.S.S1.gamma_temp_filtered = Data.S.S1.gamma_filtered(Data.subscripts);
    
    Data.S.S2.thetadelta_temp = Data.S.S2.thetadelta(Data.subscripts);
    Data.S.S2.theta_temp_filtered = Data.S.S2.theta_filtered(Data.subscripts);
    Data.S.S2.delta_temp_filtered = Data.S.S2.delta_filtered(Data.subscripts);
    
    %Multiplying PFC signals by prefactors at the same time if necessary 
    if Interface.set_prefactors_checkbox.Value == 1
        Data.S.S3.PFCsup_temp = Data.S.S3.PFCsup(Data.subscripts) * Data.sup_prefactor;
        Data.S.S3.PFCdeep_temp = Data.S.S3.PFCdeep(Data.subscripts) * Data.deep_prefactor;
    else
        Data.S.S3.PFCsup_temp = Data.S.S3.PFCsup(Data.subscripts);
        Data.S.S3.PFCdeep_temp = Data.S.S3.PFCdeep(Data.subscripts);
    end
    
    %Refreshing PFCdif_temp and PFCdif_filtered_temp vector (used for Delta
    %Detection in check_Delta.m function
    Data.S.S3.PFCdif_temp = Data.S.S3.PFCdeep_temp - Data.S.S3.PFCsup_temp;
    [Filter.PFCdif_A, Filter.PFCdif_B] = butter(Data.filter_order, Data.cutoff_freq/(Data.fs/2));
    filtered = filtfilt(Filter.PFCdif_A,Filter.PFCdif_B,Data.S.S3.PFCdif_temp);
    Data.S.S3.PFCdif_temp_filtered = [Data.S.S3.PFCdif_temp_filtered(2:end) filtered(end)];
    
end