%% updateResults
% results is an allresults file from the online sleep scoring interface
% returns a new sleep scoring according to the thresholds supplied
function updatedResults=updateResults(results, gammaThresh, thetaDeltaThresh)
    updatedResults=results;
    results=results(:,8);
    results(find(updatedResults(:,3)>10^gammaThresh))=3;%Wake
    results(find(updatedResults(:,3)<10^gammaThresh & updatedResults(:,6)>10^thetaDeltaThresh))=2;%REM
    results(find(updatedResults(:,3)<10^gammaThresh & updatedResults(:,6)<10^thetaDeltaThresh))=1;%NREM
    updatedResults(:,8)=results;
end