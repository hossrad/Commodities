function fval = objfuncSSC( x, pfMeanIS, pfCovIS, gamma )
%fval = (-x*pfMeanIS)+(gamma/2)*(x*pfCovIS*x'); 
fval = -(x*pfMeanIS)/sqrt(x*pfCovIS*x');
end

