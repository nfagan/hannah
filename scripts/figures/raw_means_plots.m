%%  raw mean plots

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
savepath = fullfile( pathfor('plots'), '040717', 'raw' );

pl = ContainerPlotter();

%%  per monkey, collapsed images

per_monk = looks;
per_monk = per_monk.collapse( 'images' );
per_monk = per_monk.do_per( {'sessions'}, @mean );

pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.bar( per_monk, 'doses', 'images', 'monkeys' );

filename = sprintf( 'per_monk_collapsed_images_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  up v. down, collapsed images

up_down = looks;
up_down = up_down.collapse( 'images' );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'sessions'}, @mean );

pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.bar( up_down, 'doses', 'images', 'monkeys' );

filename = sprintf( 'ud_collapsed_images_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );
%%  per monkey, faces / scr / outdoors

per_monk = looks;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );

per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

pl.default();
% pl.y_lim = [0 4.5e3];
pl.y_lim = [];
pl.order_by = { 'scrambled', 'outdoors', 'social' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.order_panels_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.bar( per_monk, 'images', 'doses', 'monkeys' );

filename = sprintf( 'per_monk_scr_out_face_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  up v. down, faces / scr / outdoors

up_down = looks;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'sessions', 'images'}, @mean );

figure;
pl.default();
pl.order_by = { 'scrambled', 'outdoors', 'social' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down, 'images', 'doses', 'monkeys' );

filename = sprintf( 'ud_scr_out_face_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  per monkey, soc / nosoc

per_monk = looks;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );
per_monk = per_monk.replace( {'outdoors', 'scrambled'}, 'nonsocial' );

per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

pl.default();
pl.order_by = { 'social', 'nonsocial' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( per_monk, 'images', 'doses', 'monkeys' );

filename = sprintf( 'per_monk_soc_nonsoc_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  up v. down, soc / nonsoc

up_down = looks;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = up_down.replace( {'outdoors', 'scrambled'}, 'nonsocial' );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'sessions', 'images'}, @mean );

figure;
pl.default();
pl.order_by = { 'social', 'nonsocial' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down, 'images', 'doses', 'monkeys' );

filename = sprintf( 'ud_soc_nonsoc_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );