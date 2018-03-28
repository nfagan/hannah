save_p = '~/Documents/MATLAB/hannah_data/02222018/for_upload';

if ( exist(save_p, 'dir') ~= 7 ), mkdir( save_p ); end

lookdur = hww.io.load_sparse_measures( 'lookdur' );

bounds = hww.io.load_eye_mouth_bounds();

%%

eye_mouth_t = (0:size(bounds.data, 2)-1) * 50/1e3;

eye_mouth_bounds = struct( bounds );
looking_duration = struct( lookdur );

eye_mouth_bounds.time = eye_mouth_t;

save( fullfile(save_p, 'looking_proportion.mat'), 'eye_mouth_bounds' );
save( fullfile(save_p, 'looking_duration.mat'), 'looking_duration' );