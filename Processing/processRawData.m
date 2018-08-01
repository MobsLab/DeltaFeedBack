%% Automated post processing for online sleep scoring 
clear all
clc

%% generate LFPData and ChannelsToAnnalyse Folders needed for SleepScoringOBGamma
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/Code/Processing'));
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/MOBS_Code/PrgMatlab'));
getParams
RefSubtraction_multi('amplifier.dat',32,1,mouse.Number,[0:31],mouse.Ref,[]);
moveFiles
cd Processed
%% Launch ndm_lfp
system(strcat('ndm_lfp', ' amplifier_',convertCharsToStrings(mouse.Number),'.xml'));
%% create LFPData and ChannelsToAnalyse
mkdir LFPData
mkdir ChannelsToAnalyse
SetCurrentSession();
     
channels=[mouse.PFCSup mouse.PFCDeep mouse.Bulb mouse.HPC];

LFP=GetLFP(channels(1));
LFP = tsd(LFP(:,1)*1E4, LFP(:,2)); 
channel=channels(1);
save(strcat('LFPData/LFP',num2str(channels(1)),'.mat'),'LFP')
clear LFP channel

LFP=GetLFP(channels(2));
LFP = tsd(LFP(:,1)*1E4, LFP(:,2));
channel=channels(2);
save(strcat('LFPData/LFP',num2str(channels(2)),'.mat'),'LFP')
clear LFP channel

LFP=GetLFP(channels(3));
LFP = tsd(LFP(:,1)*1E4, LFP(:,2));
channel=channels(3);
save(strcat('LFPData/LFP',num2str(channels(3)),'.mat'),'LFP')
clear LFP channel

LFP=GetLFP(channels(4));
LFP = tsd(LFP(:,1)*1E4, LFP(:,2));
channel=channels(4);
save(strcat('LFPData/LFP',num2str(channels(4)),'.mat'),'LFP')
clear LFP channel

PFCsup=GetLFP(channels(1));
PFCsup = tsd(PFCsup(:,1)*1E4, PFCsup(:,2));
channel=channels(1);
save('ChannelsToAnalyse/PFCsup.mat','PFCsup','channel')
clear LFP channel

PFCdeep=GetLFP(channels(2));
PFCdeep = tsd(PFCdeep(:,1)*1E4, PFCdeep(:,2));
channel=channels(2);
save('ChannelsToAnalyse/PFCdeep.mat','PFCdeep','channel')
clear LFP channel

Bulb_deep=GetLFP(channels(3));
Bulb_deep = tsd(Bulb_deep(:,1)*1E4, Bulb_deep(:,2));
channel=channels(3);
save('ChannelsToAnalyse/Bulb_deep.mat','Bulb_deep','channel')
clear LFP channel

dHPC_deep=GetLFP(channels(4));
dHPC_deep = tsd(dHPC_deep(:,1)*1E4, dHPC_deep(:,2));
channel=channels(4);
save('ChannelsToAnalyse/dHPC_deep.mat','dHPC_deep','channel')
clear LFP channel

%% Launch SleepScoringOBGamma
SleepScoringOBGamma()
CompareHypnograms