function binned = hannah__bin_within_bounds(bounds, bin_size)

start = 1;
data = bounds.data;
n_bins = floor( size(data, 2) / bin_size );
new_data = false( size(data, 1), n_bins );

for i = 1:n_bins
  extr = data( :, start:start+bin_size-1 );
  new_data(:, i) = any( extr, 2 );
  start = start + bin_size;
end

if ( start < size(data, 2) )
  new_data(:, end+1) = any( data(:, start:end), 2 );
end

binned = bounds;
binned.data = new_data;

end