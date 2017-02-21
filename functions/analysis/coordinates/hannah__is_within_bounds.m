function x = hannah__is_within_bounds( x, y, bounds )

assert( isa(x, 'Container') && isa(y, 'Container') ...
  , 'Specify x and y coordinates as Container objects.' );
assert( x.labels == y.labels, 'The label objects of x and y must match' );
bounds_msg = ['Specify bounds as a 4 element double vector; was a ''%s''' ...
  , ' with %d elements'];
assert( isa(bounds, 'double'), bounds_msg, class(bounds), numel(bounds) );
assert( numel(bounds) == 4, bounds_msg, class(bounds), numel(bounds) );

within_x = x.data >= bounds(1) & x.data <= bounds(2);
within_y = y.data >= bounds(3) & y.data <= bounds(4);
x.data = within_x & within_y;

end