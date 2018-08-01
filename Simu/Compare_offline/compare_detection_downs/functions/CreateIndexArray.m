function IndexArray = CreateIndexArray (DetectionMatrix,freq)

IndexArray = [];
for i = 1:size(DetectionMatrix,1)
    IndexArray = [IndexArray  DetectionMatrix(i,1)*1e-4*freq:DetectionMatrix(i,2)*1e-4*freq];
end
IndexArray = round(IndexArray);

