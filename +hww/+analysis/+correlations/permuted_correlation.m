conf = hww.config.load();
date_dir = datestr( now, 'mmddyy' );
save_path = fullfile( conf.PATHS.processedImageData, 'analyses', 'correlations', date_dir );
if ( exist(save_path, 'dir') ~= 7 ), mkdir( save_path ); end
filename = 'correlations.mat';

addpath( genpath(fullfile(conf.PATHS.repositories, 'global')) );

warning( 'off', 'all' );

p = gcp( 'nocreate' );
if ( isempty(p) )
  p = parpool( feature('NumCores') );
end

N = 10;
do_save = true;
do_parallel = false;

lookdur = hww.io.load_sparse_measures( 'lookdur' );
lookdur = lookdur.only( 'image' );
lookdur = lookdur.add_field( 'kind', 'baseline' );
lookdur = lookdur.add_field( 'permuted', 'permuted__true' );

conts = cell( 1, N );
dists = cell( 1, N );

if ( ~do_parallel )
  lookdur = struct( 'Value', lookdur );
else
  lookdur = parallel.pool.Constant( lookdur );
end

fprintf( 'Progress:\n' );
fprintf( ['\n' repmat('.', 1, N+1) '\n\n'] );
tic;
parfor i = 1:N+1
  
warning( 'off', 'all' );
  
real_data = lookdur.Value;

% don't shuffle on last iteration
if ( i < N+1 )
  shuffled_data = real_data.shuffle_each( {'monkeys', 'images'} );
else
  shuffled_data = real_data;
  shuffled_data( 'permuted' ) = 'permuted__false';
end

norm = hww.process.saline_normalize( shuffled_data );
norm = norm.rm( 'saline' );
norm = norm.for_each( {'monkeys', 'doses'}, @mean );
norm( 'kind' ) = 'normalized';

base = shuffled_data.only( 'saline' );
base = base.for_each( {'monkeys', 'doses'}, @mean );

dists{i} = base.append( norm );

%   arrange so that labels are equivalent
base = base.append( base );
norm = Container.concat( norm.enumerate({'doses', 'monkeys'}) );

fs = { 'kind', 'doses' };
assert( eq_ignoring(norm.labels, base.labels, fs), 'Labels are not equivalent.' );

[r, p] = corr( base.data, norm.data );
clpsed = norm.one();

clpsed.data = [r, p];

conts{i} = clpsed;

fprintf( '\b|\n' );

end

run_time = datestr( now );

dists = Container.concat( dists );
conts = Container.concat( conts );
conts = conts.add_field( 'run_time', run_time );
dists = dists.add_field( 'run_time', run_time );

if ( do_save )
  save( fullfile(save_path, filename), 'conts', 'dists' );
end

toc;

warning( 'on', 'all' );

%%

permuted = conts.only( 'permuted__true' );
nonpermuted = conts.only( 'permuted__false' );

P = sum( permuted.data(:, 1) < nonpermuted.data(1) ) / N;

