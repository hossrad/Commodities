function [ pfStratDesRelWts, c,d ] = pfStrat_cml( pfWindowXsRtrns, pfSettings )
%% CML model Tu,Zhou 2011
% Calculating desired relative weights
% Combination of 1/N and markowitz rule
[~,N] = size(pfWindowXsRtrns);
v1 = ones(N,1);   
M = pfSettings.WindowSize;
gamma = pfSettings.gamma;

pfCovIS_hat = cov(pfWindowXsRtrns);                          % [NxN] in-sample asset variance-covariance
pfMeanIS_hat = mean(pfWindowXsRtrns)';

%% Calculate MV 
pfCovIS_tilde = (M/(M-N-2))*pfCovIS_hat;  % TZ method scales CovIS
w_bar = (1/gamma)*(pfCovIS_tilde\pfMeanIS_hat); % TZ method with absolute weights

%Using TZ method, but relative weights
% pfSettings.tz = 1;
% w_bar = pfStrat_mv(pfWindowXsRtrns, pfSettings,0);

%% Calculate equal-weighted
w_e = (1/N)*v1;

%% Calculate weights across two portfolios
theta_tilde_sq = pfMeanIS_hat'/(pfCovIS_hat)*pfMeanIS_hat;
theta_tilde_sq_b = calcTheta2Sq_Adj(M,N,theta_tilde_sq); % TZ2007 approximator
%theta_tilde_sq_b = theta_tilde_sq;

c1 = (M-2)*(M-N-2)/((M-N-1)*(M-N-4));
pi1_hat = w_e'*pfCovIS_hat*w_e-(2/gamma)*w_e'*pfMeanIS_hat+(1/gamma^2)*(theta_tilde_sq_b);  % pi1 measures bias of 1/N (actually variance of w_e - w_optimal)
pi2_hat = (1/gamma^2)*(c1-1)*(theta_tilde_sq_b)+(c1/gamma^2)*(N/M); % pi2 measures variance of optimized weights ((actually variance of w_optimized - w_optimal)
delta_hat = pi1_hat/(pi1_hat+pi2_hat);
w_cml = (1-delta_hat)*w_e+(delta_hat)*w_bar;

c = delta_hat;    % weight on optimal MV
d = 1-delta_hat ; % weight on 1/N


if pfSettings.relativeWts == 1
    pfStratDesRelWts = w_cml/abs(v1'*w_cml);
else
    pfStratDesRelWts = w_cml;
end

%pfStratDesRelWts = w_cml;                % Calculate absolute weights
%pfStratDesRelWts = w_cml/abs(v1'*w_cml);  % Calculate relative weights


end
