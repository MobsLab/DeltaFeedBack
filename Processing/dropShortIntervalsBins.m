function updatedBins=dropShortIntervalsBins(bins,duration)
updatedBins=[];
for i=1:size(bins,1)
    if (bins(i,2)-bins(i,1))>=duration
        updatedBins=[updatedBins; bins(i,1) bins(i,2)];
    end
end
end