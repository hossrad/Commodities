function [ pfStratDesWts pfMeanIS pfCovIS] = pfStrat_mv( pfWindowXsRtrns, pfSettings, SSconst)
% Mean-variance (Out-of-sample)
% Calculating desired relative weights

%% Remove Nan columns and add them back later with zero weight
[~,colNans] = find(isnan(pfWindowXsRtrns));
colNans = unique(colNans);

originalN = size(pfWindowXsRtrns,2);
pfWindowXsRtrns(:,colNans)=[];
cols = 1:originalN;
cols(:,colNans) = []; %non NaN column numbers
%% 


[M,N] = size(pfWindowXsRtrns);
v1 = ones(N,1);                                                             % [Nx1] vector of 1s
gamma = pfSettings.gamma;

pfMeanIS = mean(pfWindowXsRtrns)';                                          % [Nx1] in-sample asset returns 
pfCovIS = cov(pfWindowXsRtrns);                                             % [NxN] in-sample asset variance-covariance 

%% Add SSconstOptions
x0 = 1/N*ones(1,N);
Aeq = ones(1,N);
Beq = 1;
if SSconst ~= 0 
    vlb = zeros(1,N);  
else
    vlb = -1*ones(1,N);
end
vub = ones(1,N);
options = optimset('TolCon',1*10^-6','TolX',1*10^-6,...
    'TolFun',1*10^-6,'MaxFunEvals',1*10^6,...
    'Display','none','Algorithm','interior-point','LargeScale','on',...
    'FinDiffType','central');
%% 

if pfSettings.tz == 1
    pfCovIS = (M/(M-N-2))*pfCovIS; % Scale it according to TZ 2011
end

%pfCovISclean = cleanMatrix(pfCovIS);

if SSconst == 1   
    %SSconstOptions
    [x, fval] = fmincon(@(x)objfuncSSC(x,pfMeanIS,pfCovIS,gamma),x0,[],[],Aeq,Beq,vlb,vub,[],options);
    pfWts = x';                                             % [Nx1] portfolio weights    
    
else
    %pfWts = pfCovIS\pfMeanIS;                                                   % [Nx1] portfolio weights   
    %pfWts = pfCovISclean\pfMeanIS; 
    pfWts = (1/gamma)*(pfCovIS\pfMeanIS);
                                                      % [Nx1] portfolio weights   
end

if pfSettings.relativeWts == 1
    pfStratDesWts = pfWts/abs(v1'*pfWts);
else
    pfStratDesWts = pfWts;
end

%pfStratDesRelWts = pfWts;
%pfStratDesRelWts = pfWts/abs(v1'*pfWts);       % [NxT] relative portfolio weights

%% Add back NaN columns that were deleted in the beginning.
%Replace NaN columns with zero weights
temp = pfStratDesWts;
pfStratDesWts = zeros(originalN,1);
pfStratDesWts(cols,1) = temp;
end

