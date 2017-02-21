% rois = { 'eyes', 'mouth', 'image' };
rois = { 'face' };
x_calc = face.x.remove( {'scrambled', 'outdoors'} );
y_calc = face.y.remove( {'scrambled', 'outdoors'} );
within_bounds = within_bounds.append( hannah__mark_within_bounds( x_calc, y_calc, rois ) );
%%
prop = within_bounds.do_per( {'monkeys', 'images', 'doses', 'rois'}, @hannah__proportion_in_bounds );
prop = within_bounds.do_per( {'images', 'sessions', 'rois'}, @hannah__proportion_in_bounds );
prop = prop.do_per( {'monkeys', 'doses', 'rois'}, @mean );

%%
prop = cat_collapse( prop, {'gender'} );

prop = prop.replace( 'expressions__s', 'submissive' );
prop = prop.replace( 'expressions__n', 'neutral' );
prop = prop.replace( 'expressions__t', 'threat' );
prop = prop.replace( 'expressions__l', 'lipsmack' );
prop = prop.replace( 'gazes__direct', 'direct' );
prop = prop.replace( 'gazes__indirect', 'indirect' );

%%
pl.default();
pl.params.x = 0:.05:5-.05;
pl.params.add_ribbon = true;
pl.params.error_function = @std;
pl.params.full_screen = true;
pl.params.y_lim = [-.2 1.2];
pl.params.shape = [3 2];
pl.params.add_legend = true;
pl.params.order_panels_by = { 'saline', 'low', 'high' };
pl.params.save_outer_folder = fullfile( pathfor('plots'), '021717' ...
  , 'roi_order', 'per_expression_binned_50ms' );

% grouping = { 'ephron', 'kubrick', 'tarantino' };
% grouping = { 'lager', 'hitch', 'cron' };
% group_str = strjoin( grouping, '_' );
% group = prop.only( grouping );
% group = group.collapse( 'monkeys' );
% group = group.replace( 'all__monkeys', group_str );

pl.plot_and_save( prop ...
  , {'monkeys', 'expressions'} ...                  % files are
  , @plot ...                                       % plotting function
  , 'rois' ...                                      % lines are
  , {'doses', 'gazes', 'expressions', 'monkeys'} ); % panels are

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