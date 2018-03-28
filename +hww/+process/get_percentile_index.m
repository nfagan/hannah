function ind = get_percentile_index(data, N)

import shared_utils.assertions.*;

assert__isa( data, 'Container' );
assert__isa( N, 'double' );
assert__is_scalar( N );
assert__is_vector( data.data );

cutoffs = prctile( data.data, (1/N:1/N:1)*100 );

ind = zeros( size(data.data, 1), 1 );

ind( data.data <= cutoffs(1) ) = 1;

for i = 2:numel(cutoffs)
  ind_ = data.data <= cutoffs(i) & data.data > cutoffs(i-1);
  ind( ind_ ) = i;
end

assert( ~any(ind==0), 'Some elements weren''t assigned.' );

ind = set_data( data, ind );

end