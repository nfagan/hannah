%%  percent change means
filename = 'sparse_measures_outliersremoved.mat';
measures_path = fullfile( pathfor('processedImageData'), '110716', filename );
load( measures_path );
looks = measures.lookdur;
looks = looks.only( 'image' );
means = struct();

%%  normalize, per session, per image

normed = saline_normalize( looks );

%%  per monk, collapsed images

per_monk = normed;
per_monk = per_monk.collapse( 'images' );

per_monk = per_monk.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.per_monk_collapsed = per_monk;

%%  up v. down, collapsed images

up_down = normed;
up_down = up_down.collapse( 'images' );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.up_down_collapsed = up_down;

%%  per monk, scr / out / face

per_monk = normed;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );

per_monk = per_monk.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.per_monk_sof = per_monk;

%%  up v. down, scr / out / face

up_down = normed;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.up_down_sof = up_down;

%%  per monk, soc / nosocial

per_monk = normed;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );
per_monk = per_monk.replace( {'outdoors', 'scrambled'}, 'nonsocial' );

per_monk = per_monk.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.per_monk_snc = per_monk;

%%  up v. down, soc / nonsocial

up_down = normed;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = make_ud( up_down );
up_down = up_down.replace( {'outdoors', 'scrambled'}, 'nonsocial' );

up_down = up_down.do_per( {'monkeys', 'doses', 'images'}, @mean );

means.up_down_snc = up_down;


