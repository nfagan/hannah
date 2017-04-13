%%  raw means

filename = 'sparse_measures_outliersremoved.mat';
measures_path = fullfile( pathfor('processedImageData'), '110716', filename );
load( measures_path );
looks = measures.lookdur;
looks = looks.only( 'image' );

means = struct();

%%  per monkey, collapsed images

per_monk = looks;
per_monk = per_monk.collapse( 'images' );
per_monk = per_monk.do_per( {'monkeys', 'doses'}, @mean );

means.per_monk_collapsed_images = per_monk;

%%  up v. down, collapsed images

up_down = looks;
up_down = up_down.collapse( 'images' );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'monkeys', 'doses'}, @mean );

means.up_down_collapsed_images = up_down;

%%  per monkey, faces / scr / outdoors

per_monk = looks;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );

per_monk = per_monk.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.per_monk_out_scr_soc = per_monk;

%%  up v. down, faces / scr / outdoors

up_down = looks;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.up_down_out_scr_soc = up_down;

%%  per monkey, soc / nosoc

per_monk = looks;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );
per_monk = per_monk.replace( {'outdoors', 'scrambled'}, 'nonsocial' );

per_monk = per_monk.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.per_monk_soc_nonsoc = per_monk;

%%  up v. down, soc / nonsoc

up_down = looks;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = up_down.replace( {'outdoors', 'scrambled'}, 'nonsocial' );

up_down = up_down.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.up_down_soc_nonsoc = up_down;
