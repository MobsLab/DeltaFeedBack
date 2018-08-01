figure;
hold on
results=readResultsTable('PostProcessing/results.csv');
plot(results{:,'CohenKappa'},results{:,'BalancedAccuracy'},'Marker','+','LineStyle','none');
xlim([0 1]);
ylim([0 1]);
xlabel("Cohen's Kappa");
ylabel('Balanced accuracy');
figure;
globalConfMatrix=zeros(3);
for i=1:length(results{:,'ConfMat'})
    globalConfMatrix=globalConfMatrix+eval(char(results{i,'ConfMat'}));
end

globalConfMatrix=globalConfMatrix./sum(globalConfMatrix,2);
h=heatmap({ strcat('Wake'), strcat('REM'),strcat('NREM')},{strcat('Wake'), strcat('REM'), strcat('NREM')},globalConfMatrix);
h.XLabel=strcat('Online');
h.YLabel=strcat('Offline');
h.Title=strcat('Confusion matrix, #Nights=',num2str(length(results{:,'ConfMat'})));
h.ColorbarVisible='off';
balancedAccuracy=sum(diag(globalConfMatrix))/3;
saveas(gcf,'PostProcessing/confMat.png');