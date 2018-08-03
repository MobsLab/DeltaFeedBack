%% time_selection 
%This functions restricts signals to time selection limits to and t1
%entered by the user on the interface. It also resets some parameters to
%restart a new session with time-selected signals once Run button will be
%pushed. 

function Data = time_selection (Data)

%time selection
Data.TimeSelection = 1;

%Reset Data Properties 
Data.Implement_counter = 0;

Data.delta_points_counter = 0;  
Data.delta_durations = [];
Data.delta_time_detection = [];
Data.Delta_Detection = [];

Data.Hilbert_counter = 0;
Data.S.S1.gamma_power = [];
Data.S.S2.theta_power = [];
Data.S.S2.delta_power = [];
Data.S.S2.ratio_power = [];

%Select Time Span 
f= waitbar(0,'Selecting Time Span...');
Data.S.S1.gamma = Data.S.S1.gamma_raw(Data.T0:Data.T1);                     %gamma signal time selection
Data.S.S1.gamma_filtered = Data.S.S1.gamma_filtered_raw(Data.T0:Data.T1);
waitbar(0.25,f,'Selecting Time Span...');
Data.S.S2.thetadelta = Data.S.S2.thetadelta_raw(Data.T0:Data.T1);           %thetadelta signal time selection
Data.S.S2.theta_filtered = Data.S.S2.theta_filtered_raw(Data.T0:Data.T1); 
Data.S.S2.delta_filtered = Data.S.S2.delta_filtered_raw(Data.T0:Data.T1);
waitbar(0.5,f,'Selecting Time Span...');
Data.S.S3.PFCsup = Data.S.S3.PFCsup_raw(Data.T0:Data.T1);                   %PFCsup signal time selection
Data.S.S3.PFCdeep = Data.S.S3.PFCdeep_raw(Data.T0:Data.T1);                 %PFCdeep signal time selection
Data.S.S3.PFCdif = Data.S.S3.PFCdeep - Data.S.S3.PFCsup;
   
waitbar(1,f,'Operation Completed');
pause(0.5);
close(f);

end