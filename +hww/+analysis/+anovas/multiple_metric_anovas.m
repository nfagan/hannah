function results = multiple_metric_anovas()

import hww.analysis.*

% - look dur
img_looks = hww.io.load_sparse_measures( 'lookdur' );
img_looks = img_looks.only( 'image' );

% - number of completed trials
img_ntrials = img_looks;
N = img_ntrials.shape(1);
new_data = ones( N, 1 );
img_ntrials.data = new_data;
img_ntrials = img_ntrials.do( {'sessions'}, @sum );

% - eye vs. mouth proportions
em_prop = hww.io.load_eye_mouth_bounds();
em_prop = em_prop.mean( 2 );
em_prop = em_prop.only( {'eyes', 'mouth'} );

% - iti proportions
iti_bounds = hww.io.load_iti_bounds();
iti_bounds = hannah__bin_within_bounds( iti_bounds, 50 );
iti_prop = iti_bounds.do_per( {'sessions', 'images'} ...
  , @hannah__relative_proportion_within_bounds, 0:1 );
iti_prop = iti_prop.rm( 'roi__0' );
iti_prop = iti_prop.replace( 'roi__1', 'image' );
iti_prop = iti_prop.mean( 2 );

results = Container();

%%  normalize

img_normed = saline_normalize( img_looks );

img_ntrials_normed = saline_normalize( img_ntrials );

iti_normed = saline_normalize( iti_prop );
iti_normed = iti_normed.keep( ~isnan(iti_normed.data) & ~isinf(iti_normed.data) );

% em_normed = cat_collapse( em_prop, 'gender' );
em_normed = em_prop.do( 'rois', @saline_normalize );
em_normed = em_normed.keep( ~isnan(em_normed.data) & ~isinf(em_normed.data) );

%%  mag change

img_mag = img_normed;
img_mag.data = abs( img_mag.data - 1 );

img_ntrials_mag = img_ntrials_normed;
img_ntrials_mag.data = abs( img_ntrials_mag.data - 1 );

em_mag = em_normed;
em_mag.data = abs( em_mag.data - 1 );

iti_mag = iti_normed;
iti_mag.data = abs( iti_mag.data - 1 );

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
  roi = per_roi{i}('rois');pathed
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

%%  iti -- raw

iti_meaned = iti_prop;
iti_meaned = iti_meaned.do( {'sessions'}, @mean );
groups = { 'doses' };

result = anovas.anovan( iti_meaned, groups );
result = Container( result, 'type', 'raw', 'images', 'all__images' ...
  , 'rois', 'image', 'measure', 'iti_proportion', 'gazes', 'all__gazes' );
results = results.append( result );

%%  iti -- mag;

iti_mag_meaned = iti_mag;
iti_mag_meaned = iti_mag_meaned.do( {'sessions'}, @mean );
groups = { 'doses' };

result = anovas.anovan( iti_mag_meaned, groups );
result = Container( result, 'type', 'mag_change', 'images', 'all__images' ...
  , 'rois', 'image', 'measure', 'iti_proportion', 'gazes', 'all__gazes' );
results = results.append( result );

%%  n trials -- raw

ntrials_meaned = img_ntrials;
ntrials_meaned = ntrials_meaned.do( {'sessions'}, @mean );
groups = { 'doses' };

result = anovas.anovan( ntrials_meaned, groups );
result = Container( result, 'type', 'raw', 'images', 'all__images' ...
  , 'rois', 'image', 'measure', 'ntrials', 'gazes', 'all__gazes' );
results = results.append( result );

%%  ntrials -- percent change

ntrials_normed_meaned = img_ntrials_normed;
ntrials_normed_meaned = ntrials_normed_meaned.do( {'sessions'}, @mean );
groups = { 'doses' };

result = anovas.anovan( ntrials_normed_meaned, groups );
result = Container( result, 'type', 'percent_change', 'images', 'all__images' ...
  , 'rois', 'image', 'measure', 'ntrials', 'gazes', 'all__gazes' );
results = results.append( result );

%%  ntrials -- percent change

ntrials_mag_meaned = img_ntrials_mag;
ntrials_mag_meaned = ntrials_mag_meaned.do( {'sessions'}, @mean );
groups = { 'doses' };

result = anovas.anovan( ntrials_mag_meaned, groups );
result = Container( result, 'type', 'mag_change', 'images', 'all__images' ...
  , 'rois', 'image', 'measure', 'ntrials', 'gazes', 'all__gazes' );
results = results.append( result );

results = results.sparse();

end