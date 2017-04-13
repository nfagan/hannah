rois = { 'eyes', 'mouth' };
% rois = { 'image' };
% rois = { 'image' };
x_calc = x.rm( {'scrambled', 'outdoors'} );
y_calc = y.rm( {'scrambled', 'outdoors'} );
bounds = hannah__mark_within_bounds( x_calc, y_calc, rois, 'or' );
%%
% prop = within_bounds.do_per( {'monkeys', 'images', 'doses', 'rois'}, @hannah__proportion_in_bounds );
% prop = within_bounds.do_per( {'images', 'sessions', 'rois'}, @hannah__proportion_in_bounds );
prop = em.do_per( {'monkeys', 'images', 'doses'}, @hannah__relative_proportion_within_bounds, 0:2 );
% prop = prop.do_per( {'monkeys', 'doses', 'rois'}, @mean );

%%
prop = cat_collapse( prop, {'gender'} );

prop = prop.replace( 'expressions__s', 'submissive' );
prop = prop.replace( 'expressions__n', 'neutral' );
prop = prop.replace( 'expressions__t', 'threat' );
prop = prop.replace( 'expressions__l', 'lipsmack' );
prop = prop.replace( 'gazes__direct', 'direct' );
prop = prop.replace( 'gazes__indirect', 'indirect' );

%%

low = collapse( prop.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
sal = collapse( prop.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
high = collapse( prop.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

low = low.opc( sal, 'doses', @minus ); low('doses') = 'lowMinusSal';
high = high.opc( sal, 'doses', @minus ); high('doses') = 'highMinusSal';
prop_subbed = low.append( high );
%%
pl.default();
pl.x = 0:.05:5-.05;
% pl.x = 0:.001:5-.001;
% pl.x = -1.5+.05:.05:0;
% pl.x = -2+.05:.05:.2;
pl.add_ribbon = true;
pl.error_function = @ContainerPlotter.sem_1d;
pl.full_screen = true;
% pl.y_lim = [-.1 1.1];
pl.y_lim = [];
pl.set_colors = 'auto';
pl.colors = { 'purple', 'orange', 'green' };
pl.shape = [1 2];
pl.add_legend = true;
pl.order_panels_by = { 'saline', 'low', 'high' };
pl.order_by = { 'saline', 'low', 'high' };
% pl.save_outer_folder = fullfile( pathfor('plots'), '030117' ...
%   , 'roi_order', 'iti_image_2500' );
pl.save_outer_folder = cd;

pl.plot_and_save(prop ...
  , {'gazes'} ...                                     % files are
  , @plot ...                                         % plotting function
  , 'doses' ...                                       % lines are
  , { 'gazes', 'rois', 'monkeys'} );                  % panels are

%%
pl.default();
% pl.params.order_panels_by = { 'eyes', 'mouth' };
% pl.params.order_groups_by = { 'low', 'saline', 'high' };
% pl.params.order_by = { 'ugit' };
pl.bar( prop3.only('ugit'), 'images', 'doses', 'rois' )
%%
pl.default()
pl.params.add_ribbon = true;
pl.params.shape = [];
pl.plot( cat_collapse(prop.only('ephron'), {'gender', 'gaze'}), 'doses', {'images', 'monkeys'} );