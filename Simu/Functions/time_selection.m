function Data = time_selection (Data,Filter,Interface)

%time selection
f= waitbar(0,'Selecting Time Span...');
Data.S.S1.gamma = Data.S.S1.gamma_raw(Data.T0:Data.T1);                     %gamma signal time selection
Data.S.S1.gamma_filtered = Data.S.S1.gamma_filtered(Data.T0:Data.T1);
waitbar(0.25,f,'Operation Completed');
Data.S.S2.thetadelta = Data.S.S2.thetadelta_raw(Data.T0:Data.T1);           %thetadelta signal time selection
Data.S.S2.theta_filtered = Data.S.S2.theta_filtered(Data.T0:Data.T1); 
Data.S.S2.delta_filtered = Data.S.S2.delta_filtered(Data.T0:Data.T1); 
waitbar(0.5,f,'Operation Completed');

Data.S.S3.PFCsup = Data.S.S3.PFCsup_raw(Data.T0:Data.T1);                   %PFCsup signal time selection
Data.S.S3.PFCdeep = Data.S.S3.PFCdeep_raw(Data.T0:Data.T1);                 %PFCdeep signal time selection


Data.S.S3.PFCdif = Data.S.S3.PFCdeep - Data.S.S3.PFCsup;
% Data.S.S3.PFCdif_filtered = filtfilt(Filter.PFCdif_A,Filter.PFCdif_B,Data.S.S3.PFCdif);
% Data.S.S3.PFCdif_filtered = Data.S.S3.PFCdif_filtered(Data.T0:Data.T1);   

waitbar(1,f,'Operation Completed');
pause(0.5);
close(f);

end