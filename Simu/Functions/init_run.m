function Data = init_run (Data,Interface)

if Data.Implement_counter == 0
    
    f = waitbar(0,'Please wait...');
    
    if strcmp(get(Interface.btn_t0_edit,'String'),'t0') == 1
        
        Data.S.S1.gamma = Data.S.S1.gamma_raw;                     %gamma signal time selection 
        Data.S.S2.thetadelta = Data.S.S2.thetadelta_raw;           %thetadelta signal time selection
        Data.S.S3.PFCsup = Data.S.S3.PFCsup_raw;                   %PFCsup signal time selection
        Data.S.S3.PFCdeep = Data.S.S3.PFCdeep_raw;                 %PFCdeep signal time selection
        Data.S.S3.PFCdif = Data.S.S3.PFCdeep_raw - Data.S.S3.PFCsup_raw;
%         Data.S.S3.PFCdif_filtered = filtfilt(Filter.PFCdif_A,Filter.PFCdif_B,Data.S.S3.PFCdif);
        
    end

    %initializations for update_display function
    waitbar(0.5,f,'Initializing time parameters for simulation ...');
    Data.subscripts = [1:Interface.time_window*Data.fs];                    %points subscripts of the first 3s window 
    Data.acq_time = size(Data.S.S1.gamma,1)/Data.fs;                        %signal selection time length
    Data.t = [0:Data.dt:Data.acq_time-Data.dt];                             %time vector
    Data.N_Hilbert_windows = Data.acq_time/Interface.time_window;           %total number of 3s time windows on which we will compute Hilbert transform
    Data.N_Implement = Data.acq_time / Interface.time_implement - 1;            %total number of Data implementations we will have to do to read all the signal
    Data.S.S3.PFCdif_temp_filtered = zeros (size(Data.subscripts));
    Data.t_tmp = [0:Data.dt:Interface.time_window-Data.dt];                 %temp time vector
    waitbar(1,f,'Operation Completed');
    pause(0.5);
    close(f);

end

end