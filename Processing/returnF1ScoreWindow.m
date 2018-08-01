%% Returns F1 score for windows in range (start,step, stop)
% binsTruth and binsTest are time intervals tables
function f1=returnF1ScoreWindow(binsTruth,binsTest,start,stop,step)
f1=[];
for i = start:step:stop
    
windowsize = i;

larger_interval = [binsTruth(:,1)-windowsize binsTruth(:,2)+windowsize];

[status, intervals_index, ~] = InIntervals(binsTest,larger_interval);

total_positives_offline = sum(binsTruth(:,2)-binsTruth(:,1));
total_positives_online = sum(binsTest(:,2)-binsTest(:,1));
true_positives = sum(status .* (binsTest(:,2) - binsTest(:,1)));
false_positives = total_positives_online - true_positives;
false_negatives = total_positives_offline - true_positives;


precision = true_positives/(true_positives + false_positives);
recall = true_positives/(true_positives + false_negatives);

f1 = [f1 2*(precision * recall)/(precision + recall)];
end