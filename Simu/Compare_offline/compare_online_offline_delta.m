clear all
L=1;
%% Paths
detection_number = '2';
folderpath = '/home/mobsspectre/Documents/MATLAB/Simu/Offline/';
mouse = 'Mice739/20180710/';
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/MOBS_Code/PrgMatlab'));
onlinepath = strcat(folderpath,mouse,'DeltaDetection/onlinedetection',detection_number,'.mat');
offlinepath = strcat(folderpath,mouse,'DeltaDetection/offlinedetection',detection_number,'.mat');
downpath = strcat(folderpath,mouse,'DownState.mat');

%% initialization
f1_onoff_tot = zeros(3,76);
online_durations_tot  = [];
offline_durations_tot = [];
interduration_online_tot = [];
interduration_offline_tot  = [];
lags_online_tot = zeros(3,1001);
corr_online_tot = zeros(3,1001);
lags_offline_tot = zeros(3,1001);
corr_offline_tot = zeros(3,1001);
hist_online_offline_tot = zeros(3,1001);
precision_tot = zeros(3,1);
recall_tot = zeros(3,1);

%% Load online and offline detection matrix
load(onlinepath);
load(offlinepath);
load(downpath);

%% Parameters
% t0 = TimeSpan(1)*1e3;
% t1 = TimeSpan(2)*1e3;
t0 = 0;
t1 = round(onlinedetection(end,2)*1000,0);
%% Online detection curve
onlinedetection = 1000 * onlinedetection; %Time in ms

s = onlinedetection(end,2)+1; %intializing curve
Online_curve = zeros (t1-t0,1);

for i = 1 : size (onlinedetection,1)
    Online_curve (onlinedetection(i,1) : onlinedetection(i,2)) = 1; %creating curve
end

%% Offline detection curve
offlinedetection = 1000 * offlinedetection; %Time in ms

firstindex = min(find(offlinedetection(:,1)>t0)); %last index corresponding to online simulaiton duration
lastindex = max(find(offlinedetection(:,2)<t1)); %last index corresponding to online simulaiton duration

offlinedetection_selection = offlinedetection(firstindex:lastindex,:) - t0;

Offline_curve = zeros (t1-t0,1);

for i = 1 : size (offlinedetection_selection,1)
    Offline_curve (offlinedetection_selection(i,1) : offlinedetection_selection(i,2)) = 1; %creating curve
end

%% DownStates curve
DownStates = [Start(down_PFCx) Stop(down_PFCx)] ./ 10; %Time in ms

firstindex = min(find(DownStates(:,1)>t0)); %last index corresponding to online simulaiton duration
lastindex = max(find(DownStates(:,1)<t1)); %last index corresponding to online simulaiton duration

DownStates_selection = DownStates(firstindex:lastindex,:) - t0;

DownStates_curve = ones (t1-t0,1);

for i = 1 : size (DownStates_selection,1)
    DownStates_curve (DownStates_selection(i,1) : DownStates_selection(i,2)) = 0; %creating curve
end

%% Stats

%f1_score online/offline
f1_onoff = zeros (76,1);
precision = zeros (76,1);
recall = zeros (76,1);
j=1;

for i = 0:1:75
    
windowsize = i;

larger_interval = [offlinedetection_selection(:,1)-windowsize offlinedetection_selection(:,2)+windowsize];

[status, ~, ~] = InIntervals(onlinedetection, larger_interval);
% offline_only = Offline_curve(Offline_curve==1);
% online_only = Online_curve(Online_curve==1);
% total_positives_offline = length(offline_only);
% total_positives_online = length(online_only);
total_positives_offline = size(offlinedetection_selection,1);
total_positives_online = size(onlinedetection,1);

%true_positives = sum(status .* (onlinedetection(:,2) - onlinedetection(:,1)));
true_positives = sum(status);

false_positives = total_positives_online - true_positives;
false_negatives = total_positives_offline - true_positives;


precision(j) = true_positives / (true_positives + false_positives);
recall(j) = true_positives / (true_positives + false_negatives);

f1_onoff(j) = 2 * (precision(j) * recall(j)) / (precision(j) + recall(j));
%total_positives_offlinetotal_positotal_positives_offlinetives_offline
j = j+1;

end

% %f1_score online/DownStates
% [status, intervals_index, ~] = InIntervals(onlinedetection, DownStates_selection);
% 
% % offline_only = Offline_curve(Offline_curve==1);
% % DownStates_only = DownStates_curve(DownStates_curve==1);
% % total_positives_DS = length(DownStates_only);
% % total_positives_online = length(online_only);
% total_positives_DS = size(DownStates_selection,1);
% total_positives_online = size(onlinedetection,1);
% 
% true_positives = sum(status);
% false_positives = total_positives_online - true_positives;
% false_negatives = total_positives_DS - true_positives;
% 
% 
% precision = true_positives / (true_positives + false_positives);
% recall = true_positives / (true_positives + false_negatives);
% 
% f1_onDSf = 2 * (precision * recall) / (precision + recall);


%Delta durations
online_durations = onlinedetection(:,2) - onlinedetection(:,1);
offline_durations = offlinedetection_selection(:,2) - offlinedetection_selection(:,1);


%Inter Delta duration
interduration_online = zeros (size(onlinedetection,1),1);
interduration_offline = zeros (size(offlinedetection_selection,1)-1,1);

for i = 2 : size (onlinedetection(:,1))
    interduration_online (i) = onlinedetection(i,2) - onlinedetection(i-1,1);
end

for i = 2 : size (offlinedetection_selection(:,1))
    interduration_offline (i) = offlinedetection_selection(i,2) - offlinedetection_selection(i-1,1);
end  
    

%Auto Correlation 
[corr_online,lags_online] = CrossCorr(onlinedetection(:,1),onlinedetection(:,1),1,1000);
[corr_offline, lags_offline] = CrossCorr(offlinedetection_selection(:,1),offlinedetection_selection(:,1),1,1000);
[corr_DownStates, lags_DownStates] = CrossCorr(DownStates_selection(:,1),DownStates_selection(:,1),1,1000);

%Cross Correlation 
[hist_online_offline,lags_online_offline] = CrossCorr(offlinedetection_selection(:,1),onlinedetection(1:size(onlinedetection,1)),1,1000);
[hist_online_DownStates,lags_online_DownStates] = CrossCorr(DownStates_selection(:,1),onlinedetection(1:size(onlinedetection,1)),1,1000);


%% Add Night Results to mean matrix
f1_onoff_tot (L,:) = f1_onoff;
online_durations_tot  = [online_durations_tot ; online_durations];
offline_durations_tot = [offline_durations_tot ; offline_durations];
interduration_online_tot = [interduration_online_tot ; interduration_online];
interduration_offline_tot  = [interduration_offline_tot ; interduration_offline];
lags_online_tot (L,:) = lags_online;
corr_online_tot (L,:) = corr_online;
lags_offline_tot (L,:) = lags_offline;
corr_offline_tot (L,:) = corr_offline;
lags_online_offline_tot (L,:) = lags_online_offline;
hist_online_offline_tot (L,:) = hist_online_offline;
precision_tot (L) = mean(precision);
recall_tot (L) = mean(recall);

L = L+1;
%% Display Results

f = figure;
hold on; plot(Online_curve,'r'); plot(Offline_curve,'b'); ylim([-0.5 1.5]); xlabel('time (ms)'); title('Online and Offline Delta Detection Patterns');
legend('online detection','offline detection');
g = figure;
set(gcf,'Color',[1 1 1]);
plot(2.*[0:1:75],mean(f1_onoff,3),'k'); 
title('f1 = f(windowsize)')
legend({strcat('mean (f1)=',num2str(mean(mean(f1_onoff_tot,1))))},'Location','best','FontSize',14); xlabel('windowsize (ms)'); ylabel ('f1 Score');
ylim([0 1]);

h = figure; 
set(gcf,'Color',[1 1 1]);
plot(recall_tot,precision_tot,'Marker','*','LineStyle','none','MarkerSize',14);
title('Precision = f(Recall)')
legend({strcat('mean(Precision)=',num2str(mean(precision_tot)),'; mean(Recall)=',num2str(mean(recall_tot)))},'Location','best','FontSize',14); 
xlabel('Recall'); 
ylabel ('Precision');
xlim([0 1]);
ylim([0 1]);

i = figure;
set(gcf,'Color',[1 1 1]);
subplot(3,1,2)
str1 = strcat(num2str(size(online_durations,1)),' delta waves detected online');
str2 = strcat(num2str(size(offline_durations,1)),' delta waves detected offline');
hold on;
[N,edges] = histcounts(online_durations_tot,16,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'r');
[N,edges] = histcounts(offline_durations_tot,16,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'b');
xlabel('duration (ms)'); ylabel('Probability'); 
title('Duration of Delta Waves detected Online vs Offline');
legend({str1,str2},'Location','south','FontSize',12);


subplot(3,1,3)
hold on 
[N,edges] = histcounts(interduration_online_tot(interduration_online_tot<3000),300,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'r');
[N,edges] = histcounts(interduration_offline_tot(interduration_offline_tot<3000),300,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'b')
title('ISI Delta Online vs ISI Delta Offline (ms)'); xlabel('Duration (ms)'); ylabel('Probability'); 
legend({'Online','Offline'},'Location','south','FontSize',12);


subplot(3,1,1)
hold on ;
a=gca;
plot(mean(lags_online_offline_tot,1),mean(hist_online_offline_tot,1),'k');
title('crosscorrelation online/offline'); xlim([-10 10]);
plot([4 4], a.YLim,'b','LineStyle','--');
xlabel('time (ms)');
