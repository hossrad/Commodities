
%% Setting parameters
numSort1 = 8; % 2*numSort1 will be nominated after first sort
numSort2 = 4; % 2*numSort2 will be nominated after second sort
rankingPeriod = 12;
tradingPeriod = 1;
tuning = 4;
pnl=[];
rets = table2array(RawReturns);
rollrets = table2array(RawRollReturns);
dateM = [month(dates(1:end,1)),[1;month(dates(1:end-1,1))]];
newMonthId = [1;find(dateM(:,1) ~= dateM(:,2))]; %1 added for the id of the first month.
totalPeriod = size(newMonthId,1); % extract total periods from daily returns
pfSettings = struct('gamma' ,1,'relativeWts',1,'tz',1);
%% Nominating Commodities
tic;
%double-sort strategy
disp('Nominating ...');
nominated = Nominate(rankingPeriod, tradingPeriod, rets, rollrets, dates, numSort1, numSort2);

%volatility timing
portfolioWeights = CalculateWeights(rankingPeriod, tradingPeriod, dailyRets, dates, tuning, pfSettings);

%% Trading

trades = Trade(nominated, rankingPeriod, tradingPeriod, totalPeriod, numSort2);

[pnl,trades] = PnL (portfolioWeights, trades, dailyRets, dates, rankingPeriod, tradingPeriod);
trades;