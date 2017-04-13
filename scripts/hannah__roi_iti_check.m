em_ = em;
em_ = hannah__bin_within_bounds( em_, 50 );
prop = em_.do_per( {'monkeys', 'images', 'doses'} ...
  , @hannah__relative_proportion_within_bounds, 0:2 );
%%
prop_ = prop;

eyes = prop_.only( 'eyes' );
mouth = prop_.only( 'mouth' );

% eyes( 'rois' ) = 'eye_over_mouth';
% mouth( 'rois' ) = 'eye_over_mouth';

% eyes = mouth ./ (eyes + mouth);

% nans = isnan( eyes.data );
% eyes.data( nans ) = 0;

sal = mouth.only( 'saline' );
low = mouth.only( 'low' );
high = mouth.only( 'high' );

high.data = high.data - sal.data;
low.data = low.data - sal.data;

prop_ = low.append( high );

% prop_.data = (1 - prop_.data) * 100;

% prop_ = mouth;
% prop_.data = 1 - prop_.data;

%%

pl.default();
pl.x = 0+.05:.05:5;
pl.y_lim = [-.2 .2];
% pl.shape = [ 2 2 ];
pl.add_ribbon = true;
pl.order_by = { 'saline', 'low', 'high' };
pl.plot( prop_.only('mouth'), 'doses', {'monkeys', 'rois'} );

%%

prop = prop__iti;
prop = prop.do_per( {'monkeys', 'doses'}, @mean );
prop.data = std( prop.data, [], 2 );
% prop.data = mean( prop.data, 2 );
