%%%%%%%%%%%%%%%%%%%%%%%%%%%Check_Delta8NoDisplay%%%%%%%%%%%%%%%%%%%%%%%%%%%
%25/07/2018
%Adrien Bertolo 


clear all
clc
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/MOBS_Code/PrgMatlab'));
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/Code/Processing'));

%% Initializaiton
Implement_counter = 0;

delta_points_counter = 0;                                                   %counting current delta wave duration (in number of points)
Delta_Detection = [];                          
delta_time_detection = [];                                                  %times(in sec) at which delta wave are detected
delta_durations = [];                                                       %durations of detected delta waves

time_window = 3;                                                            %time window for sleep scoring computations (s)

%% Loading Signals
                                                                            %setting path of directory containing LFP signals  
dname = uigetdir('/media/mobsspectre/Mobs/SleepScoring','Mice Experiment Folder Selection');                  
[filename1,filepath1]=uigetfile({'*.*','All Files'},'Select Params File','/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/ParamsSouris');
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
                                                                            
load(strcat(dname,'/Processed/LFPData/LFP',num2str(mouse.PFCSup)));         %loading signals
PFCsup_LFP = LFP; clear LFP;
PFCsup = Data(PFCsup_LFP);
PFCsup = PFCsup * 0.195e-3; 
load(strcat(dname,'/Processed/LFPData/LFP',num2str(mouse.PFCDeep)));
PFCdeep_LFP = LFP; clear LFP;
PFCdeep = Data(PFCdeep_LFP);
PFCdeep = PFCdeep * 0.195e-3;                                               %important step to convert in mV

%% Pre_processing

waitbar(0.5,f,'Pre Processing ...');

time = Range(PFCsup_LFP)*1e-4;
Fs = 1/(median(diff(Range(PFCsup_LFP,'s'))));
fs = 312.5;                                                                 %sampling frequency downsampled signal
dt = 1/fs;                                                                  %time between 2 samples downsampled signal  
DB_duration = Fs/fs;                                                        %datablock duration
time = time(DB_duration/2:DB_duration:end-DB_duration/2);  

[Filter_PFCdif_A, Filter_PFCdif_B] = butter(2, 8/(fs/2));                   %Fitler definition

                                                                            %Prefactors
load(strcat(dname,'/Processed/SleepScoring_OBGamma.mat'),'SWSEpoch','TotalNoiseEpoch','Epoch');       
TS = and(Epoch-TotalNoiseEpoch,SWSEpoch);

PFCsup_LFP_SWS = Restrict(PFCsup_LFP,TS);
PFCdeep_LFP_SWS = Restrict(PFCdeep_LFP,TS);


var_sup = var(Data(PFCsup_LFP_SWS));
var_deep = var(Data(PFCdeep_LFP_SWS));

deep_prefactor = 1;
sup_prefactor = var_deep/var_sup;
                                                                             %Delta Treshold
diff_temp = Data(PFCdeep_LFP_SWS) - sup_prefactor * Data(PFCsup_LFP_SWS);                                   

b = fir1(1024,[1 12]*(2/fs));
diff_temp_filtered = filtfilt(b,1,diff_temp);

pos_diff_temp = max(diff_temp_filtered,0);
std_diff = std(pos_diff_temp(pos_diff_temp>0));                             % std that determines thresholds

delta_treshold = 2 * std_diff * 0.195e-3;

waitbar(0.75,f,'Down Sampling Signal ...');
                                                                            
PFCsup = movmean(PFCsup,DB_duration);                                       %affecting mean value of each Datablock too each point of this same DataBlock  
PFCdeep = movmean(PFCdeep,DB_duration);       
PFCsup = PFCsup(DB_duration/2:DB_duration:end-DB_duration/2);               %down sampling to replace each DataBlock by one point
PFCdeep = PFCdeep(DB_duration/2:DB_duration:end-DB_duration/2);

waitbar(1,f,'Operation Completed');
pause(0.5);
close(f);

%% Run the loop

if Implement_counter == 0
    
    f = waitbar(0,'Please wait...');
    
                                                                            %initializations for update_display function
    waitbar(0.5,f,'Initializing time parameters for simulation ...');
    subscripts = 1:time_window*fs;                                          %points subscripts of the first 3s window 
    acq_time = time(end);                                                   %signal selection time length
    N_Implement = size(PFCsup,1) - 1;                                       %total number of Data implementations we will have to do to read all the signal
    PFCdif_temp_filtered = zeros (size(subscripts));
    t_tmp = time(subscripts);                                               %temp time vector
    waitbar(1,f,'Operation Completed');
    pause(0.5);
    close(f);

end

f = waitbar(0,'Please wait...');

snap = figure; 
snap_ax = axes('Parent',snap,'Units','normalized','Visible','on','HandleVisibility','on');
snap_plot = plot(0,0,0,0,0,0);
set(snap_plot(1),'Color','blue');
set(snap_plot(2),'Color',[0 0.5 0]);
set(snap_plot(3),'Color','red');

for i = 1:N_Implement - (size(subscripts,2)+1) 

    if mod(i,round((N_Implement-(size(subscripts,2)+1))/64)) ==0
      waitbar(i/round(N_Implement-size(subscripts,2)+1),f,'Detecting Delta Waves ...');  
    end
      
    PFCsup_temp = PFCsup(subscripts) * sup_prefactor;
    PFCdeep_temp = PFCdeep(subscripts) * deep_prefactor;
    PFCdif_temp = PFCdeep_temp - PFCsup_temp;
    
    filtered = filtfilt(Filter_PFCdif_A,Filter_PFCdif_B,PFCdif_temp);
    PFCdif_temp_filtered = [PFCdif_temp_filtered(2:end) filtered(end)];
    
    
    if PFCdif_temp_filtered(end) - delta_treshold >= 0                      %check if current point is above treshold

        if PFCdif_temp_filtered(end-1) - delta_treshold < 0                 %check if last point was not above --> beginning of a potential delta wave 
            
                                                                            %start counting points 
            delta_points_counter = delta_points_counter+1;
            delta_time_detection = [delta_time_detection ; t_tmp(end)];     %add detection time to time detection array
            
        else
            delta_points_counter = delta_points_counter+1;                  %if last point was not above --> continue to count

        end
                                                                            %if current point is below tresholdcheck then check if last point was above --> ending of a potential delta wave
    elseif PFCdif_temp_filtered(end-1) - delta_treshold >= 0  && ~isempty(delta_time_detection)  
                                                                            %check if potential delta wave is longer than 50 ms
        if delta_points_counter * dt > 0.05 && delta_points_counter * dt < 0.15                

                                                                            %add delta wave duration to delta duration array
            delta_durations = [delta_durations ; (delta_points_counter*dt)];                    
            
            t0 = delta_time_detection(end);                                 %plot delta wave snapshot
            duration = delta_durations(end)/dt;
            t1 = delta_time_detection(end)+delta_durations(end);
            delta_points_counter = 0;
            
        else
            delta_points_counter = 0;

            if ~isempty(delta_time_detection)
            delta_time_detection (end) = [];                                %erase too short delta wave time detection
            end
        end

    end
    
    %implement new cycle
    Implement_counter = Implement_counter + 1;
    subscripts = subscripts + 1;
    t_tmp = time(subscripts);
    
end

if size (delta_time_detection,1) ~= size(delta_durations,1)
delta_time_detection(end)=[];
end

waitbar(1,f,'Operation Completed');
pause(0.5);
close(f);

Delta_Detection = [delta_time_detection (delta_time_detection + delta_durations)];
uisave('Delta_Detection',strcat(dname,'/DeltaDetection/onlinedetection.mat'));

