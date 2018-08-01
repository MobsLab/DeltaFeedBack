function updatedBins=mergeCloseBins(bins,duration)
updatedBins= [bins(1,1) bins(1,2)];
for i=1:size(bins,1)
    if (bins(i,2)-updatedBins(end,2))<=duration
        updatedBins=[updatedBins(1:(end-1),:); updatedBins(end,1) bins(i,2)];
    else
        updatedBins=[updatedBins; bins(i,1) bins(i,2)];
    end
end
end