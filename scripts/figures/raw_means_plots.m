%%  raw mean plots

% - load
filename = 'sparse_measures_outliersremoved.mat';
measures_path = fullfile( pathfor('processedImageData'), '110716', filename );
load( measures_path );

% - measure type
measure_type = 'lookdur';
looks = measures.( measure_type );

% - roi
looks = looks.only( 'image' );

% - savepath
savepath = fullfile( pathfor('plots'), datestr(now, 'mmddyy'), measure_type, 'raw' );
do_save = false;
if ( do_save && exist(savepath, 'dir') ~= 7 ), mkdir(savepath); end

pl = ContainerPlotter();

%%
normed = hww.process.saline_normalize( looks );
normed.data = (normed.data-1)*100;

%%  per monkey, collapsed images

mean_func = @Container.mean_1d;

per_monk = looks;
per_monk = per_monk.collapse( 'images' );
per_monk = per_monk.for_each_1d( {'sessions'}, mean_func );

pl.default();
pl.order_by = { 'saline', 'low', 'high' };
pl.y_lim = [0 3.1e3];
pl.bar( per_monk, 'doses', 'images', 'monkeys' );

filename = sprintf( 'per_monk_collapsed_images_%s', measure_type );
if ( do_save )
  saveas( gcf, fullfile(savepath, filename), 'epsc' );
end

%%  up v. down, collapsed images, overlaid points

pl = ContainerPlotter();

mean_func = @Container.mean_1d;

up_down = looks;
up_down = up_down.collapse( 'images' );
up_down = hww.process.add_ud( up_down );

up_down = up_down.for_each_1d( {'sessions'}, mean_func );

pl.default(); figure(1); clf();
pl.y_lim = [0, 3e3];
pl.order_by = { 'saline', 'low', 'high' };
pl.bar( up_down, 'doses', 'images', 'monk_group' );

filename = sprintf( 'ud_collapsed_images_%s', measure_type );

%   add points

xs_labs = { 'saline', 'low', 'high' };
g_labs = { 'all__images' };
p_labs = { 'monk_group__up', 'monk_group__down' };

C = allcomb( {xs_labs, g_labs, p_labs} );

axs = findobj( figure(1), 'type', 'axes' );
set( axs, 'NextPlot', 'add' );

colors = hww.plot.util.get_monkey_colors();

for i = 1:size(C, 1)
  
  x_lab = C{i, 1};
  g_lab = C{i, 2};
  p_lab = C{i, 3};
  
  ax_ind = numel(axs) - find(strcmp(p_labs, p_lab)) + 1;
  
  x_coord = find( strcmp(xs_labs, x_lab) );
  subset = up_down.only( C(i, :) );
  subset = subset.for_each_1d( {'monkeys', 'images'}, mean_func );
  
%   offsets = -1/numel(g_labs):1/numel(g_labs):1/numel(g_labs);
  
%   g_offset = find( strcmp(g_labs, g_lab) );
  
%   x = x_coord + offsets( g_offset );
  x = x_coord;
  
  data = subset.data;
  
  for k = 1:numel(data)
    color = colors.(char(subset('monkeys', k)));
    plot( axs(ax_ind), x, data(k), sprintf('%s*', color) );
  end
  
end

% saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  per monkey, social vs. scrambled, overlaid points

% kind = 'social_v_nonsocial';
kinds = { 'social_v_scrambled', 'social_v_outdoors_v_scrambled' ...
  , 'social_v_nonsocial', 'social_minus_nonsocial' };
mis_per_monkey = { true, false };
mis_normalized = { true, false };
add_points = false;
do_save = true;

CC = allcomb( {kinds, mis_per_monkey, mis_normalized} );

for idx = 1:size(CC, 1)
  
  kind = CC{idx, 1};
  is_per_monkey = CC{idx, 2};
  is_normalized = CC{idx, 3};

  filename = kind;

  pl = ContainerPlotter();
  mean_func = @Container.mean_1d;

  if ( is_normalized )
    up_down = normed;
    up_down = up_down.rm( 'saline' );
  else
    up_down = looks;
  end

  if ( strcmp(kind, 'social_v_scrambled') )
    up_down = up_down.rm( 'outdoors' );
    up_down( 'images', ~up_down.where('scrambled') ) = 'social';
  elseif ( strcmp(kind, 'social_v_outdoors_v_scrambled') )
    nonsoc_ind = up_down.where( {'outdoors', 'scrambled'} );
    up_down( 'images', ~nonsoc_ind ) = 'social';
  elseif ( strcmp(kind, 'social_v_nonsocial') || strcmp(kind, 'social_minus_nonsocial') )
    up_down = up_down.replace( {'outdoors', 'scrambled'}, 'nonsocial' );
    up_down( 'images', ~up_down.where('nonsocial') ) = 'social';
  else
    assert( false );
  end

  if ( ~is_per_monkey )
    up_down = hww.process.add_ud( up_down );
  end

  up_down = up_down.each1d( {'sessions', 'images'}, mean_func );

  if ( strcmp(kind, 'social_minus_nonsocial') )
    up_down = up_down({'social'}) - up_down({'nonsocial'});
  end

  pl.default(); figure(1); clf();

  if ( is_normalized && ~strcmp(kind, 'social_minus_nonsocial') )
    pl.y_lim = [-50, 150];
  elseif ( is_normalized && strcmp(kind, 'social_minus_nonsocial') )
    pl.y_lim = [-30, 50];
  elseif ( ~is_normalized && ~strcmp(kind, 'social_minus_nonsocial') )
    pl.y_lim = [0, 4e3];
  else
    pl.y_lim = [-800, 1500];
  end

  pl.order_by = { 'saline', 'low', 'high' };

  if ( ~is_per_monkey )
    pl.bar( up_down, 'doses', 'images', 'monk_group' );
  else
    pl.bar( up_down, 'doses', 'images', 'monkeys' );
  end

  if ( is_normalized )
    filename = [ filename, '_normalized' ];
  else
    filename = [ filename, '_raw' ];
  end

  if ( is_per_monkey )
    filename = [ filename, '_per_monkey' ];
  else
    filename = [ filename, '_ud' ];
  end

  %   add points

  xs_labs = { 'saline', 'low', 'high' };
  % g_labs = { 'all__images' };
  g_labs = up_down( 'images' );

  if ( is_per_monkey )
    p_labs = up_down( 'monkeys' );
  else
    p_labs = { 'monk_group__up', 'monk_group__down' };
  end

  if ( add_points )

    C = allcomb( {xs_labs, g_labs, p_labs} );

    axs = findobj( figure(1), 'type', 'axes' );
    set( axs, 'NextPlot', 'add' );

    colors = hww.plot.util.get_monkey_colors();

    for i = 1:size(C, 1)

      x_lab = C{i, 1};
      g_lab = C{i, 2};
      p_lab = C{i, 3};

      ax_ind = numel(axs) - find(strcmp(p_labs, p_lab)) + 1;

      x_coord = find( strcmp(xs_labs, x_lab) );
      subset = up_down.only( C(i, :) );
      subset = subset.for_each_1d( {'monkeys', 'images'}, mean_func );

    %   offsets = -1/numel(g_labs):1/numel(g_labs):1/numel(g_labs);

    %   g_offset = find( strcmp(g_labs, g_lab) );

    %   x = x_coord + offsets( g_offset );
      x = x_coord;

      data = subset.data;

      for k = 1:numel(data)
        color = colors.(char(subset('monkeys', k)));
        plot( axs(ax_ind), x, data(k), sprintf('%s*', color) );
      end

    end
  end

  if ( do_save )
    save_dir = fullfile( savepath, kind );
    if ( exist(save_dir, 'dir') ~= 7 ), mkdir( save_dir ); end
    saveas( gcf, fullfile(save_dir, filename), 'png' );
    saveas( gcf, fullfile(save_dir, filename), 'epsc' );
    saveas( gcf, fullfile(save_dir, filename), 'fig' );
  end
end

%%  per monkey, faces / scr / outdoors

per_monk = looks;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );

per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

pl.default();
% pl.y_lim = [0 4.5e3];
pl.y_lim = [];
pl.order_by = { 'scrambled', 'outdoors', 'social' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.order_panels_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.bar( per_monk, 'images', 'doses', 'monkeys' );

filename = sprintf( 'per_monk_scr_out_face_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  up v. down, faces / scr / outdoors

up_down = looks;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'sessions', 'images'}, @mean );

figure;
pl.default();
pl.order_by = { 'scrambled', 'outdoors', 'social' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down, 'images', 'doses', 'monkeys' );

filename = sprintf( 'ud_scr_out_face_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  per monkey, each of 8 categories / scr / outdoors

per_monk = looks;
per_monk = cat_collapse( per_monk, {'gender'} );
per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

pl.default();
pl.y_lim = [];
pl.order_by = { 'scrambled', 'outdoors' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.order_panels_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.bar( per_monk, 'images', 'doses', 'monkeys' );

filename = sprintf( 'per_monk_scr_out_per_exp_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%	up v. down, each of 8 categories / scr / outdoors

up_down = looks;
up_down = cat_collapse( up_down, {'gender'} );
up_down = make_ud( up_down );

up_down = up_down.do_per( {'sessions', 'images'}, @mean );

figure;
pl.default();
pl.order_by = { 'scrambled', 'outdoors' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down, 'images', 'doses', 'monkeys' );

filename = sprintf( 'ud_scr_out_per_exp_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  per monkey, soc / nosoc

per_monk = looks;
per_monk = cat_collapse( per_monk, {'gender', 'gaze', 'expression'} );
per_monk = per_monk.replace( 'uaaa', 'social' );
per_monk = per_monk.replace( {'outdoors', 'scrambled'}, 'nonsocial' );

per_monk = per_monk.do_per( {'sessions', 'images'}, @mean );

pl.default();
pl.order_by = { 'social', 'nonsocial' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( per_monk, 'images', 'doses', 'monkeys' );

filename = sprintf( 'per_monk_soc_nonsoc_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );

%%  up v. down, soc / nonsoc

mean_func = @rowops.mean;

up_down = looks;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = up_down.replace( {'outdoors', 'scrambled'}, 'nonsocial' );
up_down = hww.process.add_ud( up_down );

up_down = up_down.for_each_1d( {'sessions', 'images'}, mean_func );

figure(1); clf();
pl.default();
pl.add_legend = false;
pl.order_by = { 'social', 'nonsocial' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down, 'images', 'doses', 'monk_group' );

%   add points

xs_labs = { 'social', 'nonsocial' };
g_labs = { 'saline', 'low', 'high' };
p_labs = { 'monk_group__up', 'monk_group__down' };

C = allcomb( {xs_labs, g_labs, p_labs} );

axs = findobj( figure(1), 'type', 'axes' );
set( axs, 'NextPlot', 'add' );

colors = hww.plot.util.get_monkey_colors();

for i = 1:size(C, 1)
  
  x_lab = C{i, 1};
  g_lab = C{i, 2};
  p_lab = C{i, 3};
  
  ax_ind = numel(axs) - find(strcmp(p_labs, p_lab)) + 1;
  
  x_coord = find( strcmp(xs_labs, x_lab) );
  subset = up_down.only( C(i, :) );
  subset = subset.for_each_1d( {'monkeys', 'images'}, mean_func );
  
  offsets = -1/numel(g_labs):1/numel(g_labs):1/numel(g_labs);
  
  g_offset = find( strcmp(g_labs, g_lab) );
  
  x = x_coord + offsets( g_offset );
  
  data = subset.data;
  
  for k = 1:numel(data)
    color = colors.(char(subset('monkeys', k)));
    plot( axs(ax_ind), x, data(k), sprintf('%s*', color) );
  end
  
end


filename = sprintf( 'ud_soc_nonsoc_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );


%%  up v. down, soc - nonsoc

mean_func = @rowops.mean;

up_down = looks;
up_down = cat_collapse( up_down, {'gender', 'gaze', 'expression'} );
up_down = up_down.replace( 'uaaa', 'social' );
up_down = up_down.replace( {'outdoors', 'scrambled'}, 'nonsocial' );
up_down = hww.process.add_ud( up_down );

up_down = up_down.for_each_1d( {'sessions', 'images'}, mean_func );
% up_down = up_down.only('social') - up_down.only('nonsocial');
up_down = up_down({'social'}) - up_down({'nonsocial'});


figure(1); clf();
pl.default();
pl.add_legend = false;
pl.y_lim = [-1000, 1800];
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( up_down, 'monk_group', 'doses', 'images' );

%   add points

xs_labs = { 'monk_group__down', 'monk_group__up' };
g_labs = { 'saline', 'low', 'high' };
p_labs = { 'social_minus_nonsocial' };

C = allcomb( {xs_labs, g_labs, p_labs} );

axs = findobj( figure(1), 'type', 'axes' );
set( axs, 'NextPlot', 'add' );

colors = hww.plot.util.get_monkey_colors();

for i = 1:size(C, 1)
  
  x_lab = C{i, 1};
  g_lab = C{i, 2};
  p_lab = C{i, 3};
  
  ax_ind = numel(axs) - find(strcmp(p_labs, p_lab)) + 1;
  
  x_coord = find( strcmp(xs_labs, x_lab) );
  subset = up_down.only( C(i, :) );
  subset = subset.for_each_1d( {'monkeys', 'images'}, mean_func );
  
  offsets = -1/numel(g_labs):1/numel(g_labs):1/numel(g_labs);
  
  g_offset = find( strcmp(g_labs, g_lab) );
  
  x = x_coord + offsets( g_offset );
  
  data = subset.data;
  
  for k = 1:numel(data)
    color = colors.(char(subset('monkeys', k)));
    plot( axs(ax_ind), x, data(k), sprintf('%s*', color) );
  end
  
end

filename = sprintf( 'ud_soc_minus_nonsoc_%s', measure_type );
saveas( gcf, fullfile(savepath, filename), 'epsc' );