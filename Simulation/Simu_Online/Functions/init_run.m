%% init_run
%This function intialize some variables for update_diplay function Callback 

function Signals = init_run (Signals,Interface)


if Signals.Implement_counter == 0
    
    f = waitbar(0,'Please wait...');
    %if the user did not whose to select a TimeSpan --> take the raw signals (entire acquisition)         
    if Signals.TimeSelection == 0
        Signals.S.S1.gamma = Signals.S.S1.gamma_raw;                       
        Signals.S.S2.thetadelta = Signals.S.S2.thetadelta_raw;           
        Signals.S.S3.PFCsup = Signals.S.S3.PFCsup_raw;                       
        Signals.S.S3.PFCdeep = Signals.S.S3.PFCdeep_raw;                   
        Signals.S.S3.PFCdif = Signals.S.S3.PFCdeep_raw - Signals.S.S3.PFCsup_raw;
        Signals.S.S1.gamma_filtered = Signals.S.S1.gamma_filtered_raw;    
        Signals.S.S2.theta_filtered = Signals.S.S2.theta_filtered_raw;
        Signals.S.S2.delta_filtered = Signals.S.S2.delta_filtered_raw;

        Signals.ratio_treshold_temp = str2double(get(Interface.ratio_edit,'String'));
        Signals.gamma_treshold_temp = str2double(get(Interface.gamma_edit,'String'));
        Signals.delta_treshold_temp = str2double(get(Interface.delta_edit,'String'));
    end

    %initializations for update_display function
    waitbar(0.5,f,'Initializing time parameters for simulation ...');
    %points subscripts of the first 3s window 
    Signals.subscripts = 1:Interface.time_window*Signals.fs;
    %Total time length               
    Signals.acq_time = Signals.t(end);
    %total number of Data implementations we will have to do to read all the signal
    Signals.N_Implement = size(Signals.S.S1.gamma,1) - 1; 
    %Initializing PFCdif_temp_filtered (refreshed in update_data.m
    %function)
    Signals.S.S3.PFCdif_temp_filtered = zeros (size(Signals.subscripts));
    %temp time vector
    Signals.t_tmp = Signals.t(Signals.subscripts);                            
    waitbar(1,f,'Operation Completed');
    pause(0.5);
    close(f);

end

end