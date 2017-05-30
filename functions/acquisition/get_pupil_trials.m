function mat = get_pupil_trials( time, pupil, trials, start, trial_length )

trial_starts = trials + start;
trial_ends = trial_starts + trial_length;

inds1 = arrayfun( @(x) find(time == x), trial_starts );
inds2 = arrayfun( @(x) find(time == x), trial_ends );

mat = zeros( numel(inds1), trial_length );

for i = 1:numel(inds1)
  mat(i, :) = pupil( inds1(i):inds2(i)-1 );
end

end