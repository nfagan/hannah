function results = run_nested_anova()

import hww.analysis.*

img_looks = hww.io.load_sparse_measures( 'lookdur' );
img_looks = img_looks.only( 'image' );
em_prop = hww.io.load_eye_mouth_bounds();
em_prop = em_prop.mean( 2 );
em_prop = em_prop.only( {'eyes', 'mouth'} );

results = Container();

%%  normalize

img_normed = saline_normalize( img_looks );
em_normed = em_prop.do( 'rois', @saline_normalize );
em_normed = em_normed.keep( ~isnan(em_normed.data) & ~isinf(em_normed.data) );

%%  mag change

img_mag = img_normed;
img_mag.data = abs( img_mag.data - 1 );
em_mag = em_normed;
em_mag.data = abs( em_mag.data - 1 );

%%  raw -- nested

meaned = img_looks;
out_ind = meaned.where( 'outdoors' );
scr_ind = meaned.where( 'scrambled' );
meaned = make_snc( meaned );
meaned( 'gazes', out_ind ) = 'gaze__outdoors';
meaned( 'gazes', scr_ind ) = 'gaze__scrambled';
meaned = meaned.do( {'sessions', 'images', 'gazes', 'expressions'}, @mean );
groups = { 'doses', 'images', 'gazes', 'expressions' };

nesting = [ 
    0, 0, 0, 0;
    1, 0, 0, 0;
    1, 1, 0, 0;
    1, 1, 1, 0;
];

result = anovas.anovan_nested( meaned, groups, nesting );

result = Container( result, 'type', 'raw', 'images', 'social_nonsocial' ...
  , 'rois', 'image', 'measure', 'lookdur' );
results = results.append( result );

%%  mag change from saline -- nested

mag_meaned = img_mag;
out_ind = mag_meaned.where( 'outdoors' );
scr_ind = mag_meaned.where( 'scrambled' );
mag_meaned = make_sns( mag_meaned );
mag_meaned( 'gazes', out_ind ) = 'gaze__outdoors';
mag_meaned( 'gazes', scr_ind ) = 'gaze__scrambled';
mag_meaned = mag_meaned.do( {'sessions', 'images', 'gazes', 'expressions'}, @mean );
groups = { 'doses', 'images', 'gazes', 'expressions' };

nesting = [ 
    0, 0, 0, 0;
    1, 0, 0, 0;
    1, 1, 0, 0;
    1, 1, 1, 0;
];

result = anovas.anovan( mag_meaned, groups, nesting );

result = Container( result, 'type', 'mag_change', 'images', 'social_nonsocial' ...
  , 'rois', 'image', 'measure', 'lookdur' );
results = results.append( result );

%%  eye mouth proportion -- raw

em_meaned = em_prop;
em_meaned = em_meaned.do( {'sessions', 'rois', 'gazes', 'expressions'}, @mean );
groups = { 'doses', 'gazes', 'expressions' };

nesting = [ 
  0, 0, 0;
  1, 0, 0;
  1, 1, 0;
];

per_roi = em_meaned.enumerate( 'rois' );
for i = 1:numel(per_roi)
  roi = per_roi{i}('rois');
  result = anovas.anovan_nested( per_roi{i}, groups, nesting );
  result = Container( result, 'type', 'raw', 'images', 'all__images' ...
    , 'rois', roi, 'measure', 'proportion' );
  results = results.append( result );
end

%%  eye mouth proportion -- mag change

mag_meaned = em_mag;
mag_meaned = mag_meaned.do( {'sessions', 'rois', 'gazes', 'expressions'}, @mean );

groups = { 'doses', 'gazes', 'expressions' };

nesting = [ 
  0, 0, 0;
  1, 0, 0;
  1, 1, 0;
];

per_roi = mag_meaned.enumerate( 'rois' );
for i = 1:numel(per_roi)
  roi = per_roi{i}('rois');
  result = anovas.anovan_nested( per_roi{i}, groups, nesting );
  result = Container( result, 'type', 'mag_change', 'images', 'all__images' ...
    , 'rois', roi, 'measure', 'proportion' );
  results = results.append( result );
end

results = results.sparse();


end