conf = hww.config.load();
date_dir = datestr( now, 'mmddyy' );
save_path = fullfile( conf.PATHS.processedImageData, 'analyses', 'correlations', date_dir );
if ( exist(save_path, 'dir') ~= 7 ), mkdir( save_path ); end
filename = 'correlations.mat';

addpath( genpath(fullfile(conf.PATHS.repositories, 'global')) );

p = parpool( feature('NumCores') );
N = 100;

lookdur = hww.io.load_sparse_measures( 'lookdur' );
lookdur = lookdur.only( 'image' );

conts = cell( 1, N );
lookdur = parallel.pool.Constant( lookdur );

parfor i = 1:N+1
 
fprintf( '\n\n\n Iteration %d of %d\n\n\n', i, N+1 );
  
real_data = lookdur.Value;

% don't shuffle on last iteration
if ( i < N+1 )
  shuffled_data = shuffled_data.for_each( {'monkeys', 'images'}, @shuffle );
else
  shuffled_data = real_data;
end

norm = hww.process.saline_normalize( shuffled_data );
norm = norm.rm( 'saline' );
norm = norm.for_each( {'monkeys', 'doses'}, @mean );

baseline = real_data.only( 'saline' );
baseline = baseline.for_each( {'monkeys', 'doses'}, @mean );

baseline = baseline.append( baseline );
norm = norm.enumerate( {'doses', 'monkeys'} );
norm = extend( norm{:} );
[r, p] = corr( baseline.data, norm.data );
clpsed = norm.one();

clpsed.data = [r, p];
clpsed = clpsed.add_field( 'permuted', 'permuted__true' );

if ( i == N+1 ), clpsed( 'permuted' ) = 'permuted__false'; end

conts{i} = clpsed;

end

conts = extend( conts{:} );

conts = conts.add_field( 'run_time' );
conts( 'run_time' ) = datestr( now );

save( fullfile(save_path, filename), 'conts' );

%%

permuted = conts.only( 'permuted__true' );
nonpermuted = conts.only( 'permuted__false' );

P = sum( permuted.data(:, 1) < nonpermuted.data(1) ) / N;

