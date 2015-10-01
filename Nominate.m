%Sorts commodities and nominates the 2*numSort1 based on the first sort for each trading period.
%2*numSort2 will be selected after the second sort for each trading period.
function nominated = Nominate(rankingPeriod, tradingPeriod, rets, rollrets, dates, numSort1, numSort2)
dateM = [month(dates(1:end,1)),[1;month(dates(1:end-1,1))]];
newMonthId = [1;find(dateM(:,1) ~= dateM(:,2))]; %1 added for the id of the first month.
totalPeriod = size(newMonthId,1); % extract total periods from daily returns
nominated = cell(floor(totalPeriod/rankingPeriod),3);
lastIndex =0;
for period = rankingPeriod+1:tradingPeriod:totalPeriod
    startRow = newMonthId(period-rankingPeriod);
    endRow = newMonthId(period)-1;
    tRets = rets(startRow:endRow,:);
    tRollrets = rollrets(startRow:endRow,:);
%     tRets(isnan(tRets))=0;
%     tRollrets(isnan(tRollrets))=0;
    
    %% Preform the first sort
    
    meanRets = mean(tRets);
    [sorted, sorted1Index] = sort(meanRets,'descend');
    firstNumIndex = find(isnan(sorted),1,'last')+1;
    if isempty(firstNumIndex)
        firstNumIndex = 1;
    end
    % keep the top numSort1 and bottom numSort1 and ignore the rest.
    topSort1 = sorted1Index(firstNumIndex:firstNumIndex+numSort1-1);
    bottomSort1 = flip(sorted1Index(max(end-numSort1+1,firstNumIndex):end));
    
    %% Perform the second sort
    meanRollretsTop = mean(tRollrets(:,topSort1));
    [~, sorted2IndexTop] = sort(meanRollretsTop, 'descend');
    %retrieve the original indices of the best performers of 2 sorts.
    buyList = topSort1(sorted2IndexTop(1:numSort2));
    
    meanRollretsBottom = mean(tRollrets(:,bottomSort1));
    [~, sorted2IndexBottom] = sort(meanRollretsBottom, 'ascend');
    %retrieve the original indices of the worst performers of 2 sorts.
    sellList = bottomSort1(sorted2IndexBottom(1:numSort2));
    
    %create output
    
    %Column 1: trade month.
    %Column 2: buy list.
    %Column 3: Sell list.
    nominated(lastIndex+1,:)={period, buyList, sellList};
    lastIndex = lastIndex+1;

end

