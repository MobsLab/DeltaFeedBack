function updateModel()
    KNN = fitcknn(X,Y,'Distance','seuclidean','NumNeighbors',18);
end

