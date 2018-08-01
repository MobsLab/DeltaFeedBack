mkdir Processed
mkdir DeltaDetection/fires
amp=strcat('amplifier_',convertCharsToStrings(mouse.Number),'.dat');
movefile('detections_matrix.mat','DeltaDetection/fires');
movefile('digin_matrix.mat','DeltaDetection/fires');
movefile('fires_actual_time.mat','DeltaDetection/fires');
movefile('fires_matrix.mat','DeltaDetection/fires');
movefile('digitalin.dat','Processed');
movefile('digitalout.dat','Processed');
movefile('sleepstage.mat','Processed');
movefile('analogin.dat','Processed');
movefile(char(amp),'Processed');
parDir=strsplit(pwd,filesep);
copyfile(char(fullfile(filesep,parDir(1),parDir(2),parDir(3),parDir(4),parDir(5),parDir(6),'PostProcessing',char(strcat('amplifier_',convertCharsToStrings(mouse.Number),'.xml')))),'Processed');

