% CreateDatasetTonesInUpEffect
% 05.06.2018 KJ
%
% Create a dataset for predicting the effect of a tone in up state
% It contains:
%   - MUA signals from PFCx
%   - effect of a town (down or no down - 0,1)
%
% SEE
%   CreateDatasetRythmDosed1 DatasetSubstageFromSUA
%
%


clear

%params
Dir=PathForExperimentsDeltaSleepSpikes('RdmTone');


%% LOOP
for p=1:length(Dir.path)
    disp(' ')
    disp('****************************************************************')
    cd(Dir.path{p})
    disp(pwd)

    clearvars -except Dir p data_cstu
    
    data_cstu.path{p} = Dir.path{p};
    data_cstu.name{p} = Dir.name{p};
    data_cstu.date{p} = Dir.date{p};

    
    %% params
    binsize_mua = 2;
    range_up = [0 200]*10;  % [0-150ms] after tone in Up
    sample_duration = 4e4; %4sec

    
    %% load
    %MUA
    MUA = GetMuaNeurons_KJ('PFCx', 'binsize',binsize_mua);
    
    %Down
    load('DownState.mat', 'down_PFCx')
    st_down = Start(down_PFCx);
    end_down = End(down_PFCx);
    %Up
    up_PFCx = intervalSet(end_down(1:end-1), st_down(2:end));
    
    %NREM
    load('SleepScoring_OBGamma.mat', 'SWSEpoch')
    
    %LFP
    load('ChannelsToAnalyse/PFCx_deep.mat')
    load(['LFPData/LFP' num2str(channel)], 'LFP')
    PFCdeep = LFP; clear LFP
    load('ChannelsToAnalyse/PFCx_sup.mat')
    load(['LFPData/LFP' num2str(channel)], 'LFP')
    PFCsup = LFP; clear LFP
    
    
    %% Tones 
    
    %load
    load('DeltaSleepEvent.mat', 'TONEtime2')
    tones_tmp = TONEtime2 + Dir.delay{p}*1E4;
    
    %restrict to REM and Up
    ToneEvent   = Restrict(ts(tones_tmp), SWSEpoch);
    ToneUp      = Restrict(ToneEvent, up_PFCx);
    tonesup_tmp = Range(ToneUp);
    
    %intervals before tones
    for i=1:length(tonesup_tmp)
        samples_intervals{i,1} = intervalSet(tonesup_tmp(i) - sample_duration, tonesup_tmp(i));
    end
    
    %Effect: induce down ?
    samples_class = zeros(length(samples_intervals),1);
    IntvToneUp  = intervalSet(tonesup_tmp+range_up(1),tonesup_tmp+range_up(2)); 
    
    intv = [Start(IntvToneUp) End(IntvToneUp)];
    [~,intervals,~] = InIntervals(st_down, intv);
    intervals(intervals==0)=[];
    intervals = unique(intervals);
    samples_class(intervals) = 1;

    %% X and Y   
    Y = [];
    X = cell(0);
    for i=1:length(samples_intervals)
        intv = samples_intervals{i};
        
        X1{i} = Data(Resample(Restrict(MUA,intv),200))';
        X2{i} = [Data(Resample(Restrict(PFCdeep,intv)),200)' ; Data(Resample(Restrict(PFCsup,intv),200))'] ; 
        Y(i) =  samples_class(i);
    end

    %concatenate
    data_cstu.X1{p} = X1;
    data_cstu.X2{p} = X2;
    data_cstu.Y{p} = Y;
 
end

%saving data
cd('C:\Users\MOBS\Desktop\Datasets')
save CreateDatasetTonesInUpEffect.mat -v7.3 data_cstu Dir binsize_mua range_up sample_duration











