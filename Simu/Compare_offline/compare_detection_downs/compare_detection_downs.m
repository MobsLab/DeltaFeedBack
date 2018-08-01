%This function computes the mean MUA, the mean LFP PFCdeep, the mean LFP  
%PFCsup and the difference during Down States, Online Detection and 
%OfflineDetection. It also computes the mean on Detections which are not 
%corresponding to downstates. 

clear all
clc

%% Paths

detection_number = '1'; %Number of the detection (last string in the matrix filename) in the detection folder 
folderpath = '/home/mobsspectre/Documents/MATLAB/Simu/Offline/';
mouse = 'Mice243/20150409/';
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/MOBS_Code/PrgMatlab'));
addpath(genpath('/home/mobsspectre/Documents/MATLAB/Simu/Compare_offline/compare_detection_downs'));
datapath = strcat('/home/mobsspectre/Documents/MATLAB/Simu/Offline/',mouse,'LFPData/');
onlinepath = strcat(folderpath,mouse,'DeltaDetection/onlinedetection',detection_number,'.mat');
offlinepath = strcat(folderpath,mouse,'DeltaDetection/offlinedetection',detection_number,'.mat');
MUApath = strcat(folderpath,mouse);
downpath = strcat(folderpath,mouse,'DownState.mat');
cd(MUApath);

%% IntervalSets: onlinedetection, offlinedetection, downstates

%mergeGap (in 1e-4 s)
delay = 1e4;
mergeGap = 100;

%Downstates
load(strcat(MUApath,'DownState.mat'));
DownStatesCenters = (Start(down_PFCx) + Stop(down_PFCx)) ./2;
downstates = intervalSet(Start(down_PFCx)-1e4, Start(down_PFCx)+1e4);
downstates_matrix = [Start(downstates) Stop(downstates)];

%Detection matrix
load(onlinepath);
[onlinedetection,onlinedetection_matrix,OnlineDetectionCenters] = process_detection (onlinedetection,delay,mergeGap);

load(offlinepath);
[offlinedetection,offlinedetection_matrix,OfflineDetectionCenters] = process_detection (offlinedetection,delay,mergeGap);

%OnlineDetection without Downstates
[status, ~, ~] = InIntervals(onlinedetection_matrix, downstates_matrix);
onlinedetection_matrix_bad = onlinedetection_matrix(find(status==0),:);
onlinedetection_bad = intervalSet(onlinedetection_matrix_bad(:,1), onlinedetection_matrix_bad(:,2));

[status, ~, ~] = InIntervals(offlinedetection_matrix, downstates_matrix);
offlinedetection_matrix_bad = offlinedetection_matrix(find(status==0),:);
offlinedetection_bad = intervalSet(offlinedetection_matrix_bad(:,1), offlinedetection_matrix_bad(:,2));

%% tsd: LFPdeep, LFPsp, MUA

%LFPdeep & LFPsup
load(strcat(datapath,'LFP4.mat'));
LFPdeep = LFP;
clear LFP;
LFPdeep = ResampleTSD(LFPdeep,100);
LFPdeep_Data = Data(LFPdeep);
time_LFPdeep = Range(LFPdeep)*1e-4;
freq_LFPdeep = 1/(time_LFPdeep(2) - time_LFPdeep(1));

load(strcat(datapath,'LFP25.mat'));
LFPsup = LFP;
clear LFP
LFPsup = ResampleTSD(LFPsup,100);
LFPsup_Data = Data(LFPsup);
time_LFPsup = Range(LFPsup)*1e-4;
freq_LFPsup = 1/(time_LFPsup(2) - time_LFPsup(1));

%MUA
load(strcat(MUApath,'/SpikesToAnalyse/PFCx_Neurons.mat'));
MUA = GetMuaNeurons_KJ(number);
MUA_Data = Data(MUA);
time_MUA = Range(MUA)*1e-4;
freq_MUA = 1/(time_MUA(2) - time_MUA(1));

%% Index arrays

onlinedetection_IndexArray = CreateIndexArray(onlinedetection_matrix,freq_LFPdeep);
onlinedetection_IndexArray_bad = CreateIndexArray(onlinedetection_matrix_bad,freq_LFPdeep);
offlinedetection_IndexArray = CreateIndexArray(offlinedetection_matrix,freq_LFPdeep);
offlinedetection_IndexArray_bad = CreateIndexArray(offlinedetection_matrix_bad,freq_LFPdeep);
downstates_IndexArray = CreateIndexArray(downstates_matrix,freq_LFPdeep);

%% MUA_mean & PFCdif_mean during DownStates

%mean on downstates_IndexArray
MUA_mean_ds = ComputeMean (MUA_Data,downstates_IndexArray,downstates_matrix);
MUA_mean_ds = MUA_mean_ds./(number(end)*10e-3);
LFPdeep_mean_ds = ComputeMean (LFPdeep_Data,downstates_IndexArray,downstates_matrix);
LFPsup_mean_ds = ComputeMean (LFPsup_Data,downstates_IndexArray,downstates_matrix);

%mean on onlinedetection_IndexArray
MUA_mean_on = ComputeMean (MUA_Data,onlinedetection_IndexArray,onlinedetection_matrix);
MUA_mean_on = MUA_mean_on./(number(end)*10e-3);
LFPdeep_mean_on = ComputeMean (LFPdeep_Data,onlinedetection_IndexArray,onlinedetection_matrix);
LFPsup_mean_on = ComputeMean (LFPsup_Data,onlinedetection_IndexArray,onlinedetection_matrix);

%mean on onlinedetection_IndexArray_bad
MUA_mean_on_bad = ComputeMean (MUA_Data,onlinedetection_IndexArray_bad,onlinedetection_matrix_bad);
MUA_mean_on_bad = MUA_mean_on_bad./(number(end)*10e-3);
LFPdeep_mean_on_bad = ComputeMean (LFPdeep_Data,onlinedetection_IndexArray_bad,onlinedetection_matrix_bad);
LFPsup_mean_on_bad = ComputeMean (LFPsup_Data,onlinedetection_IndexArray_bad,onlinedetection_matrix_bad);

%mean on offlinedetection_IndexArray
MUA_mean_off = ComputeMean (MUA_Data,offlinedetection_IndexArray,offlinedetection_matrix);
MUA_mean_off = MUA_mean_off./(number(end)*10e-3);
LFPdeep_mean_off = ComputeMean (LFPdeep_Data,offlinedetection_IndexArray,offlinedetection_matrix);
LFPsup_mean_off = ComputeMean (LFPsup_Data,offlinedetection_IndexArray,offlinedetection_matrix);

%mean on offlinedetection_IndexArray
MUA_mean_off_bad = ComputeMean (MUA_Data,offlinedetection_IndexArray_bad,offlinedetection_matrix_bad);
MUA_mean_off_bad = MUA_mean_off_bad./(number(end)*10e-3);
LFPdeep_mean_off_bad = ComputeMean (LFPdeep_Data,offlinedetection_IndexArray_bad,offlinedetection_matrix_bad);
LFPsup_mean_off_bad = ComputeMean (LFPsup_Data,offlinedetection_IndexArray_bad,offlinedetection_matrix_bad);


%% Display Results
figure;

subplot(4,3,1)
hold on;
ylim([0 8]);
plot(-1000:10:990,MUA_mean_ds,'b');
ax=gca;
h = plot([0 0], ax.YLim,'Color',[0 0.3 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('Taux de décharge (Hz)');
title('mean(MUA) during DownStates');
legend(h,'DownState Start','location','southwest')
subplot(4,3,4)
hold on;
ylim([-600 1400]);
plot(-1000:10:990,LFPdeep_mean_ds,'b')
ax=gca;
h = plot([0 0], ax.YLim,'Color',[0 0.3 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP signals (mV)');
title('mean(LFPdeep) during DownStates');
legend(h,'DownState Start','location','southwest')
subplot(4,3,7)
hold on;
ylim([-600 500]);
plot(-1000:10:990,LFPsup_mean_ds,'b')
ax=gca;
h = plot([0 0], ax.YLim,'Color',[0 0.3 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP signals (mV)');
title('mean(LFPsup) during DownStates');
legend(h,'DownState Start','location','southwest')
subplot(4,3,10)
hold on;
ylim([-600 1400]);
plot(-1000:10:990,LFPdeep_mean_ds-LFPsup_mean_ds,'b');
ax=gca;
h = plot([0 0], ax.YLim,'Color',[0 0.3 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP(PFCdeep) - LFP(PFCsup) (mV)');
title('mean(LFP_d) during DownStates');
legend(h,'DownState Start','location','northwest');


subplot(4,3,2)
hold on;
ylim([0 8]);
plot(-1000:10:990,MUA_mean_on,'b');
plot(-1000:10:990,MUA_mean_on_bad,'r');
ax=gca;
plot([0 0], ax.YLim,'Color',[0 0.8 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('Taux de décharge (Hz)');
title('mean(MUA) during OnlineDetection');
legend({'All online detections', 'No DownState','Detection start'},'FontSize',8,'location','southwest');
subplot(4,3,5)
hold on;
ylim([-600 1400]);
plot(-1000:10:990,LFPdeep_mean_on,'b')
plot(-1000:10:990,LFPdeep_mean_on_bad,'r')
ax=gca;
plot([0 0], ax.YLim,'Color',[0 0.8 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP signals (mV)');
title('mean(LFPdeep) during OnlineDetection');
legend({'All online detections', 'No DownState','Detection start'},'FontSize',8,'location','northwest');
subplot(4,3,8)
hold on;
ylim([-600 500]);
plot(-1000:10:990,LFPsup_mean_on,'b')
plot(-1000:10:990,LFPsup_mean_on_bad,'r')
ax=gca;
plot([0 0], ax.YLim,'Color',[0 0.8 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP signals (mV)');
title('mean(LFPsup) during OnlineDetection');
legend({'All online detections', 'No DownState','Detection start'},'FontSize',8,'location','northwest');
subplot(4,3,11)
hold on;
ylim([-600 1400]);
plot(-1000:10:990,LFPdeep_mean_on-LFPsup_mean_on,'b');
plot(-1000:10:990,LFPdeep_mean_on_bad-LFPsup_mean_on_bad,'r');
ax=gca;
plot([0 0], ax.YLim,'Color',[0 0.8 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP(PFCdeep) - LFP(PFCsup) (mV)');
title('mean(LFP_d) during OnlineDetection');
legend({'All online detections', 'No DownState','Detection start'},'FontSize',8,'location','northwest');


subplot(4,3,3)
hold on 
ylim([0 8]);
plot(-1000:10:990,MUA_mean_off,'b');
plot(-1000:10:990,MUA_mean_off_bad,'r');
ax=gca;
plot([0 0], ax.YLim,'Color',[0 0.8 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('Taux de décharge (Hz)');
title('mean(MUA) during OfflineDetection');
legend({'All online detections', 'No DownState','Detection start'},'FontSize',8,'location','southwest');
subplot(4,3,6)
hold on;
ylim([-600 1400]);
plot(-1000:10:990,LFPdeep_mean_off,'b')
plot(-1000:10:990,LFPdeep_mean_off_bad,'r')
ax=gca;
plot([0 0], ax.YLim,'Color',[0 0.8 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP signals (mV)');
title('mean(LFPdeep) during OfflineDetection');
legend({'All online detections', 'No DownState','Detection start'},'FontSize',8,'location','northwest');
subplot(4,3,9)
hold on;
ylim([-600 500]);
plot(-1000:10:990,LFPsup_mean_off,'b')
plot(-1000:10:990,LFPsup_mean_off_bad,'r')
ax=gca;
plot([0 0], ax.YLim,'Color',[0 0.8 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP signals (mV)');
title('mean(LFPsup) during OfflineDetection');
legend({'All online detections', 'No DownState','Detection start'},'FontSize',8,'location','northwest');
subplot(4,3,12)
hold on;
ylim([-600 1400]);
plot(-1000:10:990,LFPdeep_mean_off-LFPsup_mean_off,'b');
plot(-1000:10:990,LFPdeep_mean_off_bad-LFPsup_mean_off_bad,'r');
ax=gca;
plot([0 0], ax.YLim,'Color',[0 0.8 0],'LineStyle','--');
xlabel('time (ms)');
ylabel('LFP(PFCdeep) - LFP(PFCsup) (mV)');
title('mean(LFP_d) during OfflineDetection');
legend({'All online detections', 'No DownState','Detection start'},'FontSize',8,'location','northwest');

