function pfWeights = CalculateWeights(rankingPeriod, holdingPeriod, rets, dates, tuning , pfSettings, SSConst )
    dateM = [month(dates(1:end,1)),[1;month(dates(1:end-1,1))]];
    newMonthId = [1;find(dateM(:,1) ~= dateM(:,2))]; %1 added for the id of the first month.
    totalPeriod = size(newMonthId,1); % extract total periods from daily returns
    sz = floor((totalPeriod-rankingPeriod)/holdingPeriod);
    vtWeights = zeros(sz,size(rets,2)+1);
    minWeights = zeros(sz,size(rets,2)+1);
    mvWeights = zeros(sz,size(rets,2)+1);
    currentRow = 1;
    for period = rankingPeriod+1:holdingPeriod:totalPeriod
        disp({'Period ' , period})
        startRow = newMonthId(period-rankingPeriod);
        endRow = newMonthId(period)-1;
        vtWeights(currentRow,:) = [period pfcommodities_timing(rets(startRow:endRow,:), [], 'rt_vol', tuning)'];
        minWeights(currentRow,:) = [period pfStrat_min( rets(startRow:endRow,:),pfSettings,  SSConst)'];
        mvWeights(currentRow,:) = [period pfStrat_mv( rets(startRow:endRow,:), pfSettings, SSConst)'];    
        currentRow = currentRow+1;
    end
    pfWeights = struct ('VolTiming', vtWeights, 'MinVar' ,minWeights, 'MeanVar', mvWeights);
