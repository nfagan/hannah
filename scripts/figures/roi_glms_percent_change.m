%%  load + setup

savepath = fullfile( '~/Desktop/hannah_data', '041117', 'glm' );

bounds = ...
  load( fullfile(pathfor('processedImageData'), '030617', 'eye_mouth_bounds.mat') );
fs = fieldnames( bounds );
bounds = bounds.( fs{1} );

within_bounds = bounds;
within_bounds = hannah__bin_within_bounds( within_bounds, 50 );
prop = within_bounds.do_per( {'monkeys', 'images', 'doses'} ...
  , @hannah__relative_proportion_within_bounds, 0:2 );

prop = prop.rm( 'roi__0' );
prop = prop.replace( 'roi__1', 'eyes' );
prop = prop.replace( 'roi__2', 'mouth' );

group1 = { 'ephron', 'kubrick', 'tarantino' };
group2 = { 'lager', 'hitch', 'cron' };

prop = prop.replace( group1, 'upGroup' );
prop = prop.replace( group2, 'downGroup' );

prop_orig = prop; % store copy

%%  minus sal

roi = 'mouth';
prop = prop_orig;
prop = prop.only( roi );

low = collapse( prop.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
sal = collapse( prop.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
high = collapse( prop.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

low = low.opc( sal, 'doses', @minus ); 
low('doses') = 'lowMinusSal';
high = high.opc( sal, 'doses', @minus ); 
high('doses') = 'highMinusSal';
% prop = low.append( high );
prop_subbed = low.append( high );

%%  glm with time across groups

prop = prop_subbed.only( roi );
prop = prop.rm( 'saline' );

factors_except_time = { 'monkeys', 'doses', 'gazes', 'expressions' };

actual_start = 0;
actual_end = 5;
step_size = .05;

start_time = 0;
end_time = 5;

time = actual_start+step_size:step_size:actual_end;

prop_truncated = prop;

time_index = time >= start_time & time <= end_time;
truncated_time = time( time_index );
prop_truncated.data = prop_truncated.data( :, time_index );
[response, predictors, factors] = ...
  hannah__get_factor_matrix( prop_truncated, factors_except_time, truncated_time );
mdl = fitglm( predictors, response );

tbl = mdl.Coefficients;
tbl.Properties.RowNames = [ {'Intercept'}, factors ];

filename = sprintf('glm_across_groups_from_%0.2f_to_%0.2f_%s.mat', start_time, end_time, roi);
save( fullfile(savepath, filename), 'tbl' );

%%  means

% - across groups
prop_meaned = prop_truncated;
prop_meaned.data = mean( prop_meaned.data, 2 );

across_group_means = struct();
across_group_means.expression = prop_meaned.do_per( {'expressions'}, @mean );
across_group_means.gazes = prop_meaned.do_per( {'gazes'}, @mean );
across_group_means.doses = prop_meaned.do_per( {'doses'}, @mean );

across_group_devs = struct();
across_group_devs.expression = prop_meaned.do_per( {'expressions'}, @std );
across_group_devs.gazes = prop_meaned.do_per( {'gazes'}, @std );
across_group_devs.doses = prop_meaned.do_per( {'doses'}, @std);

% - per group
per_group_means = struct();
per_group_means.expression = prop_meaned.do_per( {'monkeys', 'expressions'}, @mean );
per_group_means.gazes = prop_meaned.do_per( {'monkeys', 'gazes'}, @mean );
per_group_means.doses = prop_meaned.do_per( {'monkeys', 'doses'}, @mean );

per_group_devs = struct();
per_group_devs.expression = prop_meaned.do_per( {'monkeys', 'expressions'}, @std );
per_group_devs.gazes = prop_meaned.do_per( {'monkeys', 'gazes'}, @std );
per_group_devs.doses = prop_meaned.do_per( {'monkeys', 'doses'}, @std );

filename = sprintf('means_across_groups_from_%0.2f_to_%0.2f_%s.mat', start_time, end_time, roi);
save( fullfile(savepath, filename), 'across_group_means' );

filename = sprintf('means_per_group_from_%0.2f_to_%0.2f_%s.mat', start_time, end_time, roi);
save( fullfile(savepath, filename), 'per_group_means' );

filename = sprintf('devs_across_groups_from_%0.2f_to_%0.2f_%s.mat', start_time, end_time, roi);
save( fullfile(savepath, filename), 'across_group_devs' );

filename = sprintf('devs_per_group_from_%0.2f_to_%0.2f_%s.mat', start_time, end_time, roi);
save( fullfile(savepath, filename), 'per_group_devs' );

%%  glm with time, up vs. down group

group_name = 'downGroup';

prop = prop_subbed;
prop = prop.only( {roi, group_name} );
prop = prop.rm( 'saline' );

factors_except_time = { 'doses', 'gazes', 'expressions' };

actual_start = 0;
actual_end = 5;
step_size = .05;

start_time = 0;
end_time = 5;

time = actual_start+step_size:step_size:actual_end;

prop_truncated = prop;

time_index = time >= start_time & time <= end_time;
truncated_time = time( time_index );
prop_truncated.data = prop_truncated.data( :, time_index );
[response, predictors, factors] = ...
  hannah__get_factor_matrix( prop_truncated, factors_except_time, truncated_time );
mdl = fitglm( predictors, response );

tbl = mdl.Coefficients;
tbl.Properties.RowNames = [ {'Intercept'}, factors ];

filename = sprintf('glm_per_group_from_%0.2f_to_%0.2f_%s_%s.mat', start_time, end_time, roi, group_name);
save( fullfile(savepath, filename), 'tbl' );


%%  divide sal

roi = 'eyes';

prop = prop_orig;
prop = prop.only( roi );

low = collapse( prop.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
sal = collapse( prop.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
high = collapse( prop.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

low = low.opc( sal, 'doses', @rdivide ); 
low('doses') = 'lowMinusSal';
high = high.opc( sal, 'doses', @rdivide ); 
high('doses') = 'highMinusSal';
prop = low.append( high );
prop.data = (prop.data-1)*100;  % magnitude change
