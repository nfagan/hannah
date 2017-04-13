function eyes = hannah__get_first_quadrant_following_eye( quadrant, eyes )

any_to_eyes = any( eyes.data == 1, 2 );
eyes_use = eyes.keep( any_to_eyes );
quadrant = quadrant.keep( any_to_eyes );

full_seconds = zeros( eyes.shape(1), 1 );
seconds = zeros( eyes_use.shape(1), 1 );

for i = 1:eyes_use.shape(1)
  fprintf( '\n - %d of %d', i, eyes_use.shape(1) );
  %   locate first fixation to eye
  first = find( eyes_use.data(i, :) > 0, 1, 'first' );
  %   locate the end of that fixation
  next_zero = find( eyes_use.data(i, :) == 0 );
  next_zero = min( next_zero( next_zero > first ) );
  if ( isempty(next_zero) ), continue; end;
  %   locate the next fixation after the
  %   fixation to the eyes
  second = find( quadrant.data(i, next_zero:end) > 0, 1, 'first' );
  if ( isempty(second) ), continue; end;
  second = second + next_zero - 1;
  seconds(i) = quadrant.data( i, second );
  assert( seconds(i) > 0 );
end

full_seconds( any_to_eyes ) = seconds;
eyes.data = full_seconds;

end