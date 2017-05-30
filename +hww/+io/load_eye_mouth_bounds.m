function prop = load_eye_mouth_bounds()

bounds = ...
  load( fullfile(pathfor('processedImageData'), '030617', 'eye_mouth_bounds.mat') );
fs = fieldnames( bounds );
bounds = bounds.( fs{1} );

within_bounds = bounds;
within_bounds = hannah__bin_within_bounds( within_bounds, 50 );
% within_bounds = hannah__bin_within_bounds( within_bounds, 5e3 );
prop = within_bounds.do_per( {'sessions', 'images'} ...
  , @hannah__relative_proportion_within_bounds, 0:2 );

prop = prop.rm( 'roi__0' );
prop = prop.replace( 'roi__1', 'eyes' );
prop = prop.replace( 'roi__2', 'mouth' );

end