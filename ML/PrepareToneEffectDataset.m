load('C:\Users\MOBS\Dropbox\DataKJ\Mobs\Delta_Data\Datasets\CreateDatasetTonesInUpEffect.mat')

test_train = 'random';

%% 
if strcmpi(test_train,'random')
    X = [];
    Y = [];
    for p=1:length(data_cstu.X2)
        Xtemp=data_cstu.X2{p};
        Ytemp=data_cstu.Y{p};
        for i=1:length(Xtemp)
            X=[X; (Xtemp{i}(1,:)-Xtemp{i}(2,:))-mean(Xtemp{i}(1,:)-Xtemp{i}(2,:))];
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