function offlinedetection = CreateDeltaWavesOffline (dname,detection_matrix_path)


%% params
InputInfo.freq_delta = [1 12];
InputInfo.thresh_std = 2;
InputInfo.min_duration = 70;
InputInfo.max_duration = 220;
InputInfo.SaveDelta = 1;

%% Loading Signals
[filename1,filepath1]=uigetfile({'*.*','All Files'},'Select Params File','/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptisteProject/ParamsSouris');
file=strcat(filepath1,filename1); 
paramsArray=readtable(file,'Delimiter',';','Format','%s%f');
mouse=struct;
mouse.PFCDeep=paramsArray{5,2};
mouse.PFCSup=paramsArray{4,2};
mouse.Bulb=paramsArray{1,2};
mouse.HPC=paramsArray{2,2};
name1=strsplit(filename1,'.');
mouse.Number=name1{1};
                                                                            
load(strcat(dname,'/Processed/LFPData/LFP',num2str(mouse.PFCDeep)),'LFP');        %loading signals
PFCsup_LFP = LFP; clear LFP;
PFCsup = Data(PFCsup_LFP);
PFCsup = PFCsup * 0.195e-3; 

load(strcat(dname,'/Processed/LFPData/LFP',num2str(mouse.PFCSup)),'LFP');
PFCdeep_LFP = LFP; clear LFP;
PFCdeep = Data(PFCdeep_LFP);
PFCdeep = PFCdeep * 0.195e-3; 

load(strcat(dname,'/Processed/SleepScoring_OBGamma.mat'),'SWSEpoch','TotalNoiseEpoch','Epoch');       

time = Range(PFCsup_LFP)*1e-4;
Fs = 1/(median(diff(Range(PFCsup_LFP,'s'))));
fs = 312.5;                                                                 %sampling frequency downsampled signal
dt = 1/fs;                                                                  %time between 2 samples downsampled signal  
DB_duration = Fs/fs;                                                        %datablock duration
time = time(DB_duration/2:DB_duration:end-DB_duration/2);  

%% Optimization

prompt = 'Same values than during experiment / Optimize Delta Threshold and Prefactors offline  ? (1/0)';

if  input(prompt) == 0
    [deep_prefactor,sup_prefactor,delta_treshold] = Detection_optimization (fs,PFCsup_LFP,PFCdeep_LFP,Epoch,TotalNoiseEpoch,SWSEpoch);
else
    load(detection_matrix_path,'detections')
    onlinedetection = detections * 1e-4;
    deep_prefactor = onlinedetection(1,6);
    sup_prefactor = onlinedetection(1,8);
    delta_treshold = onlinedetection(1,5);
end


%% filter & positive value

%down_sampling signal
PFCsup = movmean(PFCsup,DB_duration);                                       %movmean with DataBlock Size  
PFCdeep = movmean(PFCdeep,DB_duration);       
PFCsup = PFCsup(DB_duration/2:DB_duration:end-DB_duration/2);               %down sampling to replace each DataBlock by its center 
PFCdeep = PFCdeep(DB_duration/2:DB_duration:end-DB_duration/2);

PFCsup_LFP = tsd(time*1e4,PFCsup);
PFCdeep_LFP = tsd(time*1e4,PFCdeep);

EEGsleepDiff = tsd(time*1e4,deep_prefactor * Data(PFCdeep_LFP) - sup_prefactor * Data(PFCsup_LFP));

[A, B] = butter(4, 8/(fs/2));
dEeg = filtfilt(A,B,Data(EEGsleepDiff));

rg = Range(EEGsleepDiff);
Filt_diff = tsd(rg,dEeg);

pos_filtdiff = max(Data(Filt_diff),0);

%% deltas

all_cross_thresh = thresholdIntervals(tsd(Range(Filt_diff), pos_filtdiff), delta_treshold, 'Direction', 'Above');

offlinedetection = dropShortIntervals(all_cross_thresh, InputInfo.min_duration * 10); % crucial element for noise detection.

offlinedetection = dropLongIntervals(offlinedetection, InputInfo.max_duration * 10); 

offlinedetection = [Start(offlinedetection) Stop(offlinedetection)] * 1e-4;

end