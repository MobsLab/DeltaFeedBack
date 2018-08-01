function index_list=testEndIndex(index,allresult)
    if(index(end)+1>size(allresult,1))
        index_list=index(1:end-1);
    else 
        index_list=index;
    end
end