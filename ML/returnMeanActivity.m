function meanActivity=returnMeanActivity(activity,unitID)
meanActivity=mean(activity(unitID,:));
if(length(meanActivity)==1)
    meanActivity=zeros(1,size(activity,2));
end
end