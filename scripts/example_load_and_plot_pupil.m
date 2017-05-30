sample_kinds = { 'time', 'posX', 'posY', 'pupilSize' };
edf_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/edfs/ephron/high';

edfs = get_trials( edf_dir, sample_kinds );

%%

trials = cellfun( @(x) unique(datasample(x(:, 1), 100)), edfs, 'un', false );

trial_start = -1e3;
trial_length = 1e3;

for i = 1:numel(edfs)
  time = edfs{i}(:, 1);
  pupil = edfs{i}(:, 4);
  mat = get_pupil_trials( time, pupil, trials{i}, trial_start, trial_length );
end

%%



