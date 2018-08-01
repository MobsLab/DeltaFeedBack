close all
figure;
%%%Load Online scoring results
load('sleepstage.mat');
%%%Load Offline scoring results
load('SleepScoring_OBGamma.mat');
allresult(:,2)=ceil(allresult(:,2)/20000);

%Time comparison
%% Create offline Hypnogram
TotRecordingTimeOffline=round(tot_length(union(REMEpoch,SWSEpoch,Wake))/10^4);

offlineHypnogram=zeros(TotRecordingTimeOffline,1);
wakeTimes=[floor(Start(Wake)/10^4) ceil(End(Wake)/10^4)]+1;
for i=1:size(wakeTimes,1)
    offlineHypnogram(wakeTimes(i,1):wakeTimes(i,2))=3;
end
REMTimes=[floor(Start(REMEpoch)/10^4) ceil(End(REMEpoch)/10^4)]+1;
for i=1:size(REMTimes,1)
    offlineHypnogram(REMTimes(i,1):REMTimes(i,2))=2;
end
SWSTimes=[floor(Start(SWSEpoch)/10^4) ceil(End(SWSEpoch)/10^4)]+1;
for i=1:size(SWSTimes,1)
    offlineHypnogram(SWSTimes(i,1):SWSTimes(i,2))=1;
end
TPR=[];
FPR=[];
for ratioGamma=-3:0.05:0
    for ratio=0:0.05:1
        allresult(find(log10(allresult(:,3))<ratioGamma & log10(allresult(:,6))<ratio),8)=1;
        allresult(find(log10(allresult(:,3))<ratioGamma & log10(allresult(:,6))>ratio),8)=2;
        [C,ia,ic]=unique(allresult(:,2));
        onlineHypnogram=interp1(allresult(ia,2),allresult(ia,8),1:length(offlineHypnogram),'next');
        positives=sum(offlineHypnogram==2);
        negatives=sum(offlineHypnogram~=2);
        truePositives=sum(onlineHypnogram'==2 & offlineHypnogram==2);
        falsePositives=sum(onlineHypnogram'==2 & offlineHypnogram~=2);
        TPR=[TPR truePositives/positives];
        FPR=[FPR falsePositives/negatives];
    end
end
TPRplot=[];
FPRplot=[];
for i=1:length(TPR)
    if(ismember([FPR(i)],FPRplot))
        if TPRplot(find(FPRplot==FPR(i)))>TPR(i)
            TPRplot(find(FPRplot==FPR(i)))=TPR(i);
        end
    else
        FPRplot=[FPRplot, FPR(i)];
        TPRplot=[TPRplot, TPR(i)];
    end
        
end
TPRplot1=[];
FPRplot1=[];
for i=1:length(TPRplot)
    if(ismember([TPRplot(i)],TPRplot1))
        if FPRplot1(find(TPRplot1==TPRplot(i)))<FPRplot(i)
            FPRplot1(find(TPRplot1==TPRplot(i)))=FPRplot(i);
        end
    else
        FPRplot1=[FPRplot1, FPRplot(i)];
        TPRplot1=[TPRplot1, TPRplot(i)];
    end
        
end
[FPRplot1,idx1]= sort(FPRplot1);
TPRplot1=TPRplot1(idx1);
X=[FPRplot1(1)];
Y=[TPRplot1(1)];
for i=2:length(TPRplot1)
    if TPRplot1(i)>TPRplot1(i-1)
        X=[X FPRplot1(i)]
        Y=[Y TPRplot1(i)]
    end
end
plot(X,Y,'LineStyle','-','Marker','*','MarkerSize',8);
hold on
plot(0:0.00001:1,0:0.00001:1)
title(strcat('ROC REMvsAll: AUC=',num2str(trapz(X,Y))));
xlabel('FPR');
ylabel('TPR');
set(gca,'FontSize',28);
