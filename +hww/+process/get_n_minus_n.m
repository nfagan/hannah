function [out_a, out_b] = get_n_minus_n(a, b, n)

import shared_utils.assertions.*;

assert__isa( a, 'Container' );
assert__isa( b, 'Container' );
assert__isa( n, 'double' );
assert__is_scalar( n );
assert( a.labels == b.labels, 'Labels must match.' );

ind_a = 1:shape(a, 1) - n;
ind_b = n+1:shape(b, 1);

out_a = a(ind_a);
out_b = b(ind_b);

end