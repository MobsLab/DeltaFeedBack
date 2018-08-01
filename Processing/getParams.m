%% Getting params from the .csv file for post processing

[filename1,filepath1]=uigetfile({'*.*','All Files'},'Select Params File','/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/ParamsSouris');
file=strcat(filepath1,filename1);
paramsArray=readtable(file,'Delimiter',';','Format','%s%f');
mouse=struct;
mouse.PFCDeep=paramsArray{5,2};
mouse.PFCSup=paramsArray{4,2};
mouse.Bulb=paramsArray{1,2};
mouse.HPC=paramsArray{2,2};
mouse.Ref=paramsArray{8,2};
name1=strsplit(filename1,'.');
mouse.Number=name1{1};
