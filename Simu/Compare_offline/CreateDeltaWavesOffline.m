clear all

%% paths
detection_number = '1';
mouse = 'Mice244/20150401/';
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/MOBS_Code/PrgMatlab'));
datapath = strcat('/home/mobsspectre/Documents/MATLAB/Simu/Offline/',mouse,'LFPData/');
savingpath = strcat('/home/mobsspectre/Documents/MATLAB/Simu/Offline/',mouse,'DeltaDetection/');

%% params
InputInfo.freq_delta = [1 12];
InputInfo.thresh_std = 2;
InputInfo.min_duration = 50;
InputInfo.max_duration = 150;
InputInfo.SaveDelta = 1;

%% loadLFP
load(strcat(datapath,'LFP4.mat'));
LFPdeep = LFP;
clear LFP;
load(strcat(datapath,'LFP25.mat'));
LFPsup = LFP;

%% normalize
clear distance
k=1;
for i=0.1:0.1:4
    distance(k)=std(Data(LFPdeep)*0.195e-3-i*Data(LFPsup)*0.195e-3);
    k=k+1;
end
Factor = find(distance==min(distance))*0.1;

%% resample & filter & positive value
EEGsleepDiff = ResampleTSD(tsd(Range(LFPdeep),Data(LFPdeep)*0.195e-3 - Factor*Data(LFPsup)*0.195e-3),312);

Fn = 1/(median(diff(Range(EEGsleepDiff,'s'))));

% b = fir1(1024,InputInfo.freq_delta*2/Fn);
% dEeg = filtfilt(b,1,Data(EEGsleepDiff));

[A, B] = butter(2, 4/(Fn/2));
dEeg = filtfilt(A,B,Data(EEGsleepDiff));

rg = Range(EEGsleepDiff);
Filt_diff = tsd(rg,dEeg);

pos_filtdiff = max(Data(Filt_diff),0);


%% stdev
std_diff = std(pos_filtdiff(pos_filtdiff>0));  % std that determines thresholds


%% deltas
% thresh_delta = InputInfo.thresh_std * std_diff;
% thresh_delta = 0.11929; %2430409
thresh_delta = 0.07290; %2440401
all_cross_thresh = thresholdIntervals(tsd(Range(Filt_diff), pos_filtdiff), thresh_delta, 'Direction', 'Above');

offlinedetection = dropShortIntervals(all_cross_thresh, InputInfo.min_duration * 10); % crucial element for noise detection.

offlinedetection = dropLongIntervals(offlinedetection, InputInfo.max_duration * 10); 

%offlinedetection = all_cross_thresh;

offlinedetection = [Start(offlinedetection) Stop(offlinedetection)] * 1e-4;

save(strcat(savingpath,'offlinedetection',detection_number,'.mat'),'offlinedetection');