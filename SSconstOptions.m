x0 = 1/N*ones(1,N);
Aeq = ones(1,N);
Beq = 1;
vlb = zeros(1,N);           
%vlb = -1000*ones(1,N);
vub = 1000*ones(1,N);
options = optimset('TolCon',1*10^-6','TolX',1*10^-6,...
    'TolFun',1*10^-6,'MaxFunEvals',1*10^6,...
    'Display','none','Algorithm','interior-point','LargeScale','on',...
    'FinDiffType','central');

%vlb = -1000*ones(1,N);        
 