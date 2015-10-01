function data = CleanData(data)
for i = 1:size(data,2)
    startRow=1;
    while isnan(data(startRow,i))
        startRow=startRow+1;
    end
    endRow = size(data,1);
    while isnan(data(endRow,i))
        endRow = endRow-1;
    end
    for j=startRow:endRow
        if isnan(data(j,i))
            data(j,i) = data(j-1,i);
        end
    end
end