%% Code used for generating graphs to compare results on multiple nights
folders=ls;
dirParent=pwd;
folders=strsplit(folders(1:end-1), ' ');
globalConfMatrix=zeros(3);
close all
figure;
subplot(2,1,1);
hold on
for i=1:length(folders)
    results=readResultsTable(fullfile(dirParent,folders{i},'/PostProcessing/results.csv'));
    subplot(2,2,1);
    hold on
    plot(results{:,'Kappa'},results{:,'balancedAccuracy'},'Marker','+','LineStyle','none','LineWidth',4);
    subplot(2,2,2);
    hold on
    plot(results{:,'sensitivity'}/100,results{:,'precisionP'}/100,'Marker','+','LineStyle','none','LineWidth',4);
    for j=1:length(results{:,'ConfMat'})
        globalConfMatrix=globalConfMatrix+eval(char(results{j,'ConfMat'}));
    end
end
subplot(2,2,1);
legend(folders,'Location','southeast');
xlim([0 1]);
ylim([0 1]);
xlabel("Cohen's Kappa");
ylabel('Balanced accuracy');
title('Balanced accuracy vs Kappa')
set(gca,'FontSize',20);
subplot(2,2,2);
legend(folders,'Location','southeast');
xlim([0 1]);
ylim([0 1]);
xlabel("Recall");
ylabel('Precision');
title('Precision vs Recall');
set(gca,'FontSize',20);
subplot(2,2,3)
globalConfMatrix=globalConfMatrix./sum(globalConfMatrix,2);
h=heatmap({ strcat('NREM'), strcat('REM'),strcat('Wake')},{strcat('NREM'), strcat('REM'), strcat('Wake')},globalConfMatrix);
h.XLabel=strcat('Online');
h.YLabel=strcat('Offline');
h.Title='Confusion matrix';
h.CellLabelFormat = '%.2f'
set(gca,'FontSize',20);
h.ColorbarVisible='off';
balancedAccuracy=sum(diag(globalConfMatrix))/3;

