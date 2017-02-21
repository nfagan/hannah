collapsed = binned_prop;

group1 = { 'ephron', 'tarantino', 'kubrick' };
group2 = { 'hitch', 'lager', 'cron' };

collapsed = collapsed.replace( group1, 'up_group' );
collapsed = collapsed.replace( group2, 'down_group' );

[responses, predictors, factors] = hannah__get_factor_matrix( collapsed.only('down_group') ...
  , {'doses', 'gazes', 'expressions', 'rois'}, 0:.1:5-.1 );

mdl = fitglm( predictors, responses );

%%

within_bounds = orig_within_bounds.remove( 'image' );
% within_bounds.data = within_bounds.data( :, 1:1e3 );

eyes = within_bounds.only( 'eyes' );
mouth = within_bounds.only( 'mouth' );
image_ind = within_bounds.where( 'face' );
either = eyes.data | mouth.data;
within_bounds.data(image_ind, :) = within_bounds.data(image_ind, :) & ~either;

trial_by_trial_prop = cat_collapse( within_bounds, 'gender' );
trial_by_trial_prop = trial_by_trial_prop.do_per( {'monkeys', 'doses', 'images'} ...
  , @hannah__get_trial_by_trial_prop );

% trial_by_trial_prop = hannah__get_trial_by_trial_prop( within_bounds );

trial_by_trial_prop = cat_collapse( trial_by_trial_prop, {'gender'} );
summed = trial_by_trial_prop.do_per( {'monkeys', 'doses', 'images', 'rois'}, @sum );

% summed = summed.replace( group1, 'e,t,k' );
% summed = summed.replace( group2, 'h,l,c' );

%% subtract / div by sal

sal = summed.only( 'saline' );
high = summed.only( 'high' );
low = summed.only( 'low' );
high = high.opc( sal, 'doses', @rdivide );
high( 'doses' ) = 'high';
low = low.opc( sal, 'doses', @rdivide );
low( 'doses' ) = 'low';
summed = high.append( low );

summed.data = summed.data - 1;

%%
pl.default();
pl.params.shape = [1 2];
pl.params.y_lim = [-.5 10];
pl.params.summary_function = @mean;
pl.params.stacked_bar = false;
pl.params.add_legend = true;
pl.params.save_outer_folder = fullfile( pathfor('plots'), '021717' ...
  , 'roi_sums', 'per_expression_down_group_up_group_div_saline' );

pl.plot_and_save( summed, {'doses'}, @bar ...
  , 'images', 'rois', {'monkeys', 'doses'} ...
);

% pl.bar( summed.only('saline'), 'images', 'rois', 'monkeys' );





