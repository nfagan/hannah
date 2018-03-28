function data = get_matched_pupil_and_lookdur()

conf = hww.config.load();
p = conf.PATHS.processedImageData;
fname = fullfile( p, '113017', 'pupil_during_fixation_plus_lookdur.mat' );
data = load( fname );
data = data.(char(fieldnames(data)));
is_zero = data.looking_duration.data == 0;
data = structfun( @(x) keep(x, ~is_zero), data, 'un', false );

end