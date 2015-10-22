function [ pfStratDesRelWts, c, d ] = pfStrat_ckz(pfWindowXsRtrns, pfSettings )
%% CKZ model Tu,Zhou 2011
% Calculating desired relative weights
% Combination of 1/N and Kan & Zhou 3-fund model
[~,N] = size(pfWindowXsRtrns);
v1 = ones(N,1);
%M = pfSettings.WindowSize;
M = size(pfWindowXsRtrns,1);
%gamma = pfSettings.gamma;
gamma = 2;

pfCovIS_hat = cov(pfWindowXsRtrns);                          % [NxN] in-sample asset variance-covariance
pfMeanIS_hat = mean(pfWindowXsRtrns)';
pfCovIS_tilde = (M/(M-N-2))*pfCovIS_hat; 

%% Calculate KZ 2007
% Using relative weights
%w_kz = pfStrat_mv_min(pfWindowXsRtrns, pfSettings);

pfMinVarRtrnIS = (v1'*inv(pfCovIS_hat)*pfMeanIS_hat)/(v1'*inv(pfCovIS_hat)*v1);
triSq = (pfMeanIS_hat-pfMinVarRtrnIS*v1)'*inv(pfCovIS_hat)*(pfMeanIS_hat-pfMinVarRtrnIS*v1);
c3 = ((M-N-1)*(M-N-4))/(M*(M-2));
incBeta_z = (N-1)/2;
incBeta_w = (M-N+1)/2;
incBeta_x = triSq/(1+triSq);

betaVal = beta(incBeta_z,incBeta_w);
IncBeta = betainc(incBeta_x,incBeta_z,incBeta_w);
IncBeta = IncBeta*betaVal; % To make this similar to Tu and Zhou

triSq_a = (((M-N-1)*triSq-(N-1))/M)+(((2*triSq^((N-1)/2))*(1+triSq)^(-(M-2)/2))/(M*IncBeta));
w_kz = (c3/gamma)*(((triSq_a/(triSq_a+(N/M)))*inv(pfCovIS_hat)*pfMeanIS_hat)+(((N/M)/(triSq_a+(N/M)))*pfMinVarRtrnIS*inv(pfCovIS_hat)*v1));
%% Calculate equal weights
w_e = (1/N)*v1;
%% Calculate distribution across 2 portfolios
theta_tilde_sq = pfMeanIS_hat'/(pfCovIS_hat)*pfMeanIS_hat;
theta_tilde_sq_b = calcTheta2Sq_Adj(M,N,theta_tilde_sq);
c1 = ((M-2)*(M-N-2))/((M-N-1)*(M-N-4));
pi1 = w_e'*pfCovIS_hat*w_e-(2/gamma)*w_e'*pfMeanIS_hat+(1/gamma^2)*(theta_tilde_sq_b);  % pi1 measures bias of 1/N (actually variance of w_e - w_optimal)

nu_hat = triSq_a/(triSq_a+N/M); % From Tu and Zhou working paper equation 23
%nu_hat = triSq/(triSq+N/M);
%nu_hat = triSq;
mu_g_hat = pfMinVarRtrnIS;

pi13_a = (1/(gamma^2))*theta_tilde_sq_b;
pi13_b = (1/gamma)*w_e'*pfMeanIS_hat;

pi13_c1 = (1/(gamma*c1));
pi13_c2 = nu_hat*w_e'*pfMeanIS_hat;
pi13_c3 = (1-nu_hat)*mu_g_hat*w_e'*v1;
pi13_c4 = (1/gamma)*(nu_hat*pfMeanIS_hat'*inv(pfCovIS_tilde)*pfMeanIS_hat+(1-nu_hat)*(mu_g_hat)*(pfMeanIS_hat')*inv(pfCovIS_tilde)*v1);
pi13_c = pi13_c1*((pi13_c2+pi13_c3)-pi13_c4);

pi13 = pi13_a-pi13_b+pi13_c;


%pi_3_hat = =(1/gamma^2)*theta_tilde_sq_b-1/(gamma^2*c1)*(theta_tilde_sq_b-N/M*eta_hat);

pi3_a = (1/(gamma^2))*theta_tilde_sq_b;
pi3_b = 1/((gamma^2)*c1);
pi3_c = (theta_tilde_sq_b-((N/M)*nu_hat));
pi3 = pi3_a-pi3_b*pi3_c;


delta_k = (pi1-pi13)/(pi1-2*pi13+pi3);
w_ckz = (1-delta_k)*w_e+(delta_k)*w_kz;
c = delta_k; % weight on optimal KZ
d = 1-delta_k ;% weight on 1/N

if pfSettings.relativeWts == 1
    pfStratDesRelWts = w_ckz/abs(v1'*w_ckz);
else
    pfStratDesRelWts = w_ckz;
end



end
