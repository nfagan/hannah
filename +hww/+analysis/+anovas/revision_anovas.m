function results = revision_anovas()

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

%%  raw -- show null results

meaned = img_looks;
meaned = meaned.do( {'sessions'}, @mean );
groups = { 'doses' };
result = anovas.anovan( meaned, groups );

result = Container( result, 'type', 'raw', 'images', 'all__images' ....
  , 'rois', 'image', 'measure', 'lookdur', 'gazes', 'all__gazes' );
results = results.append( result );

%%  mag change from saline

mag_meaned = img_mag;
mag_meaned = mag_meaned.do( {'sessions'}, @mean );
groups = { 'doses' };
result = anovas.anovan( mag_meaned, groups );

result = Container( result, 'type', 'mag_change', 'images', 'all__images' ...
  , 'rois', 'image', 'measure', 'lookdur', 'gazes', 'all__gazes' );
results = results.append( result );

%%  raw social vs. nonsocial

meaned = img_looks;
meaned = make_snc( meaned );
meaned = meaned.do( {'sessions', 'images'}, @mean );
groups = { 'doses', 'images' };

result = anovas.anovan( meaned, groups );
result = Container( result, 'type', 'raw', 'images', 'social_nonsocial' ...
  , 'rois', 'image', 'measure', 'lookdur', 'gazes', 'all__gazes' );
results = results.append( result );

%%  mag change social vs. nonsocial

mag_meaned = img_mag;
mag_meaned = make_snc( mag_meaned );
mag_meaned = mag_meaned.do( {'sessions', 'images'}, @mean );
groups = { 'doses', 'images' };

result = anovas.anovan( mag_meaned, groups );
result = Container( result, 'type', 'mag_change', 'images', 'social_nonsocial' ...
  , 'rois', 'image', 'measure', 'lookdur', 'gazes', 'all__gazes' );
results = results.append( result );

%%  social only, mag change

mag_meaned = img_mag;
mag_meaned = make_snc( mag_meaned );
mag_meaned = mag_meaned.remove( 'nonsocial' );
mag_meaned = mag_meaned.do( {'sessions', 'gazes', 'expressions'}, @mean );
groups = { 'doses', 'gazes', 'expressions' };

result = anovas.anovan( mag_meaned, groups );
result = Container( result, 'type', 'mag_change', 'images', 'social' ...
  , 'rois', 'image', 'measure', 'lookdur', 'gazes', 'all__gazes' );
results = results.append( result );

%%  social only, raw

meaned = img_looks;
meaned = make_snc( meaned );
meaned = meaned.remove( 'nonsocial' );
meaned = meaned.do( {'sessions', 'gazes', 'expressions'}, @mean );
groups = { 'doses', 'gazes', 'expressions' };

result = anovas.anovan( meaned, groups );
result = Container( result, 'type', 'raw', 'images', 'social' ...
  , 'rois', 'image', 'measure', 'lookdur', 'gazes', 'all__gazes' );
results = results.append( result );

%%  eye mouth proportion -- raw

em_meaned = em_prop;
em_meaned = em_meaned.do( {'sessions', 'rois'}, @mean );
groups = { 'doses' };

per_roi = em_meaned.enumerate( 'rois' );
for i = 1:numel(per_roi)
  roi = per_roi{i}('rois');
  result = anovas.anovan( per_roi{i}, groups );
  result = Container( result, 'type', 'raw', 'images', 'all__images' ...
    , 'rois', roi, 'measure', 'proportion', 'gazes', 'all__gazes' );
  results = results.append( result );
end

%%  eye mouth proportion -- mag change

mag_meaned = em_mag;
mag_meaned = mag_meaned.do( {'sessions', 'rois'}, @mean );

groups = { 'doses' };

per_roi = mag_meaned.enumerate( 'rois' );
for i = 1:numel(per_roi)
  roi = per_roi{i}('rois');
  result = anovas.anovan( per_roi{i}, groups );
  result = Container( result, 'type', 'mag_change', 'images', 'all__images' ...
    , 'rois', roi, 'measure', 'proportion', 'gazes', 'all__gazes' );
  results = results.append( result );
end

%%  eye mouth proportion -- raw; full model

em_meaned = em_prop;
em_meaned = em_meaned.do( {'sessions', 'rois', 'gazes', 'expressions'}, @mean );
groups = { 'doses', 'gazes', 'expressions' };

per_roi = em_meaned.enumerate( 'rois' );
for i = 1:numel(per_roi)
  roi = per_roi{i}('rois');
  result = anovas.anovan( per_roi{i}, groups );
  result = Container( result, 'type', 'raw', 'images', 'all__images' ...
    , 'rois', roi, 'measure', 'proportion', 'gazes', 'direct_vs_inverted' );
  results = results.append( result );
end

%%  eye mouth proportion -- mag change; full model

mag_meaned = em_mag;
mag_meaned = mag_meaned.do( {'sessions', 'rois', 'gazes', 'expressions'}, @mean );
groups = { 'doses', 'gazes', 'expressions' };

per_roi = mag_meaned.enumerate( 'rois' );
for i = 1:numel(per_roi)
  roi = per_roi{i}('rois');
  result = anovas.anovan( per_roi{i}, groups );
  result = Container( result, 'type', 'mag_change', 'images', 'all__images' ...
    , 'rois', roi, 'measure', 'proportion', 'gazes', 'direct_vs_inverted' );
  results = results.append( result );
end

results = results.sparse();

end