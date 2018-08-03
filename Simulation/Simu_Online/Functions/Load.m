%% Load
%This function loads Signals from the mouse directory. User also have to 
%select the correpsonding mouse parameter file so the code can determine
%what channel to load and initalise thresholds for sleep scoring. 

%.mat files are generated from tsd objects.

%We keep real timestamps from acquisition for the time vector used in this
%simulaiton 

function [Signals,Filter,Interface] = Load (Signals,Filter,Interface)
    
%setting path of directory containing signals  
Signals.dname = uigetdir('/media/mobsspectre/Mobs/SleepScoring','Mice Experiment Folder Selection'); 
[filename1,filepath1]=uigetfile({'*.*','All Files'},'Select Params File','/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptisteProject/ParamsSouris');
file=strcat(filepath1,filename1); 
Signals.paramsArray=readtable(file,'Delimiter',';','Format','%s%f');
mouse=struct;
mouse.PFCDeep=Signals.paramsArray{4,2};
mouse.PFCSup=Signals.paramsArray{5,2};
mouse.Bulb=Signals.paramsArray{1,2};
mouse.HPC=Signals.paramsArray{2,2};
Signals.gamma_treshold = Signals.paramsArray{6,2};
set(Interface.gamma_edit,'String',num2str(Signals.gamma_treshold));
Signals.ratio_treshold  = Signals.paramsArray{7,2};
set(Interface.ratio_edit,'String',num2str(Signals.ratio_treshold));

f = waitbar(0,'Loading Signal ...');

%loading signals                                                                      
load(strcat(Signals.dname,'/Processed/LFPData/LFP',num2str(mouse.PFCSup)),'LFP');         
Signals.S.S3.PFCsup_LFP = LFP; clear LFP;
Signals.S.S3.PFCsup_raw = Data(Signals.S.S3.PFCsup_LFP);
Signals.S.S3.PFCsup_raw = Signals.S.S3.PFCsup_raw * 0.195e-3; 

waitbar(0.25,f,'Loading Signal ... ...');

load(strcat(Signals.dname,'/Processed/LFPData/LFP',num2str(mouse.PFCDeep)),'LFP');
Signals.S.S3.PFCdeep_LFP = LFP; clear LFP;
Signals.S.S3.PFCdeep_raw = Data(Signals.S.S3.PFCdeep_LFP);
Signals.S.S3.PFCdeep_raw = Signals.S.S3.PFCdeep_raw * 0.195e-3;                         

waitbar(0.5,f,'Loading Signal ... ...');

load(strcat(Signals.dname,'/Processed/LFPData/LFP',num2str(mouse.Bulb)),'LFP');
Signals.S.S1.gamma_LFP = LFP; clear LFP;
Signals.S.S1.gamma_raw = Data(Signals.S.S1.gamma_LFP);
Signals.S.S1.gamma_raw = Signals.S.S1.gamma_raw * 0.195e-3;   

waitbar(0.75,f,'Loading Signal ... ...');

load(strcat(Signals.dname,'/Processed/LFPData/LFP',num2str(mouse.HPC)),'LFP');
Signals.S.S2.thetadelta_LFP = LFP; clear LFP;
Signals.S.S2.thetadelta_raw = Data(Signals.S.S2.thetadelta_LFP);
Signals.S.S2.thetadelta_raw = Signals.S.S2.thetadelta_raw * 0.195e-3;

%Time Vector is created with real timestamps from acquisition
Signals.t = Range(Signals.S.S3.PFCsup_LFP)*1e-4;
Signals.Fs = 1/(median(diff(Range(Signals.S.S3.PFCsup_LFP,'s'))));
Signals.fs = 312.5;                                                     %sampling frequency downsampled signal
Signals.dt = 1/Signals.fs;                                              %time between 2 samples downsampled signal  
Signals.DB_duration = Signals.Fs/Signals.fs;                            %datablock duration 

waitbar(1,f,'Operation Completed');
pause(0.5);
close(f);

end

