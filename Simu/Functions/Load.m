%%Load
%This function loads 'gamma.mat' (OB Gamma Signal), 'thetadelta.mat' (HPC
%Signal), 'PFCsup.mat' and 'PFCdeep.mat' files. 
%
function Data = Load (Data,Filter)

if isempty (Data.Fs) || isempty(Data.DB_duration) 
    f = warndlg('Please set Sampling Frequency and Datablock Size before loading signals','Warning');
    pause(1);
else
    dname = uigetdir(pwd,'Signals Folder Selection');                           %setting path of directory containing signals  
    Data.Path.gamma_path = strcat(dname,'/gamma.mat'); assignin('base','gamma_path',Data.Path.gamma_path);
    Data.Path.thetadelta_path = strcat(dname,'/thetadelta.mat'); assignin('base','thetadelta_path',Data.Path.thetadelta_path);
    Data.Path.PFCsup_path = strcat(dname,'/PFCsup.mat'); assignin('base','PFCsup_path',Data.Path.PFCsup_path);
    Data.Path.PFCdeep_path = strcat(dname,'/PFCdeep.mat'); assignin('base','PFCdeep_path',Data.Path.PFCdeep_path); 

    f = waitbar(0,'Loading Signal ...');
    load(Data.Path.gamma_path);                                                 %loading signals
    load(Data.Path.thetadelta_path); 
    load(Data.Path.PFCsup_path); 
    load(Data.Path.PFCdeep_path); 
    
    Data.S.S1.gamma_raw = Gamma  * 0.195e-3;                                    %important step to convert in mV
    Data.S.S2.thetadelta_raw = thetadelta * 0.195e-3;
    Data.S.S3.PFCsup_raw = PFCsup * 0.195e-3; 
    Data.S.S3.PFCdeep_raw = PFCdeep * 0.195e-3;    
    
    waitbar(0.25,f,'Down Sampling Signal ...');
    Data.S.S1.gamma_raw = movmean(Data.S.S1.gamma_raw,Data.DB_duration);        %affecting mean value of each Datablock too each point of this same DataBlock  
    Data.S.S2.thetadelta_raw = movmean(Data.S.S2.thetadelta_raw,Data.DB_duration);        
    Data.S.S3.PFCsup_raw = movmean(Data.S.S3.PFCsup_raw,Data.DB_duration);          
    Data.S.S3.PFCdeep_raw = movmean(Data.S.S3.PFCdeep_raw,Data.DB_duration);       
    
    Data.S.S1.gamma_raw = Data.S.S1.gamma_raw(1:Data.DB_duration:end);          %down sampling to replace each DataBlock by one point
    Data.S.S2.thetadelta_raw = Data.S.S2.thetadelta_raw(1:Data.DB_duration:end);
    Data.S.S3.PFCsup_raw = Data.S.S3.PFCsup_raw(1:Data.DB_duration:end);
    Data.S.S3.PFCdeep_raw = Data.S.S3.PFCdeep_raw(1:Data.DB_duration:end);
    
    waitbar(0.5,f,'Filtering Signal ...');
    Data.S.S1.gamma_filtered = filtfilt(Filter.gamma,Data.S.S1.gamma_raw);     %filter 
    Data.S.S2.theta_filtered = filtfilt(Filter.theta,Data.S.S2.thetadelta_raw);
    Data.S.S2.delta_filtered = filtfilt(Filter.delta,Data.S.S2.thetadelta_raw);
    
    waitbar(1,f,'Operation Completed');
    pause(0.5);
    close(f);
end

end