function binned = hannah__bin_within_bounds(bounds, bin_size)

start = 1;
data = bounds.data;
n_bins = floor( size(data, 2) / bin_size );
new_data = zeros( size(data, 1), n_bins );
unqs = unique( bounds.data(:) );

for i = 1:n_bins
  extr = data( :, start:start+bin_size-1 );
  for k = 1:numel(unqs)
    ind = any( extr == unqs(k), 2 );
    new_data( ind, i ) = unqs(k);
  end
  start = start + bin_size;
end

if ( start < size(data, 2) )
  new_data(:, end+1) = any( data(:, start:end), 2 );
end

binned = bounds;
binned.data = new_data;

end