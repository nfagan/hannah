function [obj, time_course] = pupil__adjust_timecourse( obj, time_course, start_stop )

data = obj.data;
assert( numel(time_course) == size(data, 2), ['The provided timecourse does' ...
  , ' not match the dimensions of the pupil data. Perhaps you have already' ...
  , ' adjusted the timecourse?'] );
assert( numel(start_stop) == 2, ['Expected `start_stop` to have two elements' ...
  , ' but %d were given'], numel(start_stop) );
assert( all([any(time_course == start_stop(1)), any(time_course == start_stop(2))]), ...
  'The specified timecourse does not contain the start or stop (or both) values' );

ind = find(time_course == start_stop(1)):find(time_course == start_stop(2));
data = data(:, ind);
time_course = time_course(:, ind);
obj.data = data;

end