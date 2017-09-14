conf = hww.config.load();
load_path = fullfile( conf.PATHS.processedImageData, 'analyses', 'correlations', '083117' );
load_path = fullfile( load_path, 'correlations.mat' );

conts = load( load_path );

real_ind = conts.conts.where( 'permuted__false' );
fake_ind = conts.conts.where( 'permuted__true' );

real_r = conts.conts.data(real_ind, 1);
fake_r = conts.conts.data(fake_ind, 1);

p = sum( fake_r < real_r ) / sum(fake_ind);
