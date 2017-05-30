%%  percent change means
filename = 'sparse_measures_outliersremoved.mat';
measures_path = fullfile( pathfor('processedImageData'), '110716', filename );
load( measures_path );

% - measure type
measure_type = 'nfix';
looks = measures.( measure_type );

% - roi
looks = looks.only( 'image' );

% - savepath
savepath = fullfile( pathfor('plots'), '041917', measure_type, 'percent_change' );
if ( exist(savepath, 'dir') ~= 7 ), mkdir(savepath); end;

means = struct();
pl = ContainerPlotter();
%%  normalize, per session, per image

normed = saline_normalize( looks );
normed.data = (normed.data-1)*100;

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

up_down = normed;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = make_ud( up_down );
up_down = up_down.replace( {'outdoors', 'scrambled'}, 'nonsocial' );

up_down = up_down.do_per( {'sessions', 'images'}, @mean );

means.up_down_snc = up_down;

figure;
pl.default();
pl.y_lim = [-40 70];
pl.order_by = { 'social', 'nonsocial' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down.rm('saline'), 'images', 'doses', 'monkeys' );

filename = sprintf( 'ud_soc_nonsoc_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );