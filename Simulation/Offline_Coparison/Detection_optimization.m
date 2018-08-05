function [deep_prefactor,sup_prefactor,delta_treshold] = Detection_optimization (fs,PFCsup_LFP,PFCdeep_LFP,Epoch,TotalNoiseEpoch,SWSEpoch)


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

end