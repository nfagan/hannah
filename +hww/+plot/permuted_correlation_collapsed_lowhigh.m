import hww.process.arr_join;

conf = hww.config.load();
date_dir = '091417';
load_dir = fullfile( conf.PATHS.processedImageData, 'analyses', 'correlations', date_dir );
save_dir = fullfile( conf.PATHS.plots, datestr(now, 'mmddyy') );

if ( exist(save_dir, 'dir') ~= 7 ), mkdir( save_dir ); end
load( fullfile(load_dir, 'correlations.mat') );
dists = dists.add_field( 'group', 'group1' );
base = dists.only( {'baseline', 'permuted__true'} );
norm = dists.only( {'normalized', 'permuted__true'} );

stats = Container();

take_mean = true;
add_text = false;
do_save = false;

if ( take_mean )
  base = base.for_each( {'monkeys', 'doses'}, @mean );
  norm = norm.for_each( {'monkeys', 'doses'}, @mean );
  fname = 'scatter_means';
else
  fname = 'scatter_all_points';
end

rebuilt = Container();
enumed = norm.enumerate( {'monkeys'} );
for i = 1:numel(enumed)
  per_dose = enumed{i}.enumerate( 'doses' );
  assert( numel(per_dose) == 2 );
  data = [ per_dose{1}.data, per_dose{2}.data ];
  data = mean( data, 2 );
  one_dose = per_dose{1};
  one_dose.data = data;
  one_dose = one_dose.collapse( 'doses' );
  rebuilt = rebuilt.append( one_dose );
end

norm = rebuilt;
base = Container.concat( base.enumerate('monkeys') );

fs = { 'kind', 'doses', 'group' };

% sanity check -- do the labels match (ignoring dose, kind, and group)?
assert( eq_ignoring(base.labels, norm.labels, fs) );

% plot permuted distribution
coeff = polyfit( base.data, norm.data, 1 );
[r, p] = corr( base.data, norm.data );
current_corr = norm.one();
current_corr.data = [r, p];
stats = stats.append( current_corr );

figure(1); clf(); hold off;

grp = arr_join( [norm('monkeys', :), norm('doses', :)], '-' );
gscatter( base.data, norm.data, grp, [], 'o' );
xlabel( 'Baseline' ); ylabel( 'Normalized looking' );
hold on;
lim1 = get( gca, 'xlim' );
lim2 = get( gca, 'ylim' );
h = plot( lim1(1):lim1(2), polyval(coeff, lim1(1):lim1(2)), 'r' );
set( h, 'linewidth', 2.5 );

if ( add_text && p < .05 )
  plot( mean(lim1), mean(lim2), 'k*' );
  text( mean(lim1)+100, mean(lim2), sprintf('r: %0.3f, p: %0.3f', r, p) );
end

% plot permuted distribution correlation, per dose
colors = { 'k--', 'm--' };
per_dose_norm = norm.enumerate( 'doses' );
for i = 1:numel(per_dose_norm)
  current_base = base.only( 'group1' ); 
  current_norm = per_dose_norm{i};
  coeff = polyfit( current_base.data, current_norm.data, 1 );
  plot( lim1(1):lim1(2), polyval(coeff, lim1(1):lim1(2)), colors{i} );
  [r, p] = corr( current_base.data, current_norm.data );
  extr = current_norm.one();
  extr.data = [r, p];
  stats = stats.append( extr );
end

% overlay real data points
real_base = dists.only( {'baseline', 'permuted__false'} );
real_norm = dists.only( {'normalized', 'permuted__false'} );
real_norm = real_norm.each1d( 'monkeys', @rowops.mean );
real_base = Container.concat( real_base.enumerate({'monkeys', 'doses'}) );
real_norm = Container.concat( real_norm.enumerate({'monkeys', 'doses'}) );

assert( eq_ignoring(real_base.labels, real_norm.labels, fs) );

grp = arr_join( [real_norm('monkeys', :), real_norm('doses', :)], '-' );

% scatter( real_base.data, real_norm.data, 'r' );
h = gscatter( real_base.data, real_norm.data, grp );
set( h, 'markersize', 25 );

real_coeff = polyfit( real_base.data, real_norm.data, 1 );
h = plot( lim1(1):lim1(2), polyval(real_coeff, lim1(1):lim1(2)), 'r' );
set( h, 'linewidth', 2.5 );

% overlay real fit lines, per dose
colors = { 'k', 'm' };
per_dose_norm = real_norm.enumerate( 'doses' );
for i = 1:numel(per_dose_norm)
  current_base = real_base.only( 'group1' );
  current_norm = per_dose_norm{i};
  coeff = polyfit( current_base.data, current_norm.data, 1 );
  plot( lim1(1):lim1(2), polyval(coeff, lim1(1):lim1(2)), colors{i} );
  [r, p] = corr( current_base.data, current_norm.data );
  extr = current_norm.one();
  extr.data = [r, p];
  stats = stats.append( extr );
end

ylim( [0, 2] );

if ( do_save )
  x_lims = { [0, 3.5e3], [800, 3.3e3] };

  for i = 1:2
    xlim( x_lims{i} );
    x_lims_str = strjoin( arrayfun(@num2str, x_lims{i}, 'un', false), '_' );

    saveas( gcf, fullfile(save_dir, [fname, x_lims_str]), 'epsc' );
    saveas( gcf, fullfile(save_dir, [fname, x_lims_str]), 'png' );
    saveas( gcf, fullfile(save_dir, [fname, x_lims_str]), 'fig' );
  end
end
%   table display
rs = stats.add_field( 'stat', 'r' );
ps = stats.add_field( 'stat', 'p' );
rs.data = rs.data(:, 1); ps.data = ps.data(:, 2);
stats2 = [rs; ps];
stats2.table( {'doses', 'permuted'}, 'stat' )

%%

figure(2);

plt = norm;
plt = make_ud( plt );

pl = ContainerPlotter();
pl.params.error_function = @std;

plt.bar( 'monkeys', 'doses' )




