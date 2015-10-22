function pfWeights = CalculateWeights(rankingPeriod, holdingPeriod, rets, dates, tuning , pfSettings)
    dateM = [month(dates(1:end,1)),[1;month(dates(1:end-1,1))]];
    newMonthId = [1;find(dateM(:,1) ~= dateM(:,2))]; %1 added for the id of the first month.
    totalPeriod = size(newMonthId,1); % extract total periods from daily returns
    pfWeights = zeros(3,floor((totalPeriod-rankingPeriod)/holdingPeriod),size(rets,2)+1);
    currentRow = 1;
    for period = rankingPeriod+1:holdingPeriod:totalPeriod
        disp({'Period ' , period})
        startRow = newMonthId(period-rankingPeriod);
        endRow = newMonthId(period)-1;
        pfWeights(1,currentRow,:) = [period pfcommodities_timing(rets(startRow:endRow,:), [], 'rt_vol', tuning)'];
        pfWeights(2,currentRow,:) = [period pfStrat_min( rets(startRow:endRow,:), 1, pfSettings)'];
        pfWeights(3,currentRow,:) = [period pfStrat_mv( rets(startRow:endRow,:), pfSettings, 1)'];
        currentRow = currentRow+1;
    end


