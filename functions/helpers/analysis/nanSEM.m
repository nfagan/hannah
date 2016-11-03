% Function for obtaining SEM
function [y] = nanSEM(x)

    nanInd = isnan(x);
    x(nanInd) = [];

    n = length(x);
    y = std(x) ./ sqrt(n);

