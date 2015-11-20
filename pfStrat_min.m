function [ pfStratDesRelWts ] = pfStrat_min( pfWindowXsRtrns, pfSettings, SSconst)
% Minimum-variance portfolio 
% Calculating desired relative weights
%  This code uses John Cochrane's calculation of desired weights for
%  minimum variance without weight constraints in the else statement.  The
%  first part of the code is where we have (1) short sales constraints and
%  (2) diversification constraints of 1/N.
%
% If we perform fmincon on the objfuncMinVar function without any vub or
% vlb constraints, we get the same answer as the John Cochrane methodology
%
%
%% Remove Nan columns and add them back later with zero weight

[~,colNans] = find(isnan(pfWindowXsRtrns));
colNans = unique(colNans);

originalN = size(pfWindowXsRtrns,2);
pfWindowXsRtrns(:,colNans)=[];
cols = 1:originalN;
cols(:,colNans) = []; %non NaN column numbers


gamma= pfSettings.gamma;
[~,N] = size(pfWindowXsRtrns);

%% SSconstOptions

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
 

v1 = ones(N,1);   

pfCovIS = cov(pfWindowXsRtrns);     % [NxN] in-sample asset variance-covariance

%Portfolio weights
if SSconst == 1 || SSconst == 2     % Short sales constraints enforced
   % SSconstOptions
   
    if SSconst == 2
        vlb = 0.5*1/N*ones(1,N);       % Minimum of 0.5* 1/N weight as per DeMiguel (2007) and no maximum
    end
    
    [x, fval] = fmincon(@(x)objfuncMinVar(x,pfCovIS),x0,...
                                       [],[],Aeq,Beq,vlb,vub,[],options);
    
    pfWts = x';                                                 % [Nx1] portfolio weights   
else
    % No short-sales constraints and no maximum weight.
    pfWts = pfCovIS\v1;                                     % [Nx1] portfolio weights
    %pfWts = (1/gamma)*(pfCovIS\pfMeanIS);            
end


%Portfolio weights
%Formula for below is on P82 of John Cochrane's Asset pricing book
                                     % [Nx1] portfolio weights


if pfSettings.relativeWts == 1
    pfStratDesRelWts = pfWts/abs(v1'*pfWts);
else
    pfStratDesRelWts = pfWts;
end
                                     
%pfStratDesRelWts = pfWts/abs(v1'*pfWts);                           % [Nx1] relative portfolio weights

%% Add back NaN columns that were deleted in the beginning.
%Replace NaN columns with zero weights
temp = pfStratDesRelWts;
pfStratDesRelWts = zeros(originalN,1);
pfStratDesRelWts(cols,1) = temp;
end

