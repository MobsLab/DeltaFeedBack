addpath(genpath('/home/mobsspectre/Dropbox/Kteam/PrgMatlab'));

PFCsup_Channel = 13;
PFCdeep_Channel = 14;
Gamma_Channel = 7;
ThetaDelta_Channel = 18;

load(strcat('LFP',num2str(PFCsup_Channel),'.mat'));
PFCsup = Data(LFP);
save('PFCsup.mat','PFCsup');

clear LFP
load(strcat('LFP',num2str(PFCdeep_Channel),'.mat'));
PFCdeep = Data(LFP);
save('PFCdeep.mat','PFCdeep');

clear LFP
load(strcat('LFP',num2str(Gamma_Channel),'.mat'));
Gamma = Data(LFP);
save('gamma.mat','Gamma');

clear LFP
load(strcat('LFP',num2str(ThetaDelta_Channel),'.mat'));
thetadelta = Data(LFP);
save('thetadelta.mat','thetadelta');