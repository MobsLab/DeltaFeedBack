function features=extractFeatures(X,unitID,name)
Xmean=returnMeanActivity(X,1:size(X,1));
%Xmean=X;
Xmean(isnan(Xmean))=0;
freqMed=(medfreq(Xmean'))';
freqMed(isnan(freqMed))=0;
[valueMax,indexMax]=max(Xmean,[],2);
skewX=skewness(Xmean')';
skewX(isnan(skewX))=0;
kurtX=kurtosis(Xmean')';
kurtX(isnan(kurtX))=0;
fftX=fft(Xmean);
fftX=abs(fftX);
fftX=fftX(1:length(fftX)/2+1);
[maxKfreq,freqMax]=maxk(fftX,5);
features=[sum(Xmean,2);rms(Xmean);mean(Xmean); (std(Xmean'))'; freqMed;maxKfreq(:);freqMax(:);rms(fftX);valueMax;indexMax;skewX;kurtX];