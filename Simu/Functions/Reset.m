function [Data,Interface] = Reset (Data,Interface)

if strcmp(get(Interface.timer, 'Running'), 'on')
    stop(Interface.timer);
    Data.Implement_counter = 0
end


clear Data 

Data=Data;
Interface=Interface;

%Data properties 
Data.Fs = 1250;                                     %sampling frequency raw signal
Data.Dt = 1/Data.Fs;                                %time between 2 samples raw signal

Data.DB_duration = 4;                               %duration of datablocks (points) on which we compute the mean to downsample signals

Data.fs = Data.Fs/Data.DB_duration;                 %sampling frequency downsampled signal
Data.dt = 1/Data.fs;                                %time between 2 samples downsampled signal

Data.Time_implement = Data.DB_duration * Data.fs;


Data.S = struct;                                    %structure containing signals
Data.Path = struct;                                 %structure containing signals paths


Data.Implement_counter = 0;                         %counting Data implementations already implemented

Data.Hilbert_counter = 0;                           %counting hilbert transforms already computed 


Data.delta_points_counter = 0;                      %counting current delta wave duration (in number of points)
Data.Delta_Detection = [];                          
Data.delta_time_detection = [];                     %times(in sec) at which delta wave are detected
Data.delta_durations = [];                          %durations of detected delta waves

Data.sleep_state = [];                              %sleep state (SWS, REM, WAKE);

Data.ratio_treshold_temp = 0.6;
Data.gamma_treshold_temp= -1.6;
Data.delta_treshold_temp= 0.3;

Data.sup_prefactor = 1;
Data.deep_prefactor = 1;

Data.S.S1.gamma_power = [];
Data.S.S2.theta_power = [];
Data.S.S2.delta_power = [];
Data.S.S2.ratio_power = [];



%Filters definitions
Filter.theta = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 6,'CutoffFrequency2',12,'SampleRate',Data.fs);
Filter.delta = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 2,'CutoffFrequency2',5,'SampleRate',Data.fs); 
Filter.gamma = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 50,'CutoffFrequency2',70,'SampleRate',Data.fs); 
Filter.PFCdif = butter(4, 4/(Data.fs/2));


%Interface properties
Interface.btn_t0_edit.String = 't0';
Interface.btn_t1_edit.String = 't1';

Interface.set_prefactors_checkbox_checkbox.Value = 0;
Interface.Sup_prefactor_edit.String = '1';
Interface.Deep_prefactor_edit.String = '1';

Interface.gamma_edit.String = '-1.6';
Interface.ratio_edit.String = '0.6';

Interface.detection_checkbox.Value = 0;
Interface.delta_edit.String = '0.3';

Interface.time_window= 3;           %time window for sleep scoring computations (s)
Interface.time_implement= Data.dt;  %time implementation at each updates

Interface.vline_gamma=[];
Interface.hline_ratio=[];
Interface.hline_delta=[];

Interface.Snapshot = [];
Interface.Detectionline1 = [];
Interface.Detectionline2 = [];

%Load Signals

f = waitbar(0,'Loading Signal ...');
x = evalin('base','load(gamma_path)');                                      %load signal
Data.S.S1.gamma_raw = x.Gamma * 0.195e-3;
x = evalin('base','load(thetadelta_path)'); 
Data.S.S2.thetadelta_raw = x.thetadelta * 0.195e-3;
x = evalin('base','load(PFCsup_path)'); 
Data.S.S3.PFCsup_raw = x.PFCsup * 0.195e-3; 
x = evalin('base','load(PFCdeep_path)');
Data.S.S3.PFCdeep_raw = x.PFCdeep * 0.195e-3; 

waitbar(0.25,f,'Down Sampling Signal ...');
Data.S.S1.gamma_raw = movmean(Data.S.S1.gamma_raw,Data.DB_duration);        %mean on the DataBlock duration 
Data.S.S2.thetadelta_raw = movmean(Data.S.S2.thetadelta_raw,Data.DB_duration);        
Data.S.S3.PFCsup_raw = movmean(Data.S.S3.PFCsup_raw,Data.DB_duration);          
Data.S.S3.PFCdeep_raw = movmean(Data.S.S3.PFCdeep_raw,Data.DB_duration);       

Data.S.S1.gamma_raw = Data.S.S1.gamma_raw(1:Data.DB_duration:end);          %down sampling to replace each DataBlock by one point
Data.S.S2.thetadelta_raw = Data.S.S2.thetadelta_raw(1:Data.DB_duration:end);
Data.S.S3.PFCsup_raw = Data.S.S3.PFCsup_raw(1:Data.DB_duration:end);
Data.S.S3.PFCdeep_raw = Data.S.S3.PFCdeep_raw(1:Data.DB_duration:end);

waitbar(0.5,f,'Filtering Signal ...');
Data.S.S1.gamma_filtered = filtfilt(Filter.gamma,Data.S.S1.gamma_raw);
Data.S.S2.theta_filtered = filtfilt(Filter.theta,Data.S.S2.thetadelta_raw);
Data.S.S2.delta_filtered = filtfilt(Filter.delta,Data.S.S2.thetadelta_raw);

waitbar(1,f,'Operation Completed');
pause(0.5);
close(f);

end