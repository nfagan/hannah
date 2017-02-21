function [response, predicts, factors] = hannah__get_factor_matrix(obj, factors, time)

if ( nargin < 3 ), time = []; end;

n_bins = shape( obj, 2 );
predicts = get_predictors( obj(:), factors );

if ( ~isempty(time) )
  assert( numel(time) == n_bins, ['The given time values do not match' ...
    , ' the number of data points in the object'] );
  n_reps = size( predicts, 1 ) / n_bins;
  time = repmat( time(:), n_reps, 1 );
  predicts = [predicts, time];
  factors = [ factors, {'time'} ];
end

response = obj.data(:);

end

function predicts = get_predictors(obj, factors)

predicts = zeros( shape(obj, 1), numel(factors) );

for i = 1:numel(factors)
  unqs = unique( obj(factors{i}) );
  for k = 1:numel(unqs)
    ind = obj.where( unqs{k} );
    predicts(ind, i) = k;
  end
end


end