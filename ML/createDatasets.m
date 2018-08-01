load('C:\Users\MOBS\Dropbox\DataKJ\Mobs\Delta_Data\Datasets\DatasetSubstageFromSUA2.mat')

test_train = 'random';

cd Datasets
%% 
if strcmpi(test_train,'random')
    X = [];
    Y = [];
    for p=1:length(data_csfs.X)
        X = [];
        Y = [];
        Xtemp=data_csfs.X{p};
        Ytemp=data_csfs.Y{p};
        UnitIDtemp=data_csfs.unitID{p};
        Nametemp=data_csfs.name{p};
        for i=1:length(Xtemp)
            X=[X; extractFeatures(Xtemp{i},UnitIDtemp,Nametemp)'];
            Y=[Y; Ytemp(i)];
        end
        save(strcat('data',num2str(p),'.mat'),'X','Y');
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