function hannah__times_per_day( measure, times )

assert( all([isa(measure, 'Container'), isa(times, 'Container')]) ...
  , '`measure` and `times` must be Containers' );
assert( measure.labels == times.labels, ['`measure` and `times` must have' ...
  , ' equivalent labels.'] );
assert( measure.contains_fields('days'), 'The objects are missing a ''days'' field.' );

combined = Structure( 'measure', measure, 'times', times );

days = combined.enumerate( 'days' );
n_days = numel( days{1} );

for i = 1:n_days
  ref_struct = struct( 'type', '{}', 'subs', {{i}} );
  one_day = days.each( @(x) subsref(x, ref_struct) );
  sessions = unique( one_day{1}('sessions') );
  ind = one_day{1}.where( sessions{1} );
  sesh_times = one_day.times.data( ind, : );
  session_start = min( sesh_times(sesh_times ~= 0) );
  session_end = max( sesh_times(sesh_times ~= 0) );
  
  sessions = one_day.enumerate( 'sessions' );
  n_sessions = numel( sessions{1} );
  for k = 1:n_sessions
    ref_struct = struct( 'type', '{}', 'subs', {{k}} );
    one_sesh = sessions.each( @(x) subsref(x, ref_struct) );
    one_times = one_sesh.times;
    one_measure = one_sesh.measure;
  end
end

end