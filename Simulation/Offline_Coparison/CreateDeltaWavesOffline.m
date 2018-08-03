clear all
addpath(genpath('/home/mobsspectre/Dropbox/Kteam/PrgMatlab'));
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptisteProject/Processing'));

%% params
InputInfo.freq_delta = [1 12];
InputInfo.thresh_std = 2;
InputInfo.min_duration = 70;
InputInfo.max_duration = 220;
InputInfo.SaveDelta = 1;

%% Loading Signals
dname = uigetdir('/media/mobsspectre/Mobs/SleepScoring','Mice Experiment Folder Selection');                   %setting path of directory containing LFP signals  
[filename1,filepath1]=uigetfile({'*.*','All Files'},'Select Params File','/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptisteProject/ParamsSouris');
file=strcat(filepath1,filename1); 
paramsArray=readtable(file,'Delimiter',';','Format','%s%f');
mouse=struct;
mouse.PFCDeep=paramsArray{4,2};
mouse.PFCSup=paramsArray{5,2};
mouse.Bulb=paramsArray{1,2};
mouse.HPC=paramsArray{2,2};
name1=strsplit(filename1,'.');
mouse.Number=name1{1};

f = waitbar(0,'Loading Signal ...');
                                                                            
load(strcat(dname,'/Processed/LFPData/LFP',num2str(mouse.PFCDeep)));         %loading signals
PFCsup_LFP = LFP; clear LFP;
PFCsup = Data(PFCsup_LFP);
PFCsup = PFCsup * 0.195e-3; 

load(strcat(dname,'/Processed/LFPData/LFP',num2str(mouse.PFCSup)));
PFCdeep_LFP = LFP; clear LFP;
PFCdeep = Data(PFCdeep_LFP);
PFCdeep = PFCdeep * 0.195e-3; 

%% Pre_processing

waitbar(0.5,f,'Pre Processing ...');

time = Range(PFCsup_LFP)*1e-4;
Fs = 1/(median(diff(Range(PFCsup_LFP,'s'))));
fs = 312.5;                                                                 %sampling frequency downsampled signal
dt = 1/fs;                                                                  %time between 2 samples downsampled signal  
DB_duration = Fs/fs;                                                        %datablock duration
time = time(DB_duration/2:DB_duration:end-DB_duration/2);  

load(strcat(dname,'/Processed/SleepScoring_OBGamma.mat'),'SWSEpoch','TotalNoiseEpoch','Epoch');       %Prefactors
TS = and(Epoch-TotalNoiseEpoch,SWSEpoch);

PFCsup_LFP_SWS = Restrict(PFCsup_LFP,TS);
PFCdeep_LFP_SWS = Restrict(PFCdeep_LFP,TS);

var_sup = var(Data(PFCsup_LFP_SWS));
var_deep = var(Data(PFCdeep_LFP_SWS));

deep_prefactor = 1;
sup_prefactor = var_deep/var_sup;
sup_prefactor = 1;
                                                                             %Delta Treshold
diff_temp = Data(PFCdeep_LFP_SWS) - sup_prefactor * Data(PFCsup_LFP_SWS);                                   

b = fir1(1024,[1 12]*(2/fs));
diff_temp_filtered = filtfilt(b,1,diff_temp);

pos_diff_temp = max(diff_temp_filtered,0);
std_diff = std(pos_diff_temp(pos_diff_temp>0));                             % std that determines thresholds

delta_treshold = 2 * std_diff * 0.195e-3;
delta_treshold = 0.2;

waitbar(0.75,f,'Down Sampling Signal ...');
                                                                            
PFCsup = movmean(PFCsup,DB_duration);                                       %movmean with DataBlock Size  
PFCdeep = movmean(PFCdeep,DB_duration);       
PFCsup = PFCsup(DB_duration/2:DB_duration:end-DB_duration/2);               %down sampling to replace each DataBlock by its center 
PFCdeep = PFCdeep(DB_duration/2:DB_duration:end-DB_duration/2);

PFCsup_LFP = tsd(time*1e4,PFCsup);
PFCdeep_LFP = tsd(time*1e4,PFCdeep);

waitbar(1,f,'Operation Completed');
pause(0.5);
close(f);

%% filter & positive value
EEGsleepDiff = tsd(time*1e4,Data(PFCdeep_LFP) - sup_prefactor * Data(PFCsup_LFP));

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

uisave('offlinedetection',strcat(dname,'/DeltaDetection/offlinedetection.mat'));