within_bounds.data = cell( size(orig_within_bounds.data) );
found = true( size(within_bounds.data) );
for i = 1:numel(rois)
  ind = orig_within_bounds.data == i;
  within_bounds.data( ind ) = rois(i);
  found = found & ~ind;
end

if ( any(found) )
  within_bounds.data( found ) = { 'leftover_roi' };
end

%%
within_bounds = orig_within_bounds;
within_bounds = hannah__bin_within_bounds( within_bounds, 50 );
prop = within_bounds.do_per( {'monkeys', 'images', 'doses'} ...
  , @hannah__relative_proportion_within_bounds, 0:2 );

%%
% prop = orig_prop;

prop = prop.replace( 'roi__0', 'restOfImage' );
prop = prop.replace( 'roi__1', 'eyes' );
prop = prop.replace( 'roi__2', 'mouth' );

%%

prop = prop.remove( 'restOfFace' );
eye_roi = prop.only( 'eyes' );
mouth_roi = prop.only( 'mouth' );
mouth_m_eye = mouth_roi.opc( eye_roi, 'rois', @minus );
mouth_m_eye('rois') = 'mouthMinusEye';
prop = mouth_m_eye;

%%
group1 = { 'ephron', 'kubrick', 'tarantino' };
group2 = { 'lager', 'hitch', 'cron' };

prop = prop.replace( group1, 'upGroup' );
prop = prop.replace( group2, 'downGroup' );

%%  n minus n

binned = pre_image;
ind_out = binned.where( 'outdoors' );
ind_scr = binned.where( 'scrambled' );

binned = binned.add_field( 'preceding_was', '<undf>' );
binned( 'preceding_was', ~(ind_out | ind_scr) ) = 'was_social';
binned( 'preceding_was', ind_out ) = 'was_outdoors';
binned( 'preceding_was', ind_scr ) = 'was_scrambled';

preceding_social = hannah__n_minus_n( binned, 1, 'was_social', [] );
preceding_outdoors = hannah__n_minus_n( binned, 1, 'was_outdoors', [] );
preceding_scrambled = hannah__n_minus_n( binned, 1, 'was_scrambled', [] );

combined = preceding_social.extend( preceding_outdoors, preceding_scrambled );
combined( 'images', ~(combined.where('outdoors') | combined.where('scrambled')) ) = 'social';
combined = combined.do_per( {'monkeys', 'images', 'doses'} ...
  , @hannah__relative_proportion_within_bounds, 0:1 );

combined = combined.replace( 'roi__0', 'restOfFace' );
combined = combined.replace( 'roi__1', 'image' );

% combined = combined.add_field( 'preceding_was', '<undf>' );
% combined.social( 'preceding_was' ) = 'social_image';
% combined.out( 'preceding_was' ) = 'outdoor_image';
% combined.scr( 'preceding_was' ) = 'scrambled_image';

% combined = combined.social.extend( combined.out, combined.scr );
% combined = combined.rm( 'restOfFace' );

%%
within_bounds.data = within_bounds.data(:, 1:500);

firsts = zeros( size(within_bounds.data, 1), 1 );

for i = 1:size( within_bounds.data, 1 )
  to_face = min( find(within_bounds.data(i, :) == 1, 1, 'first') );
  to_eye = min( find(within_bounds.data(i, :) == 2, 1, 'first') );
  if ( isempty(to_face) && isempty(to_eye) )
    continue;
  elseif ( isempty(to_face) )
    firsts(i) = 2;
  else firsts(i) = 1;
  end
end
%%
within_bounds.data = firsts;