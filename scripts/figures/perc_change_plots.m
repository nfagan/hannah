%%  percent change means
filename = 'sparse_measures_outliersremoved.mat';
measures_path = fullfile( pathfor('processedImageData'), '110716', filename );
load( measures_path );

% - measure type
measure_type = 'lookdur';
looks = measures.( measure_type );

% - roi
looks = looks.only( 'image' );

% - savepath
savepath = fullfile( pathfor('plots'), '091417', measure_type, 'percent_change' );
if ( exist(savepath, 'dir') ~= 7 ), mkdir(savepath); end;

means = struct();
pl = ContainerPlotter();
%%  normalize, per session, per image

normed = hww.process.saline_normalize( looks );
normed.data = (normed.data-1)*100;

%%  mag change per expression, social images only

plt = normed;
plt = cat_collapse( plt, {'gender'} );
plt = plt.rm( {'outdoors', 'scrambled'} );

figure;
pl.default();
pl.order_groups_by = { 'low', 'high' };
pl.order_by = { 'uadt', 'uads', 'uadl', 'uadn', 'uait', 'uais', 'uail', 'uain' };
pl.order_panels_by = { 'ephron', 'tarantino', 'kubrick', 'hitch', 'cron', 'lager' };
pl.y_lim = [];

pl.bar( plt.rm('saline'), 'images', 'doses', 'monkeys' );

% pl.order_groups_by = { 'low', 'high' };
% pl.bar( up_down.rm('saline'), 'images', 'doses', 'monkeys' );

% filename = sprintf( 'ud_exp_gaze_%s', measure_type );
% saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  bidirect expression / gaze

up_down = normed;
up_down = make_ud( up_down );
up_down = up_down.rm( {'outdoors', 'scrambled'} );
up_down = cat_collapse( up_down, {'gender'} );

figure;
pl.default();
pl.y_lim = [-50 90];
pl.order_groups_by = { 'low', 'high' };
pl.bar( up_down.rm('saline'), 'images', 'doses', 'monkeys' );

filename = sprintf( 'ud_exp_gaze_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );
%%  bidirect figure

per_monk = normed;
per_monk = per_monk.collapse( 'images' );

per_monk = per_monk.do_per( {'sessions'}, @mean );

means.bidirect = per_monk;

figure;
pl.default();
pl.order_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.order_groups_by = { 'low', 'high' };
pl.bar( per_monk.rm('saline'), 'monkeys', 'doses', 'rois' );

%%  per monk, collapsed images

per_monk = normed;
per_monk = per_monk.collapse( 'images' );

per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

means.per_monk_collapsed = per_monk;

figure;
pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.bar( per_monk.rm('saline'), 'doses', 'images', 'monkeys' );

filename = sprintf( 'per_monk_collapsed_images_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  mag change, collapsed images

mag_change = hww.process.add_ud( normed );
mag_change = mag_change.rm( 'saline' );
mag_change.data = abs( mag_change.data );
mag_change = mag_change.each1d( 'sessions', @rowops.mean );

figure(1); clf();
pl.default();
pl.y_lim = [ 0, 90 ];
pl.order_by = { 'low', 'high' };
pl.bar( mag_change, 'doses', 'images', 'images' );

%   add points

xs_labs = { 'low', 'high' };
g_labs = { 'all__images' };
p_labs = { 'all__images' };

C = allcomb( {xs_labs, g_labs, p_labs} );

axs = findobj( figure(1), 'type', 'axes' );
set( axs, 'NextPlot', 'add' );

colors = hww.plot.util.get_monkey_colors();

for i = 1:size(C, 1)
  
  x_lab = C{i, 1};
  g_lab = C{i, 2};
  p_lab = C{i, 3};
  
  ax_ind = numel(axs) - find(strcmp(p_labs, p_lab)) + 1;
  
  x = find( strcmp(xs_labs, x_lab) );
  subset = mag_change.only( C(i, :) );
  subset = subset.each1d( {'monkeys', 'images'}, @rowops.mean );
  
  data = subset.data;
  
  for k = 1:numel(data)
    color = colors.(char(subset('monkeys', k)));
    plot( axs(ax_ind), x, data(k), sprintf('%s*', color) );
  end
  
end

filename = sprintf( 'mag_change_collapsed_images_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  up v. down, collapsed images

up_down = normed;
up_down = up_down.collapse( 'images' );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'sessions', 'images'}, @mean );

means.up_down_collapsed = up_down;

pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.bar( up_down.rm('saline'), 'doses', 'images', 'monkeys' );

filename = sprintf( 'ud_collapsed_images_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );
%%  per monk, scr / out / face

per_monk = normed;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );

per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

means.per_monk_sof = per_monk;

pl.default();
% pl.y_lim = [-50 105];
% pl.y_lim = [-50 90];
pl.order_by = { 'scrambled', 'outdoors', 'social' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.order_panels_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.bar( per_monk.rm('saline'), 'images', 'doses', 'monkeys' );

filename = sprintf( 'per_monk_scr_out_face_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );
%%  up v. down, scr / out / face

up_down = normed;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'sessions', 'images'}, @mean );

means.up_down_sof = up_down;

figure;
pl.default();
% pl.y_lim = [-40 70];
% pl.y_lim = [-40 60];
pl.order_by = { 'scrambled', 'outdoors', 'social' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down.rm('saline'), 'images', 'doses', 'monkeys' );

filename = sprintf( 'ud_scr_out_face_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  per monk, scr / out / per expression

per_monk = normed;
per_monk = cat_collapse( per_monk, {'gender'} );

per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

means.per_monk_sof = per_monk;

pl.default();
pl.order_by = { 'scrambled', 'outdoors' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.order_panels_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.bar( per_monk.rm('saline'), 'images', 'doses', 'monkeys' );

filename = sprintf( 'per_monk_scr_out_per_exp_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  up v. down, scr / out / per expression

up_down = normed;
up_down = cat_collapse( up_down, {'gender'} );
up_down = make_ud( up_down );
up_down = up_down.do_per( {'sessions', 'images'}, @mean );

means.up_down_sof = up_down;

figure;
pl.default();
pl.order_by = { 'scrambled', 'outdoors' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down.rm('saline'), 'images', 'doses', 'monkeys' );

filename = sprintf( 'ud_scr_out_per_exp_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  per monk, soc / nosocial

per_monk = normed;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );
per_monk = per_monk.replace( {'outdoors', 'scrambled'}, 'nonsocial' );

per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

means.per_monk_snc = per_monk;

pl.default();
pl.order_by = { 'social', 'nonsocial' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( per_monk.rm('saline'), 'images', 'doses', 'monkeys' );

filename = sprintf( 'per_monk_soc_nonsoc_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );
%%  up v. down, soc / nonsocial

filename = sprintf( 'ud_soc_nonsoc_%s', measure_type );
soc_points_filename = sprintf( 'ud_soc_nonsoc_points_social_%s', measure_type );
nsoc_points_filename = sprintf( 'ud_soc_nonsoc_points_nonsocial_%s', measure_type );

mean_func = @Container.mean_1d;

up_down = normed;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = up_down.replace( {'outdoors', 'scrambled'}, 'nonsocial' );
up_down = up_down.for_each_1d( {'sessions', 'images'}, mean_func );
up_down = hww.process.add_ud( up_down );

means.up_down_snc = up_down;

figure(1); clf();
pl.default();
pl.y_lim = [-40 100];
pl.x_tick_rotation = 0;
pl.order_by = { 'social', 'nonsocial' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down.rm('saline'), 'images', 'doses', 'monk_group' );
% saveas( gcf, fullfile(savepath, filename), 'epsc' );

%   add points

xs_labs = { 'social', 'nonsocial' };
g_labs = { 'low', 'high' };
p_labs = { 'monk_group__up', 'monk_group__down' };

C = allcomb( {xs_labs, g_labs, p_labs} );

axs = findobj( figure(1), 'type', 'axes' );
set( axs, 'NextPlot', 'add' );

colors = hww.plot.util.get_monkey_colors();

for i = 1:size(C, 1)
  
  x_lab = C{i, 1};
  g_lab = C{i, 2};
  p_lab = C{i, 3};
  
  ax_ind = numel(axs) - find(strcmp(p_labs, p_lab)) + 1;
  
  x_coord = find( strcmp(xs_labs, x_lab) );
  subset = up_down.only( C(i, :) );
  subset = subset.for_each_1d( {'monkeys', 'images'}, mean_func );
  
  offsets = -1/numel(g_labs):1/numel(g_labs):1/numel(g_labs);
  
  g_offset = find( strcmp(g_labs, g_lab) );
  
  x = x_coord + offsets( g_offset );
  
  data = subset.data;
  
  for k = 1:numel(data)
    color = colors.(char(subset('monkeys', k)));
    plot( axs(ax_ind), x, data(k), sprintf('%s*', color) );
  end
  
end

saveas( gcf, fullfile(savepath, filename), 'epsc' );
