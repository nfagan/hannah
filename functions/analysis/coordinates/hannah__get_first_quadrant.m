function bounds = hannah__get_first_quadrant( bounds )

none = ~any( bounds.data > 0, 2 );
present = bounds.keep( ~none );
seconds = zeros( present.shape(1), 1 );

for i = 1:present.shape(1)
  fprintf( '\n - %d of %d', i, present.shape(1) );
  first = find( present.data(i, :) > 0, 1, 'first' );
  next_zero = find( present.data(i, :) == 0 );
  next_zero = min( next_zero( next_zero > first ) );
  second = find( present.data(i, next_zero:end) > 0, 1, 'first' );
  if ( isempty(second) ), continue; end;
  second = second + next_zero - 1;
  seconds(i) = present.data( i, second );
end

bounds.data = bounds.data(:, 1);
bounds.data( ~none ) = seconds;

end