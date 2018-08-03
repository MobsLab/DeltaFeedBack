%%%%%%%%%%%%%%%%%%%%%%% COMPARE DELTA DETECTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%
%25/07/2018
%Adrien Bertolo 

clear all
clc
addpath(genpath('/home/mobsspectre/Dropbox/Kteam/PrgMatlab'));

%% initialization
f1_onoff_tot = [];
online_durations_tot  = [];
offline_durations_tot = [];
interduration_online_tot = [];
interduration_offline_tot  = [];
lags_online_tot = [];
corr_online_tot = [];
lags_offline_tot = [];
corr_offline_tot = [];
lags_online_offline_tot = [];
hist_online_offline_tot = [];
precision_tot = [];
recall_tot = [];
closest_inter_duration_tot = [];

%% Paths
run = 1;

while run == 1

mouse = uigetdir('/media/mobsspectre/Mobs/SleepScoring','Mouse Selection'); 
prompt = 'Which Detection Number do you want ? \n';
detection_number = num2str(input(prompt));
sleepstagepath = strcat(mouse,'/Processed/sleepstage.mat');
fires_actual_time_path = strcat(mouse,'/DeltaDetection/fires/fires_actual_time.mat'); 
detection_matrix_path = strcat(mouse,'/DeltaDetection/fires/detections_matrix.mat'); 
offlinepath = strcat(mouse,'/DeltaDetection/offlinedetection',detection_number,'.mat');


%% Load Detections
load(fires_actual_time_path);
Detection{1} = {fires_actual_time*1e-4}; clear fires_actual_time
load(detection_matrix_path); 
Detection{2} = {detections*1e-4}; clear detections;
Detection{3} = load(offlinepath);
%Detection{4} = load(onlinepath); 
load(sleepstagepath);

%% Detections Selection 

prompt = 'Select first Detection to compare \n 1:fires_actual \n 2:detection_matrix \n 3:offline \n 4:online simulation \n';
first = input(prompt);

if isstruct(Detection{1,first})
    Detection_1 = cell2mat(struct2cell(Detection{1,first}));
elseif iscell(Detection{1,first}) 
    Detection_1 = cell2mat(Detection{1,first});
else 
    Detection_1 = Detection{1,first};
end

prompt = 'Select second Detection to compare \n 1:fires_actual \n 2:detection_matrix \n 3:offline \n 4:online simulation \n';
second = input(prompt);

if isstruct(Detection{1,second})
    Detection_2 = cell2mat(struct2cell(Detection{1,second}));
elseif iscell(Detection{1,second})
    Detection_2 = cell2mat(Detection{1,second});
else 
    Detection_2 = Detection{1,second};
end

prompt = 'Compare [Start Stop] or just [Stop] (1/0) \n';
mode = input(prompt);


if mode == 0
    
    if size(Detection_1,2)==2
        Detection_1 = Detection_1(:,2);
    elseif size(Detection_1,2)== 11 || size(Detection_1,2)== 10 
        Detection_1 = Detection_1(:,1);
    end
    
    if size(Detection_2,2)==2
        Detection_2 = Detection_2(:,2);
    elseif size(Detection_2,2)== 11 || size(Detection_2,2)== 10 
        Detection_1 = Detection_1(:,1);
    end
    
elseif mode ==1 
    
    if size(Detection_1,2) == 11 || size(Detection_1,2)== 12
        Detection_1 = [Detection_1(:,2) Detection_1(:,1)];
    end
    
    if size(Detection_2,2) == 11 || size(Detection_1,2)== 12
        Detection_2 = [Detection_2(:,2) Detection_2(:,1)];
    end
    
end
%% Restrict a Detection to specific Sleep Stage 
prompt = 'Do you want to restrict a detection to a specific Sleep Stage ? (1/0) \n';
awnser = input(prompt);
if awnser == 1
    prompt = 'Which Detection (1/2) \n';
    num = input(prompt);
    
    prompt = 'On which Sleep State do you want to restrict the detection \n 1: NREM \n 2: REM \n 3: Wake \n';
    sleepstate = input(prompt);
    
    transition = diff([0 (allresult(:,8) == sleepstate)' 0]);
    startState = find(transition == 1);
    endState = find(transition == -1);
    endState(end) = endState(end)-1;
    bins = [allresult(startState(:),2)/20000 allresult(endState(:),2)/20000];
    
    if num == 1
        [status,interval,index] = InIntervals(Detection_1,bins);
        Detection_1 = Detection_1 (find(status==1),:);
    else
        [status,interval,index] = InIntervals(Detection_2,bins);
        Detection_2 = Detection_2 (find(status==1),:);
    end
end

%% Restrict Longer Detection 
t0 = 0;

if mode == 0 
    t1 = min(round(Detection_1(end)*1000,0),round(Detection_2(end)*1000,0));
    firstindex_1 = min(find(Detection_1*1000>t0)); %last index corresponding to online simulaiton duration
    lastindex_1 = max(find(Detection_1*1000<t1)); %last index corresponding to online simulaiton duration
    Detection_1 = (Detection_1(firstindex_1:lastindex_1) - t0)*1000;

    firstindex_2 = min(find(Detection_2*1000>t0)); %last index corresponding to online simulaiton duration
    lastindex_2 = max(find(Detection_2*1000<t1)); %last index corresponding to online simulaiton duration
    Detection_2 = (Detection_2(firstindex_2:lastindex_2) - t0)*1000;

elseif mode ==1
    t1 = min(round(Detection_1(end,2)*1000,0),round(Detection_2(end,2)*1000,0));
    firstindex_1 = min(find(Detection_1(:,1)*1000>t0)); %last index corresponding to online simulaiton duration
    lastindex_1 = max(find(Detection_1(:,2)*1000<t1)); %last index corresponding to online simulaiton duration
    Detection_1 = (Detection_1(firstindex_1:lastindex_1,:) - t0)*1000;

    firstindex_2 = min(find(Detection_2(:,1)*1000>t0)); %last index corresponding to online simulaiton duration
    lastindex_2 = max(find(Detection_2(:,2)*1000<t1)); %last index corresponding to online simulaiton duration
    Detection_2 = (Detection_2(firstindex_2:lastindex_2,:) - t0)*1000;

end

%% Detection Curves
Detection_1_curve = zeros (t1-t0,1);
Detection_2_curve = zeros (t1-t0,1);

if mode ==0 
    for i = 1 : size (Detection_1)
        Detection_1_curve (round(Detection_1(i))) = 1; %creating curve
    end

    for i = 1 : size (Detection_2)
        Detection_2_curve (round(Detection_2(i))) = 1; %creating curve
    end
elseif mode ==1
    for i = 1 : size (Detection_1,1)
    Detection_1_curve (round(Detection_1(i,1)) : round(Detection_1(i,2))) = 1; %creating curve
    end
    
    for i = 1 : size (Detection_2,1)
    Detection_2_curve (round(Detection_2(i,1)) : round(Detection_2(i,2))) = 1; %creating curve
    end
end

%% Stats
%f1_score online/offline
f1_onoff = zeros (61,1);
precision = zeros (61,1);
recall = zeros (61,1);
j=1;

for i = 0:5:300
    
    windowsize = i;
    
    if mode ==0
        larger_interval = [Detection_2 Detection_2+windowsize];
    elseif mode ==1
        larger_interval = [Detection_2(:,1)-windowsize Detection_2(:,2)+windowsize];
    end

    [status, ~, ~] = InIntervals(Detection_1, larger_interval);
    total_positives_offline = size(Detection_2,1);
    total_positives_online = size(Detection_1,1);

    true_positives = sum(status);

    false_positives = total_positives_online - true_positives;
    false_negatives = total_positives_offline - true_positives;


    precision(j) = true_positives / (true_positives + false_positives);
    recall(j) = true_positives / (true_positives + false_negatives);

    f1_onoff(j) = 2 * (precision(j) * recall(j)) / (precision(j) + recall(j));
    j = j+1;

end
f1_onoff(isnan(f1_onoff))=0;

%Inter Delta duration
interduration_online = zeros (size(Detection_1,1)-1,1);
interduration_offline = zeros (size(Detection_2,1)-1,1);

for i = 2 : size (Detection_1(:,1))
    if mode == 1
        interduration_online (i) = Detection_1(i,1) - Detection_1(i-1,2);
    else
        interduration_online (i) = Detection_1(i) - Detection_1(i-1);
    end
end

for i = 2 : size (Detection_2(:,1))
    if mode == 1
        interduration_offline (i) = Detection_2(i,1) - Detection_2(i-1,2);
    else
        interduration_offline (i) = Detection_2(i) - Detection_2(i-1);
    end
end 

%Closest intervals
closest_inter_duration = [];
for i = 1:size(Detection_2,1)
    a = Detection_2 (i);
    diff_inter = Detection_1 - a;
    diff_inter_pos = diff_inter(diff_inter>0);
    closest_inter_duration = [closest_inter_duration min(diff_inter_pos)];
    diff_inter_neg = diff_inter(diff_inter<0);
    closest_inter_duration = [closest_inter_duration max(diff_inter_neg)];
end

%Durations
if mode ==1
    online_durations = [(Detection_1(:,2)-Detection_1(:,1)) status];
    offline_durations = Detection_2(:,2)-Detection_2(:,1); 
end

%Auto Correlation
[corr_online,lags_online] = CrossCorr(Detection_1(:,1),Detection_1(:,1),1,1000);
[corr_offline, lags_offline] = CrossCorr(Detection_2(:,1),Detection_2(:,1),1,1000);

%Cross Correlation 
%[hist_online_offline,lags_online_offline] = CrossCorr(Detection_1,Detection_2,1,1000);
[hist_online_offline,lags_online_offline] = xcorr(Detection_1_curve,Detection_2_curve,1000);

%Number of Detections
num1 = size(Detection_1,1);
num2 = size(Detection_2,1);
ratio = num1/num2*100;


%% Display Results

f = figure;
hold on 
subplot(2,1,1)
plot(Detection_2_curve,'b')
ylim([-0.5 1.5]); xlabel('time (ms)');
subplot(2,1,2)
plot(Detection_1_curve,'r')
ylim([-0.5 1.5]); xlabel('time (ms)');

f2 = figure;
hold on 
plot(Detection_2_curve,'b'); 
plot(Detection_1_curve,'r')
ylim([-0.5 1.5]); xlabel('time (ms)');

g = figure;
subplot(3,1,1)
set(gcf,'Color',[1 1 1]);
plot(0:5:300,precision,'k'); 
title('precision = f(windowsize)')
legend({strcat('precision (60 ms)=',num2str(round(precision(31)),2))},'Location','best','FontSize',14); xlabel('windowsize (ms)'); ylabel ('precision');
ylim([0 1]);

subplot(3,1,2)
plot(0:5:300,recall,'k');
title('recall = f(windowsize)')
legend({strcat('recall (60 ms)=',num2str(round(recall(31)),2))},'Location','best','FontSize',14); xlabel('windowsize (ms)'); ylabel ('recall');
ylim([0 1]);

subplot(3,1,3)
plot(0:5:300,f1_onoff,'k'); 
title('f1 = f(windowsize)')
legend({strcat('f1 (60 ms)=',num2str(round(f1_onoff(31)),2))},'Location','best','FontSize',14); xlabel('windowsize (ms)'); ylabel ('f1 Score');
ylim([0 1]);

h = figure; 
set(gcf,'Color',[1 1 1]);
plot(mean(recall),mean(precision),'Marker','*','LineStyle','none','MarkerSize',14);
title('Precision = f(Recall)')
legend({strcat('mean(Precision)=',num2str(round(mean(precision),2)),'; mean(Recall)=',num2str(round(mean(recall),2)))},'Location','best','FontSize',14); 
xlabel('Recall'); 
ylabel ('Precision');
xlim([0 1]);
ylim([0 1]);

i = figure;
set(gcf,'Color',[1 1 1]);

subplot(2,2,1)
hold on ;
a=gca;
plot(lags_online,corr_online,'k');
title('Autocorelation Detection 1'); xlim([-300 300]);
%plot([4 4], a.YLim,'b','LineStyle','--');
xlabel('time (ms)');

subplot(2,2,2)
hold on ;
a=gca;
plot(lags_offline,corr_offline,'k');
title('Autocorrelation Detection 2'); xlim([-300 300]);
%plot([4 4], a.YLim,'b','LineStyle','--');
xlabel('time (ms)');

subplot(2,2,3)
hold on ;
a=gca;
plot(lags_online_offline,hist_online_offline/max(abs(hist_online_offline)),'k');
title('crosscorrelation online/offline'); xlim([-300 300]);
%plot([4 4], a.YLim,'b','LineStyle','--');
xlabel('time (ms)');

subplot(2,2,4)
hold on 
[N,edges] = histcounts(interduration_online(interduration_online<3000),300,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'r');
[N,edges] = histcounts(interduration_offline(interduration_offline<3000),300,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'b')
title('ISI Delta fire vs ISI Delta Offline (ms)'); xlabel('Duration (ms)'); ylabel('Probability'); 
legend({'Online','Offline'},'Location','south','FontSize',12);


j = figure; 
hold on 
[N,edges] = histcounts(closest_inter_duration,500000,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'r');
title('Closest interduration between Fire and Offline Intervals'); xlabel('Duration (ms)'); ylabel('Probability'); 
xlim([-1000 1000]);

%% Add Night Results to mean matrix
prompt = 'Add theese results to mean them with other nights afterwords ? (1/0) \n';
if input(prompt) == 1
    if mode == 1
        online_durations_tot = [online_durations_tot ; online_durations];
        offline_durations_tot = [offline_durations_tot ; offline_durations];
    end
    interduration_online_tot = [interduration_online_tot ; interduration_online];
    interduration_offline_tot  = [interduration_offline_tot ; interduration_offline];
    lags_online_tot = [lags_online_tot ; lags_online'];
    corr_online_tot = [corr_online_tot ; corr_online'];
    lags_offline_tot = [lags_offline_tot ; lags_offline'];
    corr_offline_tot = [corr_offline_tot ; corr_offline'];
    lags_online_offline_tot = [lags_online_offline_tot ; lags_online_offline];
    hist_online_offline_tot = [hist_online_offline_tot ; hist_online_offline'];
    precision_tot = [precision_tot ; precision'];
    recall_tot = [recall_tot ; recall'];
    f1_onoff_tot = [f1_onoff_tot ; f1_onoff'];
    closest_inter_duration_tot = [closest_inter_duration_tot closest_inter_duration];
end
close all

%% Continue or Stop 
prompt = 'Would you like to compare other detections ? (1/0) \n';
run = input(prompt);

end

%% Display Mean Results

g = figure;
subplot(3,1,1)
hold on 
set(gcf,'Color',[1 1 1]);
plot(0:5:300,mean(precision_tot,1),'k','LineWidth',1.2); 
title('precision = f(windowsize)','FontSize',13.5)
ylabel ('precision','FontSize',12.5);
ylim([0 1]);
ax=gca;
plot([30 30], ax.YLim,'k','LineStyle','--');
plot([60 60], ax.YLim,'k','LineStyle','--');


subplot(3,1,2)
hold on 
plot(0:5:300,mean(recall_tot,1),'k','LineWidth',1.2);
title('recall = f(windowsize)','FontSize',13.5)
ylabel ('recall','FontSize',12.5);
ylim([0 1]);
ax=gca;
plot([30 30], ax.YLim,'k','LineStyle','--');
plot([60 60], ax.YLim,'k','LineStyle','--');


subplot(3,1,3)
hold on 
plot(0:5:300,mean(f1_onoff_tot,1),'k','LineWidth',1.2); 
title('f1 = f(windowsize)','FontSize',13.5)
xlabel('windowsize (ms)','FontSize',12.5); ylabel ('f1 Score','FontSize',12.5);
ylim([0 1]);
ax=gca;
plot([30 30], ax.YLim,'k','LineStyle','--');
plot([60 60], ax.YLim,'k','LineStyle','--');


h = figure; 
set(gcf,'Color',[1 1 1]);
plot(recall_tot(:,31),precision_tot(:,31),'Marker','*','LineStyle','none','MarkerSize',14);
xlim([0 1]);
ylim([0 1]);
title('Precision = f(Recall) for WindowSize = 60 ms','FontSize',13.5)
legend({strcat('Precision(60 ms)=',num2str(round(mean(precision_tot(:,31)),2)),'; Recall(60ms)=',num2str(round(mean(recall_tot(:,31)),2)))},'Location','best','FontSize',14); 
xlabel('Recall','FontSize',12.5); 
ylabel ('Precision','FontSize',12.5);



i = figure;
set(gcf,'Color',[1 1 1]);

subplot(1,2,1)
hold on ;
a=gca;
plot(mean(lags_online_offline_tot,1),mean(hist_online_offline_tot,1)/max(mean(hist_online_offline_tot,1)),'k');
title('Mean CrossCorrelation','FontSize',13.5); xlim([-200 200]);
xlabel('time (ms)','FontSize',12.5);

subplot(1,2,2)
hold on 
[N,edges] = histcounts(interduration_online_tot(interduration_online_tot<3000),300,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'r');
[N,edges] = histcounts(interduration_offline_tot(interduration_offline_tot<3000),300,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'b')
title('Delta Interduration Distributions','FontSize',13.5); xlabel('Duration (ms)','FontSize',12.5); ylabel('Probability','FontSize',12.5); 
legend({'Online','Offline'},'Location','south','FontSize',12','Box','off');


j = figure; 
hold on 
[N,edges] = histcounts(closest_inter_duration_tot,500000,'Normalization','Probability');
plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'r');
title('Closest interduration between Fire and Offline Intervals'); xlabel('Duration (ms)'); ylabel('Probability'); 
xlim([-200 200]);

if mode == 1 
    online_durations_tot_TP = online_durations_tot(online_durations_tot(:,2) ==1);
    online_durations_tot_FP = online_durations_tot(online_durations_tot(:,2) == 0);
    
    k = figure;
    set(gcf,'Color',[1 1 1]);
    str0 = strcat(num2str(size(online_durations_tot,1)),' good delta waves detected online');
    str1 = strcat(num2str(size(online_durations_tot_TP,1)),' good delta waves detected online');
    str2 = strcat(num2str(size(online_durations_tot_FP,1)),' bad delta waves detected online');
    str3 = strcat(num2str(size(offline_durations_tot,1)),'delta waves detected offline');
    hold on;
    [N,edges] = histcounts(online_durations_tot(:,1),15);
    plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'r','LineWidth',1.3);
    [N,edges] = histcounts(online_durations_tot_TP,15);
    plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'g','LineStyle','--');
    [N,edges] = histcounts(online_durations_tot_FP,15);
    plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'r','LineStyle','--');
    [N,edges] = histcounts(offline_durations_tot,15);
    plot((edges(2:end)+edges(1:end-1))/2,smooth(N),'b','LineWidth',1.3);
    xlabel('duration (ms)','FontSize',12.5); ylabel('Occurencies','FontSize',12.5); 
    title('Durations of Good and Bad Delta Waves detected Online vs Offline','FontSize',13.5);
    legend({str0,str1,str2,str3},'Location','south','FontSize',12','Box','off');
end

