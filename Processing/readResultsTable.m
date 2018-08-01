function results=readResultsTable(path)
results=readtable(path,'Delimiter', ',', 'HeaderLines', 0, 'ReadVariableNames', true, 'Format', '%s%f%f%f%f%f%f%s');
end
