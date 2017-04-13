roi = 'eyes';

prop_ = prop.only( roi );

%%  full time window
start_time = 0;
end_time = 5;
step_size = .05;

time = start_time+step_size:step_size:end_time;
[response, predictors, factors] = ...
  hannah__get_factor_matrix( prop_, {'monkeys', 'doses', 'gazes', 'expressions'}, time );
mdl = fitglm( predictors, response );

tbl = mdl.Coefficients;
tbl.Properties.RowNames = [ {'Intercept'}, factors ];

save( sprintf('with_group_glm_%s.mat', roi), 'tbl' );

%% select time window

start_time = 0;
end_time = 5;
step_size = .05;

time = start_time+step_size:step_size:end_time;

prop_truncated = prop_;

start = 0;
stop = 5;

time_index = time >= start & time <= stop;
truncated_time = time( time_index );
prop_truncated.data = prop_truncated.data( :, time_index );
[response, predictors, factors] = ...
  hannah__get_factor_matrix( prop_truncated, {'monkeys', 'doses', 'gazes', 'expressions'}, truncated_time );
mdl = fitglm( predictors, response );

tbl = mdl.Coefficients;
tbl.Properties.RowNames = [ {'Intercept'}, factors ];

save( sprintf('with_group_glm_%s_%0.1f_to_%0.1f.mat', roi, start, stop), 'tbl' );

% save means

meaned = prop_truncated;
meaned.data = mean( meaned.data, 2 );

means = meaned.do_per( {'monkeys', 'doses'}, @mean );
devs = meaned.do_per( {'monkeys', 'doses'}, @std );

save( sprintf('means_%s_%0.1f_to_%0.1f.mat', roi, start, stop), 'means' );
save( sprintf('devs_%s_%0.1f_to_%0.1f.mat', roi, start, stop), 'devs' );

means_per_cat = meaned.do_per( 'images', @mean );
devs_per_cat = meaned.do_per( 'images', @std );

save( sprintf('means_per_cat%s_%0.1f_to_%0.1f.mat', roi, start, stop), 'means_per_cat' );
save( sprintf('devs__per_cat%s_%0.1f_to_%0.1f.mat', roi, start, stop), 'devs_per_cat' );

%%

start = 0;
stop = 5;

time_index = time >= start & time <= stop;
truncated_time = time( time_index );

current_group_name = 'upGroup';
current = prop_.only( current_group_name );

current.data = current.data( :, time_index );

[response, predictors, factors] = ...
  hannah__get_factor_matrix( current, {'doses', 'gazes', 'expressions'}, truncated_time );
mdl = fitglm( predictors, response );

tbl = mdl.Coefficients;
tbl.Properties.RowNames = [ {'Intercept'}, factors ];

save( sprintf('%s_group_glm_%s_%0.1f_to_%0.1f.mat', current_group_name, roi, start, stop), 'tbl' );

%%  means per gaze

to_save.gaze_means_per_monk = meaned.do_per( {'monkeys', 'gazes'}, @mean );
to_save.gaze_devs_per_monk = meaned.do_per( {'monkeys', 'gazes'}, @std );

to_save.gaze_means = meaned.do_per( {'gazes'}, @mean );
to_save.gaze_devs = meaned.do_per( {'gazes'}, @std );

to_save.exp_means_per_monk = meaned.do_per( {'monkeys', 'expressions'}, @mean );
to_save.exp_devs_per_monk = meaned.do_per( {'monkeys', 'expressions'}, @std );

to_save.exp_means = meaned.do_per( {'expressions'}, @mean );
to_save.exp_devs = meaned.do_per( {'expressions'}, @std );

fs = fieldnames( to_save );
for i = 1:numel(fs)
  current_save_str = fs{i};
  eval( sprintf('%s = to_save.(''%s'');', current_save_str, current_save_str) );
  save( sprintf('%s_%s.mat', current_save_str, roi), current_save_str );
end







