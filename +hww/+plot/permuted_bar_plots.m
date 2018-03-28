import hww.process.arr_join;

conf = hww.config.load();
date_dir = '091417';
base_l_p = conf.PATHS.processedImageData;
base_s_p = conf.PATHS.plots;
load_dir = fullfile( base_l_p, 'analyses', 'correlations', date_dir );
save_dir = fullfile( base_s_p, datestr(now, 'mmddyy') );

if ( exist(save_dir, 'dir') ~= 7 ), mkdir( save_dir ); end

load( fullfile(load_dir, 'correlations.mat') );

base = Container.concat( all_data );
base = base.only( 'permuted__true' );

base = base.each1d( {'monkeys', 'doses'}, @rowops.mean );

base = hww.process.add_ud( base );

figure(1); clf();

pl = ContainerPlotter();
pl.order_by = { 'saline', 'low', 'high' };

base.bar( pl, 'doses', 'images', 'monk_group' );

% 
% add points
%

mean_func = @rowops.mean;

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
  
  x = find( strcmp(xs_labs, x_lab) );
  subset = base.only( C(i, :) );
  subset = subset.for_each_1d( {'monkeys', 'images'}, mean_func );
  
  data = subset.data;
  
  for k = 1:numel(data)
    color = colors.(char(subset('monkeys', k)));
    plot( axs(ax_ind), x, data(k), sprintf('%s*', color) );
  end
  
end

saveas( figure(1), fullfile(save_dir, 'perm_bar_raw_data'), 'epsc' );
saveas( figure(1), fullfile(save_dir, 'perm_bar_raw_data'), 'fig' );
saveas( figure(1), fullfile(save_dir, 'perm_bar_raw_data'), 'png' );

