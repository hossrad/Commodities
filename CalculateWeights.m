function pfWeights = CalculateWeights(rankingPeriod, holdingPeriod, rets, dates, tuning)

    dateM = [month(dates(1:end,1)),[1;month(dates(1:end-1,1))]];
    newMonthId = [1;find(dateM(:,1) ~= dateM(:,2))]; %1 added for the id of the first month.
    totalPeriod = size(newMonthId,1); % extract total periods from daily returns
    pfWeights = zeros(floor((totalPeriod-rankingPeriod)/holdingPeriod),size(rets,2)+1);
    currentRow = 1;
    for period = rankingPeriod+1:holdingPeriod:totalPeriod
        startRow = newMonthId(period-rankingPeriod);
        endRow = newMonthId(period)-1;
        pfWeights(currentRow,:) = [period pfcommodities_timing(rets(startRow:endRow,:), [], 'rt_vol', tuning)'];
        currentRow = currentRow+1;
    end


