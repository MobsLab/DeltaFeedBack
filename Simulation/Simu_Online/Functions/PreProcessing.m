%% Pre Processing 
%This function downsamples signals to 312.5 Hz, and performs gamma, theta 
%and delta filtering.

%Prefactors are computed by dividing the two variances of PFCsup and
%PFCdeep.

%Delta threshold for detection is computed from the std of the filtered
%(PrefactorDeep * PFCdeep - PrefactorSup * PFCsup) signal.

%AllResult matrix is also initalize


function Signals = PreProcessing (Signals,Interface,Filter)

f = waitbar(0,'Down Sampling Signal ...');

Signals.t = Signals.t(uint32(Signals.DB_duration/2:Signals.DB_duration:end-Signals.DB_duration/2)); 

%affecting mean value computed with Datablock too each point  
Signals.S.S1.gamma_raw = movmean(Signals.S.S1.gamma_raw,Signals.DB_duration);        
Signals.S.S2.thetadelta_raw = movmean(Signals.S.S2.thetadelta_raw,Signals.DB_duration);        
Signals.S.S3.PFCsup_raw = movmean(Signals.S.S3.PFCsup_raw,Signals.DB_duration);          
Signals.S.S3.PFCdeep_raw = movmean(Signals.S.S3.PFCdeep_raw,Signals.DB_duration);       

%down sampling to replace each DataBlock by one point:  the Datablock center 
Signals.S.S1.gamma_raw = Signals.S.S1.gamma_raw(uint32(Signals.DB_duration/2:Signals.DB_duration:end-Signals.DB_duration/2));          
Signals.S.S2.thetadelta_raw = Signals.S.S2.thetadelta_raw(uint32(Signals.DB_duration/2:Signals.DB_duration:end-Signals.DB_duration/2));
Signals.S.S3.PFCsup_raw = Signals.S.S3.PFCsup_raw(uint32(Signals.DB_duration/2:Signals.DB_duration:end-Signals.DB_duration/2));
Signals.S.S3.PFCdeep_raw = Signals.S.S3.PFCdeep_raw(uint32(Signals.DB_duration/2:Signals.DB_duration:end-Signals.DB_duration/2));

waitbar(0.25,f,'Filtering Signal ...');

%Fitlers definition 
Filter.gamma = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 50,'CutoffFrequency2',70,'SampleRate',Signals.fs); 
Filter.theta = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 5,'CutoffFrequency2',10,'SampleRate',Signals.fs);
Filter.delta = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 2,'CutoffFrequency2',5,'SampleRate',Signals.fs); 

%Filtering
Signals.S.S1.gamma_filtered_raw = filtfilt(Filter.gamma,Signals.S.S1.gamma_raw);     
Signals.S.S2.theta_filtered_raw = filtfilt(Filter.theta,Signals.S.S2.thetadelta_raw);
Signals.S.S2.delta_filtered_raw = filtfilt(Filter.delta,Signals.S.S2.thetadelta_raw);

%Prefactors 
waitbar(0.5,f,'Determining Prefacors ...');

load(strcat(Signals.dname,'/Processed/SleepScoring_OBGamma.mat'),'SWSEpoch','TotalNoiseEpoch','Epoch');       
%Epoch corresponding to SWS sleep without the noise 
TS = and(Epoch-TotalNoiseEpoch,SWSEpoch);

%Selecting SWS Sleep without Noise Epoch 
Signals.S.S3.PFCsup_LFP_SWS = Restrict(Signals.S.S3.PFCsup_LFP,TS);
Signals.S.S3.PFCdeep_LFP_SWS = Restrict(Signals.S.S3.PFCdeep_LFP,TS);

%Computing Variances 
var_sup = var(Data(Signals.S.S3.PFCsup_LFP_SWS));
var_deep = var(Data(Signals.S.S3.PFCdeep_LFP_SWS));

%Computing Prefators 
Signals.deep_prefactor = 1;
Signals.sup_prefactor = var_deep/var_sup;

%Setting Prefactors in the Interface 
set(Interface.Sup_prefactor_edit,'String',num2str(Signals.sup_prefactor));
set(Interface.Deep_prefactor_edit,'String',num2str(Signals.deep_prefactor));

%Delta threshold 
waitbar(0.5,f,'Determining Delta Threshold ...');

%Computing PFCdeep _ PFCsup with prefactors 
diff_temp = Data(Signals.S.S3.PFCdeep_LFP_SWS) - Signals.sup_prefactor * Data(Signals.S.S3.PFCsup_LFP_SWS);                                   

%Filtering 
b = fir1(1024,[1 12]*(2/Signals.fs));
diff_temp_filtered = filtfilt(b,1,diff_temp);

%Selecting positive values 
pos_diff_temp = max(diff_temp_filtered,0);

%Computing std that determines threshold
std_diff = std(pos_diff_temp(pos_diff_temp>0));                            

Signals.delta_treshold = 2 * std_diff * 0.195e-3;

set(Interface.delta_edit,'String',num2str(Signals.delta_treshold));

waitbar(1,f,'Operation Completed');
pause(0.5);
close(f);

%Initializing AllResults matrix 
Signals.AllResults = zeros(round(size(Signals.t,1)/312),2);

%Settint PreProcessed indicator to 1
Signals.PreProcessed = 1;

end