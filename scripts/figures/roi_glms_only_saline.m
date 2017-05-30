function roi_glms_only_saline()

%%  load + setup

savepath = fullfile( '~/Desktop/hannah_data', '050517' );
if ( exist(savepath, 'dir') ~= 7 ), mkdir(savepath); end;

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

%%  only saline glm

prop = prop_orig.only( 'saline' );

props = prop.enumerate( 'rois' );
for i = 1:numel(props)
  current = props{i};
  factors_except_time = { 'monkeys', 'gazes', 'expressions' };

  actual_start = 0;
  actual_end = 5;
  step_size = .05;

  time = actual_start+step_size:step_size:actual_end;

  [response, predictors, factors] = ...
    hannah__get_factor_matrix( current, factors_except_time, time );
  mdl = fitglm( predictors, response );

  tbl = mdl.Coefficients;
  tbl.Properties.RowNames = [ {'Intercept'}, factors ];
  
  filename = sprintf( 'glm_only_saline_%s.mat', char(current('rois')) );

  save( fullfile(savepath, filename), 'tbl' );
end

%%  plot with groups as panels

pl = ContainerPlotter();
pl.x = time;
pl.order_by = { 'saline', 'low', 'high' };
pl.add_ribbon = true;
pl.save_outer_folder = savepath;
pl.y_lim = [ 0 .55 ];

prop = prop_orig;

pl.plot_and_save( prop, 'rois', @plot, 'doses', {'monkeys', 'rois'} );

%%  perc change

props = prop_orig.enumerate( 'rois' );
prop_subbed = Container();
for i = 1:numel(props)
  prop = props{i};

  low = collapse( prop.only('low'), {'imgGaze', 'file_names', 'days', 'sessions'} );
  sal = collapse( prop.only('saline'), {'imgGaze', 'file_names', 'days', 'sessions'} );
  high = collapse( prop.only('high'), {'imgGaze', 'file_names', 'days', 'sessions'} );

  low = low.opc( sal, 'doses', @minus ); 
  low('doses') = 'lowMinusSal';
  high = high.opc( sal, 'doses', @minus ); 
  high('doses') = 'highMinusSal';
  prop_subbed = prop_subbed.append( low.append(high) );
end

%%  anovas

anovas = Container();

%%  anovas -- all groups

types = { 'minus_sal', 'raw' };
objs = { prop_subbed, prop_orig };

for i = 1:numel(objs)
  current = objs{i};
  current_type = types{i};
  if ( isequal(current_type, 'minus_sal') )
    current = current.rm( 'saline' );
  end
  current = current.mean(2);
  
  per_roi = current.enumerate( 'rois' );
  
  for k = 1:numel(per_roi)
    current_roi = per_roi{k};
    current_roi_label = char( current_roi('rois') );
    groups = { 'monkeys', 'gazes', 'expressions', 'doses' };

    labs = labels_for_anova( current_roi, groups );

    [~, tbl, stats] = anovan( current_roi.data, labs, 'varnames', groups, 'model', 'full', 'display', 'off' );
    [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups), 'display', 'off' );
    s.tbl = tbl;
    s.stats = stats;
    s.c = c;
    s.gnames = gnames;

    current_cont = Container( s, 'kind', current_type, 'monkeys', 'all' ...
      , 'rois', current_roi_label );
    current_cont = current_cont.sparse();
    anovas = anovas.append( current_cont );
  end
end

%%  anovas -- per group

objs1 = prop_subbed.enumerate( {'monkeys', 'rois'} );
types1 = repmat( {'minus_sal'}, 1, numel(objs1) );
objs2 = prop_orig.enumerate( {'monkeys', 'rois'}  );
types2 = repmat( {'raw'}, 1, numel(objs2) );
objs = { objs1{:}, objs2{:} };
types = { types1{:}, types2{:} };

for i = 1:numel(objs)
  current = objs{i};
  current_type = types{i};
  if ( isequal(current_type, 'minus_sal') )
    current = current.rm( 'saline' );
  end
  current = current.mean(2);

  groups = { 'gazes', 'expressions', 'doses' };

  labs = labels_for_anova( current, groups );

  [~, tbl, stats] = anovan( current.data, labs, 'varnames', groups, 'model', 'full', 'display', 'off' );
  [c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups), 'display', 'off' );
  s.tbl = tbl;
  s.stats = stats;
  s.c = c;
  s.gnames = gnames;
  
  current = Container( s, 'kind', current_type, 'monkeys', current('monkeys') ...
    , 'rois', current('rois') );
  current = current.sparse();
  anovas = anovas.append( current );
end

save( fullfile(savepath, 'glm_anovas.mat'), 'anovas' );


