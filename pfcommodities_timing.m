function [ pfStratDesWts ] = pfcommodities_timing( pfWindowXsRtrns, pfSettings, stratName, tuning)
% pfWindowXsRtrns is the window of returns to calculate risk
% pfSettings is the settings for the strategy.  pfWindowRiskfactors are the
% risk-factors for the asset type.  For equities, risk factors are MKT,
% SMB, MOM, LIQ.
% Stratname is the name of the strategy.

%pfWindowRiskfactors = pfSettings.windowRiskFactors;

pfMeanIS = mean(pfWindowXsRtrns)';                                          % [Nx1] in-sample asset returns
pfStdIS = nanstd(pfWindowXsRtrns)';
pfCovIS = cov(pfWindowXsRtrns);
%pfVaRIS = VaRisk(pfWindowXsRtrns,beta);
%pfCVaRIS = CVaRisk(pfWindowXsRtrns,beta);
N=size(pfWindowXsRtrns,1);


switch lower(stratName)
    case '1_n' % Equally-weighted
        pfStratDesRelWts = 1/N*ones(N,1);
    case 'rt_vol' % Variance
        riskParam = (1./pfStdIS.^2).^tuning;
    case 'rt_var' % Value-at-Risk
        riskParam = ((1./pfVaRIS).^tuning)';
    case 'rt_cvar' % Conditional-Value-At-Risk
        riskParam = ((1./pfCVaRIS).^tuning)';
    case 'rrt_beta'
        for i = 1:N
            stats = regstats(pfWindowXsRtrns(:,i),pfWindowRiskfactors,'linear',{'beta','rsquare','adjrsquare','tstat'});
            [~,N_riskfactor] = size(pfWindowRiskfactors);
            betaVal = stats.beta(2:end);
            betaTotal = sum(betaVal);
            avgBeta(i) = betaTotal/N_riskfactor;
        end
        riskParam = (avgBeta'./(pfStdIS.^2)).^tuning;
    case 'rrt_beta_pos'
        for i = 1:N
            stats = regstats(pfWindowXsRtrns(:,i),pfWindowRiskfactors,'linear',{'beta','rsquare','adjrsquare','tstat'});
            [~,N_riskfactor] = size(pfWindowRiskfactors);
            betaVal = stats.beta(2:end);
            betaTotal = sum(betaVal);
            avgBeta(i) = betaTotal/N_riskfactor;
            avgBetaPos(i) = max(avgBeta(i),0);
        end
        riskParam = (avgBetaPos'./(pfStdIS.^2)).^tuning;
end

if strcmp(lower(stratName),'1_n')
    pfStratDesWts = pfStratDesRelWts;
else
    riskParam(isnan(riskParam))=0;
    riskParam(isinf(riskParam))=0;
    pfStratDesWts = riskParam/sum(riskParam);
end

end