clear all
load('C:\Users\MOBS\Dropbox\DataKJ\Mobs\Delta_Data\Datasets\DatasetSubstageFromSUA2.mat')

test_train = 'random';


%% 
if strcmpi(test_train,'random')
    X = [];
    Y = [];
    for p=1:length(data_csfs.X)
        Xtemp=data_csfs.X{p};
        Ytemp=data_csfs.Y{p};
        UnitIDtemp=data_csfs.unitID{p};
        Nametemp=data_csfs.name{p};
        X_down=[];
        Y_down=[];
        Xmean=Xtemp{1};
        for i=1:length(Xtemp)
            Xmean=Xmean+Xtemp{i};
        end
        Xmean=mean(Xmean,2);
        [max,i_plus]=maxk(Xmean(UnitIDtemp(:,1)>0),length(Xmean(UnitIDtemp(:,1)>0)));
        [max,i_minus]=maxk(Xmean(UnitIDtemp(:,1)<0),length(Xmean(UnitIDtemp(:,1)<0)));
        for i=1:length(Xtemp)
            X=[X; extractFeatures(Xtemp{i}(i_plus(1:4:length(i_plus)),:),UnitIDtemp(i_plus(1:4:length(i_plus)),:),Nametemp)' extractFeatures(Xtemp{i}(i_plus(2:4:length(i_plus)),:),UnitIDtemp(i_plus(2:4:length(i_plus)),:),Nametemp)' extractFeatures(Xtemp{i}(i_plus(3:4:length(i_plus)),:),UnitIDtemp(i_plus(3:4:length(i_plus)),:),Nametemp)' extractFeatures(Xtemp{i}(i_plus(4:4:length(i_plus)),:),UnitIDtemp(i_plus(4:4:length(i_plus)),:),Nametemp)' extractFeatures(Xtemp{i}(i_minus(1:4:length(i_minus)),:),UnitIDtemp(i_minus(1:4:length(i_minus)),:),Nametemp)' extractFeatures(Xtemp{i}(i_minus(2:4:length(i_minus)),:),UnitIDtemp(i_minus(2:4:length(i_minus)),:),Nametemp)' extractFeatures(Xtemp{i}(i_minus(3:4:length(i_minus)),:),UnitIDtemp(i_minus(3:4:length(i_minus)),:),Nametemp)' extractFeatures(Xtemp{i}(i_minus(4:4:length(i_minus)),:),UnitIDtemp(i_minus(4:4:length(i_minus)),:),Nametemp)' str2double(Nametemp) size(Xtemp{i},1)];
            Y=[Y; Ytemp(i)];
        end
    end

elseif strcmpi(test_train,'mouse')
    X_train = cell(0);
    Y_train = [];
    for p=1
        X_train = [X_train data_cstu.X2{p}];
        Y_train = [Y_train data_cstu.Y{p}];
    end
    
    X_test = cell(0);
    Y_test = [];
    for p=2
        X_test = [X_test data_cstu.X2{p}];
        Y_test = [Y_test data_cstu.Y{p}];
    end
    
    Y_train = categorical(Y_train');
    Y_test = categorical(Y_test');
    
end
X_feature={};
for i=1:44000
    freqMed=(medfreq(X{i}'))';
    freqMed(isnan(freqMed))=0;
    [valueMax,indexMax]=max(X{i},[],2);
    skewX=skewness(X{i}')';
    skewX(isnan(skewX))=0;
    kurtX=kurtosis(X{i}')';
    kurtX(isnan(kurtX))=0;
    X_feature={X_feature{:} [sum(X{i},2);mean(X{i},2); (std(X{i}'))'; freqMed;valueMax;skewX;kurtX;]};
end
X_feature_trans=[]
for i=1:length(X_feature)
    X_feature_trans=[X_feature_trans; X_feature{i}'];
end
Y=uint8(Y);
Y1=Y;
Y1(Y==3 | Y==2)=1;
idx=randperm(size(X_feature_trans,1));
idxTest=idx(1:length(idx)*0.2);
idxTrain=idx((length(idx)*0.2+1):end);
Mdl = TreeBagger(250,X_feature_trans(idxTrain,:),Y1(idxTrain));
labels = predict(Mdl,X_feature_trans(idxTest,:));
labelsTest = predict(Mdl,X_feature_trans(idxTest,:));

Ynrem=Y(idxTrain);
Xnrem=X_feature_trans(idxTrain,:);
Xnrem=Xnrem(Ynrem==1|Ynrem==2|Ynrem==3,:);
Ynrem=Ynrem(Ynrem==1|Ynrem==2|Ynrem==3);
Mdl1 = TreeBagger(250,Xnrem,Ynrem);

Xtest=X_feature_trans(idxTest,:);
Ypred=str2num(cell2mat(labelsTest(:)));
labelsTest1=predict(Mdl1,Xtest(Ypred==1,:));
Ypred(Ypred==1)=str2num(cell2mat(labelsTest1(:)));
cp=classperf(uint8(Y(idxTest)),Ypred)

cp.CountingMatrix./sum(cp.CountingMatrix,2)
balancedAccuracy=mean(diag(cp.CountingMatrix./sum(cp.CountingMatrix,2)))

Mdl = TreeBagger(250,X_feature_trans(idxTrain,:),Y(idxTrain));
labels = predict(Mdl,X_feature_trans(idxTest,:));
labelsTest2 = predict(Mdl,X_feature_trans(idxTest,:));
cp=classperf(uint8(Y(idxTest)),str2num(cell2mat(labels(:))))
cp.CountingMatrix./sum(cp.CountingMatrix,2)
balancedAccuracy=mean(diag(cp.CountingMatrix./sum(cp.CountingMatrix,2)))

% 
% 
% img1=zeros(size(X{1}));
% img2=zeros(size(X{1}));
% img3=zeros(size(X{1}));
% img4=zeros(size(X{1}));
% img5=zeros(size(X{1}));
% % img1=[];
% % img2=[];
% % img3=[];
% % img4=[];
% % img5=[];
% neur1=[];
% neur2=[];
% neur3=[];
% neur4=[];
% neur5=[];
% for i=1:length(X)
%     if Y(i)=='1'
%         img1=img1 +X{i};
%         neur1=[neur1 sum(X{i}(5,:))];
%     elseif Y(i)=='2'
%         img2=img2 +X{i};
%         neur2=[neur2 sum(X{i}(5,:))];
%     elseif Y(i)=='3'
%         img3=img3 +X{i};
%         neur3=[neur3 sum(X{i}(5,:))];
%     elseif Y(i)=='4'
%         img4=img4 +X{i};
%         neur4=[neur4 sum(X{i}(5,:))];
%     elseif Y(i)=='5'
%         img5=img5 +X{i};
%         neur5=[neur5 sum(X{i}(5,:))];
%     end
% end
% imgTable={[img1] [img2] [img3] [img4] [img5]};
% figure
% imgT=[];
% for i=1:3
%     subplot(5,1,i)
%     imshow(imgTable{i}/1200);
%     axis image
%     %imgT=[imgT; sum(imgTable{i}(5,:),1)];
% end
