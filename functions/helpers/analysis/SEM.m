% Function for obtaining SEM
function [y] = SEM(x)

    n = length(x);
    y = std(x) ./ sqrt(n);

