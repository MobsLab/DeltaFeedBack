%% This codes compares the output from offline processing to the hypnogram recorded on the intan DigitalOut file
%% Adds the results to the results.csv file 

% See SleepScoringOBGamma
clear all
close all
%% Load Online hypnogram
fileinfo = dir('digitalout.dat');
num_samples = fileinfo.bytes/2; % uint16 = 2 bytes
fid = fopen('digitalout.dat', 'r');
hypnogramOnline = fread(fid, num_samples, 'uint16')/256;
hypnogramOnline=hypnogramOnline(1:20000:end);
fclose(fid);
hypnogramOnline(hypnogramOnline==4)=3;

load('sleepstage.mat');
allresult(:,2)=ceil(allresult(:,2)/20000);

%% Construct sleep intervals bins

transitionREMOnline=diff([0 (hypnogramOnline==2)' 0]);
startREMOnline=find(transitionREMOnline==1);
endREMOnline=find(transitionREMOnline==-1);
binsREMOnline=[startREMOnline(:) endREMOnline(:)];

transitionNREMOnline=diff([0 (hypnogramOnline==1)' 0]);
startNREMOnline=find(transitionNREMOnline==1);
endNREMOnline=find(transitionNREMOnline==-1);
binsNREMOnline=[startNREMOnline(:) endNREMOnline(:)];

transitionWAKEOnline=diff([0 (hypnogramOnline==1)' 0]);
startWAKEOnline=find(transitionWAKEOnline==1);
endWAKEOnline=find(transitionWAKEOnline==-1);
binsWAKEOnline=[startWAKEOnline(:) endWAKEOnline(:)];

%% Load Offline Data
load('SleepScoring_OBGamma.mat');
%% Construct offline Hypnogram
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

%% Evaluate classifier performance
lengthHypnogram=min(length(offlineHypnogram),length(hypnogramOnline));
Kappa = mKAPPA([offlineHypnogram(1:lengthHypnogram), hypnogramOnline(1:lengthHypnogram)],[0, 1, 2, 3],'quadratic');
cp=classperf(offlineHypnogram(1:lengthHypnogram), hypnogramOnline(1:lengthHypnogram));
accuracy=cp.CorrectRate*100
sensitivity=cp.Sensitivity*100
specificity=cp.Specificity*100
PPV=cp.PositivePredictiveValue*100
NPV=cp.NegativePredictiveValue*100

recallP = sensitivity;
recallN = specificity;
precisionP = PPV;
precisionN = NPV;
f1P = 2*((precisionP*recallP)/(precisionP + recallP));
f1N = 2*((precisionN*recallN)/(precisionN + recallN));
fscore = ((f1P+f1N)/2);

%% Confusion Matrix
wakeOffline=length(offlineHypnogram(offlineHypnogram==3));
REMOffline=length(offlineHypnogram(offlineHypnogram==2));
NREMOffline=length(offlineHypnogram(offlineHypnogram==1));

wakeOnline=length(hypnogramOnline(hypnogramOnline==3));
REMOnline=length(hypnogramOnline(hypnogramOnline==2));
NREMOnline=length(hypnogramOnline(hypnogramOnline==1));

confMatrix=flipud([sum(offlineHypnogram(1:lengthHypnogram)==3 & hypnogramOnline(1:lengthHypnogram)==1) sum(offlineHypnogram(1:lengthHypnogram)==3 & hypnogramOnline(1:lengthHypnogram)==2) sum(offlineHypnogram(1:lengthHypnogram)==3 & hypnogramOnline(1:lengthHypnogram)==3);
   sum(offlineHypnogram(1:lengthHypnogram)==2 & hypnogramOnline(1:lengthHypnogram)==1) sum(offlineHypnogram(1:lengthHypnogram)==2 & hypnogramOnline(1:lengthHypnogram)==2) sum(offlineHypnogram(1:lengthHypnogram)==2 & hypnogramOnline(1:lengthHypnogram)==3);
   sum(offlineHypnogram(1:lengthHypnogram)==1 & hypnogramOnline(1:lengthHypnogram)==1) sum(offlineHypnogram(1:lengthHypnogram)==1 & hypnogramOnline(1:lengthHypnogram)==2) sum(offlineHypnogram(1:lengthHypnogram)==1 & hypnogramOnline(1:lengthHypnogram)==3)]);
probConfMatrix=confMatrix./sum(confMatrix,2);
totTimeOffline=sum(confMatrix,1);
totTimeOnline=sum(confMatrix,2);
figure;
h=heatmap({ strcat('Wake'), strcat('REM'),strcat('NREM')},{strcat('Wake'), strcat('REM'), strcat('NREM')},confMatrix);
h.XLabel=strcat('Online');
h.YLabel=strcat('Offline');
h.Title=strcat('Confusion matrix, Kappa=',num2str(Kappa));
h.ColorbarVisible='off';
figure;
h=heatmap({ strcat('Wake'), strcat('REM'),strcat('NREM')},{strcat('Wake'), strcat('REM'), strcat('NREM')},probConfMatrix);
h.XLabel=strcat('Online');
h.YLabel=strcat('Offline');
h.Title=strcat('Confusion matrix, Kappa=',num2str(Kappa));
h.ColorbarVisible='off';
balancedAccuracy=sum(diag(probConfMatrix))/3;
saveas(gcf,'confMat.png');

%% Generates Results file
resultsTable=readResultsTable('../../PostProcessing/results.csv');
pwDir=strsplit(pwd,filesep);
newResults={pwDir(end-1),Kappa,balancedAccuracy,accuracy,precisionP,sensitivity,specificity,mat2str(confMatrix)};

if (~(ismember(pwDir(end-1),resultsTable{:,{'Date'}})))
    resultsTableUpdated=[resultsTable; newResults];
    writetable(resultsTableUpdated,'../../PostProcessing/results.csv');
end

%% Generate Points file
cd ../..
resultMat=strcat(pwDir(end-1),'.mat');
if (exist(resultMat{:})~=2)
    resultsUpdated=cat(2,allresult(:,3:5),offlineHypnogram(allresult(:,2)));
    save(strcat('PostProcessing/models/',resultMat{:}),'resultsUpdated');
end

%% Update Model
X=allresult(:,3:5);
Y=offlineHypnogram(allresult(:,2));
try
load('PostProcessing/Models/KNN-model.mat');
catch
    print('No existing KNN model');
end
if length(KNN.Y)>4E5
    idx=randperm(length(Y));
    idxTrain=idx(1:(length(KNN.Y)-length(Y)));
    idxTest=idx((length(KNN.Y)-length(Y)+1):end);
    X=[KNN.X(idxTrain,:) X];
    Y=[KNN.Y(idxTrain) Y];
    KNN2 = fitcknn(X,Y,'Distance','seuclidean','NumNeighbors',18);
    if compareHoldout(KNN,KNN2,X(idxTest,:),X(idxTest,:),Y(idxTest))
        KNN=KNN2;
        save('PostProcessing/Models/KNN-model.mat','KNN');
    end
else
    X=[KNN.X; X];
    Y=[KNN.Y; Y];
    KNN2 = fitcknn(X,Y,'Distance','seuclidean','NumNeighbors',18);
    KNN=KNN2;
    save('PostProcessing/Models/KNN-model.mat','KNN');
end
    
