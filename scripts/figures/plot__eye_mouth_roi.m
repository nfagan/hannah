bounds = load( '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/030617/eye_mouth_bounds.mat' );
fs = fieldnames( bounds );
bounds = bounds.( fs{1} );

within_bounds = bounds;
within_bounds = hannah__bin_within_bounds( within_bounds, 50 );
prop = within_bounds.do_per( {'monkeys', 'images', 'doses'} ...
  , @hannah__relative_proportion_within_bounds, 0:2 );

prop = prop.rm( 'roi__0' );
prop = prop.replace( 'roi__1', 'eyes' );
prop = prop.replace( 'roi__2', 'mouth' );

%%
group1 = { 'ephron', 'kubrick', 'tarantino' };
group2 = { 'lager', 'hitch', 'cron' };

prop = prop.replace( group1, 'upGroup' );
prop = prop.replace( group2, 'downGroup' );

%%  minus sal

low = collapse( prop.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
sal = collapse( prop.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
high = collapse( prop.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

low = low.opc( sal, 'doses', @minus ); 
low('doses') = 'lowMinusSal';
high = high.opc( sal, 'doses', @minus ); 
high('doses') = 'highMinusSal';
prop = low.append( high );

%%  divide sal

low = collapse( prop.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
sal = collapse( prop.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
high = collapse( prop.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

low = low.opc( sal, 'doses', @rdivide ); 
low('doses') = 'lowMinusSal';
high = high.opc( sal, 'doses', @rdivide ); 
high('doses') = 'highMinusSal';
prop = low.append( high );

prop.data = (prop.data-1)*100;

%%

pl = ContainerPlotter();
pl.default();
pl.x = 0:.05:5-.05;
pl.add_ribbon = true;
pl.error_function = @ContainerPlotter.sem_1d;
pl.full_screen = true;
pl.y_lim = [-.2 .2];
pl.shape = [];
pl.add_legend = true;
pl.order_panels_by = { 'upGroup', 'downGroup' };
pl.order_by = { 'saline', 'low', 'high' };
pl.save_outer_folder = cd;

pl.plot_and_save(prop ...
  , {'rois'} ...                                      % files are
  , @plot ...                                         % plotting function
  , 'doses' ...                                       % lines are
  , { 'monkeys'} );                                   % panels are

