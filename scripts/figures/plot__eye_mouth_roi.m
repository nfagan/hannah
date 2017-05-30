bounds = load( '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/030617/eye_mouth_bounds.mat' );
fs = fieldnames( bounds );
bounds = bounds.( fs{1} );

within_bounds = bounds;
within_bounds = hannah__bin_within_bounds( within_bounds, 50 );
% prop = within_bounds.do_per( {'monkeys', 'images', 'doses'} ...
%   , @hannah__relative_proportion_within_bounds, 0:2 );
prop = within_bounds.do_per( {'sessions', 'images'} ...
  , @hannah__relative_proportion_within_bounds, 0:2 );

prop = prop.rm( 'roi__0' );
prop = prop.replace( 'roi__1', 'eyes' );
prop = prop.replace( 'roi__2', 'mouth' );
prop_orig = prop;

%%
prop = prop_orig;
group1 = { 'ephron', 'kubrick', 'tarantino' };
group2 = { 'lager', 'hitch', 'cron' };

prop = prop.replace( group1, 'upGroup' );
prop = prop.replace( group2, 'downGroup' );

%%  minus sal

low = collapse( prop.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
sal = collapse( prop.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
high = collapse( prop.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

low = low.opc( sal, {'doses', 'images', 'genders', 'gazes', 'expressions'}, @minus ); 
low('doses') = 'lowMinusSal';
high = high.opc( sal, {'doses', 'images', 'genders', 'gazes', 'expressions'}, @minus ); 
high('doses') = 'highMinusSal';
prop = low.append( high );

%%  divide sal
% is_zero = all( prop.data == 0, 2 );
% prop = prop.keep( ~is_zero );
prop = prop.do( {'sessions', 'rois'}, @mean );
low = collapse( prop.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
sal = collapse( prop.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
high = collapse( prop.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

low = low.opc( sal, {'doses', 'images', 'genders', 'gazes', 'expressions'}, @rdivide ); 
low('doses') = 'lowDivideSal';
high = high.opc( sal, {'doses', 'images', 'genders', 'gazes', 'expressions'}, @rdivide ); 
high('doses') = 'highDivideSal';
prop = low.append( high );

torm = any(isinf(prop.data), 2) | any(isnan(prop.data), 2);
% torm = any( isinf(prop.data), 2 );
prop = prop.keep( ~torm );
prop.data = (prop.data-1)*100;

%%

pl = ContainerPlotter();
pl.default();
pl.x = 0:.05:5-.05;
pl.add_ribbon = true;
pl.error_function = @ContainerPlotter.sem_1d;
pl.full_screen = true;
pl.y_lim = [0 .55];
pl.shape = [];
pl.add_legend = true;
pl.order_panels_by = { 'upGroup', 'downGroup' };
pl.order_by = { 'saline', 'low', 'high' };
pl.save_outer_folder = '~/Desktop/hannah_data/051817';

pl.plot_and_save(prop ...
  , {'rois'} ...                                      % files are
  , @plot ...                                         % plotting function
  , 'doses' ...                                       % lines are
  , { 'monkeys'} );                                   % panels are

