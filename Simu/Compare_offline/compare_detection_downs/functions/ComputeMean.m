function mean_signal = ComputeMean (signal2mean,IndexArray,DetectionMatrix)

mean_signal = signal2mean(IndexArray)';
mean_signal = reshape(mean_signal, [200,size(DetectionMatrix,1)])';
mean_signal = mean(mean_signal,1);
