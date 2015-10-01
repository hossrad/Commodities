figure;
hold;
title('Wealth evolution ($1)');

plot(pnl(:,1),cumprod(pnl(:,2)+1),'LineWidth',2);
plot(pnl(:,1),cumprod(pnl(:,3)+1),'LineWidth',2);
xlabel('Month');
ylabel('Wealth');
legend('Volatility timing','Double-sort');
grid on;


dssharpe = zeros(394,1);
vtsharpe = zeros(394,1);
for i=36:394
    dssharpe(i,1) = mean(pnl(i-23:i,3))/std(pnl(i-23:i,3));
    vtsharpe(i,1) = mean(pnl(i-23:i,2))/std(pnl(i-23:i,2));
end
dssharpe(1:35,1) = nan;
vtsharpe(1:35,1) = nan;
figure;
title('24 month moving average Sharpe ratio');
hold on;
plot(pnl(:,1),vtsharpe,'LineWidth',2);
plot(pnl(:,1),dssharpe,'LineWidth',2);
legend('Volatility timing','Double-sort');
xlabel('Month');
ylabel('Sharpe Ratio');
grid on;