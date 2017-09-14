conf = hww.config.load();
date_dir = datestr( now, 'mmddyy' );
save_path = fullfile( conf.PATHS.processedImageData, 'analyses', 'correlations', date_dir );
if ( exist(save_path, 'dir') ~= 7 ), mkdir( save_path ); end
filename = 'correlations.mat';

addpath( genpath(fullfile(conf.PATHS.repositories, 'global')) );
addpath( genpath(fullfile(conf.PATHS.repositories, 'hannah')) );

warning( 'off', 'all' );

p = gcp( 'nocreate' );
if ( isempty(p) )
  p = parpool( feature('NumCores') );
end

N = 1e3;
do_save = true;
do_parallel = true;

lookdur = hww.io.load_sparse_measures( 'lookdur' );
lookdur = lookdur.only( 'image' );
lookdur = lookdur.add_field( 'kind', 'baseline' );
lookdur = lookdur.add_field( 'permuted', 'permuted__true' );

conts = cell( 1, N );
dists = cell( 1, N );
all_data = cell( 1, N );

if ( ~do_parallel )
  lookdur = struct( 'Value', lookdur );
else
  lookdur = parallel.pool.Constant( lookdur );
end

fprintf( 'Progress:\n' );
fprintf( ['\n' repmat('.', 1, N+1) '\n\n'] );

tic;

for i = 1:N+1
  
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

current_dist = shuffled_data;
soc_ind = ~current_dist.where( {'outdoors', 'scrambled'} );
current_dist( 'images', soc_ind ) = 'social';
current_dist( 'images', ~soc_ind ) = 'nonsocial';
current_dist = current_dist.for_each_1d( {'sessions', 'images'}, @Container.mean_1d );

all_data{i} = current_dist;

norm = norm.for_each_1d( {'monkeys', 'doses'}, @Container.mean_1d );
norm( 'kind' ) = 'normalized';

base = shuffled_data.only( 'saline' );
base = base.for_each_1d( {'monkeys', 'doses'}, @Container.mean_1d );

dists{i} = base.append( norm );

% %   arrange so that labels are equivalent
% base = base.append( base );
% norm = Container.concat( norm.enumerate({'doses', 'monkeys'}) );
norm = norm.for_each_1d( 'monkeys', @Container.mean_1d );

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
  save( fullfile(save_path, filename), 'conts', 'dists', 'all_data' );
end

toc;

warning( 'on', 'all' );

%%

permuted = conts.only( 'permuted__true' );
nonpermuted = conts.only( 'permuted__false' );

P = sum( permuted.data(:, 1) < nonpermuted.data(1) ) / N;

