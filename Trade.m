%
%output: trades matrix
%Column 1: open period
%Colimn 2: close period
%Column 3: trading commodity 
%Column 4: trade direction ----> +1(long) -1(short)
%Column 5: trade return

function trades = Trade(nominated, rankingPeriod, tradingPeriod, totalPeriod, periodTradeCount)
trades = zeros((totalPeriod-rankingPeriod)*periodTradeCount*2/tradingPeriod,5);
lastTradeIndex = 0;
for period = rankingPeriod+1:tradingPeriod:totalPeriod
    
    
    %% Open positions that should be opened this period
    longTrades = cell2mat(nominated(cell2mat(nominated(:,1))==period,2))';
    longNum = size(longTrades,1);
    trades(lastTradeIndex+1:lastTradeIndex+longNum,1:4) = [repmat(period,longNum,1) repmat(-1,longNum,1)  longTrades ones(longNum,1)];
    lastTradeIndex = lastTradeIndex+ longNum;
    
    shortTrades = cell2mat(nominated(cell2mat(nominated(:,1))==period,3))';
    shortNum = size(shortTrades,1);
    trades(lastTradeIndex+1:lastTradeIndex+longNum,1:4) = [repmat(period,shortNum,1) repmat(-1,shortNum,1)  shortTrades -1*ones(shortNum,1)];
    lastTradeIndex = lastTradeIndex+ shortNum;
    
end
%% Close all open positions 
trades(:,2)=min(trades(:,1)+tradingPeriod,totalPeriod);