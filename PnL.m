function [pnl, trades] = PnL(portfolioWeights, trades, dailyRets, dates, rankingPeriod, tradingPeriod)
    dateM = [month(dates(1:end,1)),[1;month(dates(1:end-1,1))]];
    newMonthId = [1;find(dateM(:,1) ~= dateM(:,2))]; %1 added for the id of the first month.
    totalPeriod = size(newMonthId,1); % extract total periods from daily returns
    pnl = zeros(totalPeriod,3);
    pnl(:,1) = [1:totalPeriod]';
    
    %Calculate pnl for the vol timining strategy
    for period = rankingPeriod+1:totalPeriod
        startRow = newMonthId(period);
        if period ~= totalPeriod
            endRow = newMonthId(period+1)-1;
        else
            endRow = size(dailyRets,1);
        end
        monthRets = prod(dailyRets(startRow:endRow,:)+1)-1;
        ind = find(portfolioWeights(:,1)<= period,1,'last');
        monthRets(isnan(monthRets))=0;
        pnl(period, 2) = portfolioWeights(ind,2:end) * monthRets';
    end      
    
    %calculate pnl for the double-sort strategy
    tradeNum = size(trades,1);
    for i = 1:tradeNum
        startIndex = newMonthId(trades(i,1));
        endIndex = newMonthId(trades(i,2))-1;
        trades(i,5) = (prod(dailyRets(startIndex:endIndex,trades(i,3))+1)-1)*trades(i,4);
    end
    trades(isnan(trades(:,5)),5)=0;
    pnl(:,3) = accumarray(trades(:,1),trades(:,5),[totalPeriod 1],@mean);
 
end