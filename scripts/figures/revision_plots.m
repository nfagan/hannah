function correlations = revision_plots()

%%  revision plots

% - load
filename = 'sparse_measures_outliersremoved.mat';
measures_path = fullfile( pathfor('processedImageData'), '110716', filename );
load( measures_path );

% - measure type
measure_type = 'lookdur';
looks = measures.( measure_type );

% - roi
looks = looks.only( 'image' );

% - savepath
savepath = fullfile( pathfor('plots'), '051817', measure_type, 'raw' );
if ( exist(savepath, 'dir') ~= 7 ), mkdir(savepath); end;

pl = ContainerPlotter();

%%

normed = saline_normalize( looks );
normed.data = (normed.data-1)*100;

%%  per monkey, collapsed images, line plots

per_monk = looks;
per_monk = per_monk.collapse( 'images' );
per_monk = per_monk.do_per( {'sessions'}, @mean );

pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.y_lim = [0 3.5e3];
pl.add_ribbon = false;
pl.plot_by( per_monk, 'doses', 'monkeys', 'images' );

filename = sprintf( 'per_monk_collapsed_images_lines_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  per monkey, social minus nonsocial, line plots

per_monk = looks;
per_monk = make_snc( per_monk );
per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );
plt = soc_minus_non_fnc( per_monk, 'doses' );

pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.y_lim = [];
pl.add_ribbon = false;
pl.y_label = plt('images');
pl.plot_by( plt, 'doses', 'monkeys', 'images' );

filename = sprintf( 'per_monk_social_minus_nonsocial_lines_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  per monkey, percent change social minus nonsocial, line plots

per_monk = normed.rm( 'saline' );
per_monk = make_snc( per_monk );
per_monk = per_monk.keep( ~isnan(per_monk.data) & ~isinf(per_monk.data) );
per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );
plt = soc_minus_non_fnc( per_monk, 'doses' );

pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.y_lim = [];
pl.add_ribbon = false;
pl.y_label = plt('images');
pl.plot_by( plt, 'doses', 'monkeys', 'images' );

filename = sprintf( 'per_monk_social_minus_nonsocial_from_saline_lines_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  scatter plot, raw soc-nonsoc saline vs. percent change soc-nonsoc

normed1 = normed.rm( 'saline' );
normed1 = make_snc( normed1 );
normed1 = normed1.do_per( {'sessions', 'images'}, @mean );
normed1 = soc_minus_non_fnc( normed1, 'doses' );

raw1 = looks;
raw1 = make_snc( raw1 );
raw1 = raw1.do_per( {'sessions', 'images'}, @mean );
raw1 = soc_minus_non_fnc( raw1, 'doses' );

scatter_x1 = raw1.only( 'saline' );
scatter_x1('doses') = 'low';
scatter_x2 = raw1.only( 'saline' );
scatter_x2('doses') = 'high';
scatter_x = scatter_x1.append( scatter_x2 );

scatter_y = append( normed1.only('low'), normed1.only('high') );

X = scatter_x.do( {'monkeys', 'doses', 'images'}, @mean );
Y = scatter_y.do( {'monkeys', 'doses', 'images'}, @mean );
%%

pl.default();
pl.marker_size = 40;
pl.x_lim = [-600 1500];
pl.y_lim = [-40 40];
pl.x_label = 'Raw saline social minus nonsocial';
pl.y_label = 'Percent change from saline social minus nonsocial';

pl.scatter( X, Y, 'images', [] );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'with_line', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

pl.scatter( X, Y, {'monkeys', 'doses'}, [] );

filename = sprintf( 'raw_vs_perc_change_scatter_%s_%s', 'without_line', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

[r, p] = corr( X.data, Y.data );

[x_dose, ~, doses] = X.enumerate('doses');
y_dose = Y.enumerate('doses');

rs = zeros( size(x_dose) );
ps = zeros( size(x_dose) );

for i = 1:numel(x_dose)
  [rs(i), ps(i)] = corr( x_dose{i}.data, y_dose{i}.data );
end

correlations = struct();
correlations.across_doses = struct( 'r', r, 'p', p );
correlations.per_dose.r = rs;
correlations.per_dose.p = ps;
correlations.per_dose.doses = doses;

correlations = Container( correlations, 'kind', 'raw_saline_vs_percent_change_soc_minus_nonsoc' );
correlations = correlations.sparse();

end
