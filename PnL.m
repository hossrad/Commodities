function [pnl, trades] = PnL(portfolioWeights, trades, dailyRets, dates, rankingPeriod, tradingPeriod)
    dateM = [month(dates(1:end,1)),[1;month(dates(1:end-1,1))]];
    newMonthId = [1;find(dateM(:,1) ~= dateM(:,2))]; %1 added for the id of the first month.
    totalPeriod = size(newMonthId,1); % extract total periods from daily returns
    pnl = zeros(totalPeriod,5);
    %Column 1: Periods
    %Column 2: Vol timing starategy
    %Column 3: Min strategy
    %Column 4: MV strategy
    %Column 5: Double-sort strategy
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
        ind = find(portfolioWeights.VolTiming(:,1)<= period,1,'last');
        monthRets(isnan(monthRets))=0;
        %Volatility timing strategy
        pnl(period, 2) = portfolioWeights.VolTiming(ind,2:end) * monthRets';
        %Min strategy
        pnl(period, 3) = portfolioWeights.MinVar(ind,2:end) * monthRets';
        %Mv strategy
        pnl(period, 4) = portfolioWeights.MeanVar(ind,2:end) * monthRets';
    end      
    
    %calculate pnl for the double-sort strategy
    tradeNum = size(trades,1);
    for i = 1:tradeNum
        startIndex = newMonthId(trades(i,1));
        endIndex = newMonthId(trades(i,2))-1;
        trades(i,5) = (prod(dailyRets(startIndex:endIndex,trades(i,3))+1)-1)*trades(i,4);
    end
    trades(isnan(trades(:,5)),5)=0;
    pnl(:,5) = accumarray(trades(:,1),trades(:,5),[totalPeriod 1],@mean);
 
end