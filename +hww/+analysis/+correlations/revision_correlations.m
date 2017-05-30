function results = revision_correlations()

em_prop = hww.io.load_eye_mouth_bounds();
em_prop = em_prop.mean( 2 );
em_prop = em_prop.only( {'eyes', 'mouth'} );

results = Container();

%%  normalize

em_normed = em_prop.do( 'rois', @saline_normalize );

%%  mag change

em_mag = em_normed;
em_mag.data = abs( em_mag.data - 1 );

%%  per roi, correlation b/w mag + raw

% normed_mag = 

end