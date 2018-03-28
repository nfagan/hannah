%%
pathinit hannah;
pathadd hannah global;

base_save_path = '~/Desktop/hannah_data';
write_tables = true;
save_plots = true;
formats = { 'epsc', 'png', 'fig' };

if ( exist(base_save_path, 'dir') ~= 7 ), mkdir( base_save_path ); end

lookdur = hww.io.load_sparse_measures( 'lookdur' );

%%  RAW

reformatted = lookdur;

sessions = reformatted( 'sessions' );
session_ns = cellfun( @(x) x(end), sessions, 'un', false );

assert( all([1; 2] == str2double(unique(session_ns))) );

reformatted = reformatted.require_fields( 'session_numbers' );

for i = 1:numel(session_ns)
  reformatted( 'session_numbers', reformatted.where(sessions{i}) ) = ...
    sprintf( 'session__%s', session_ns{i} );
end

%%  MEAN RAW

mean_within = {'days', 'monkeys', 'doses', 'session_numbers'};

meaned = reformatted.each1d( mean_within, @rowops.mean );

t_meaned = meaned.each1d( {'doses', 'session_numbers', 'monkeys'}, @rowops.mean );
t_devs = meaned.each1d( {'doses', 'session_numbers', 'monkeys'}, @rowops.std );
t_meaned = t_meaned.require_fields( 'measure' );
t_meaned( 'measure' ) = 'means';
t_devs = t_devs.require_fields( 'measure' );
t_devs( 'measure' ) = 'std';

t_raw = table( append(t_meaned, t_devs), {'monkeys', 'doses', 'measure'}, 'session_numbers' );

if ( write_tables )
  writetable( t_raw, fullfile(base_save_path, 'raw.txt') ...
    , 'WriteRowNames', true );
end
%%  PLOT RAW

pl = ContainerPlotter();

pl.shape = [3, 2];
pl.order_by = { 'saline', 'low', 'high' };

meaned.bar( pl, 'doses', 'session_numbers', 'monkeys' );

f = FigureEdits( gcf );
f.one_legend();

if ( save_plots )
  for i = 1:numel(formats)
    if ( ~isempty(strfind(formats{i}, 'eps')) )
      ext = 'eps';
    else
      ext = formats{i};
    end
    saveas( gcf, fullfile(base_save_path, ...
      sprintf('raw.%s', ext)), formats{i} );
  end
end

%%  NORMALIZE

normed = meaned;
norm_within = setdiff( mean_within, 'days' );
[I, C] = normed.get_indices( norm_within );

for i = 1:numel(I)
  
  raw_data = meaned.data( I{i}, : );
  sal_ind = meaned.where( [C(i, :), 'saline'] );
  sal_data = meaned.data( sal_ind, : );
  sal_mean = mean( sal_data );
  norm_data = raw_data ./ sal_mean;    
  normed.data( I{i}, : ) = norm_data;
  
end

normed.data = (normed.data - 1) * 100;

t_meaned = normed.each1d( {'doses', 'session_numbers', 'monkeys'}, @rowops.mean );
t_devs = normed.each1d( {'doses', 'session_numbers', 'monkeys'}, @rowops.std );
t_meaned = t_meaned.require_fields( 'measure' );
t_meaned( 'measure' ) = 'means';
t_devs = t_devs.require_fields( 'measure' );
t_devs( 'measure' ) = 'std';

t_comb = rm( append(t_meaned, t_devs), 'saline' );

t_norm = table( t_comb, {'monkeys', 'doses', 'measure'}, 'session_numbers' );

if ( write_tables )
  writetable( t_norm, fullfile(base_save_path, 'normalized.txt') ...
    , 'WriteRowNames', true );
end
%%  PLOT NORM
  
figure(1); clf();
pl = ContainerPlotter();

pl.shape = [3, 2];
pl.y_lim = [-45, 45];
pl.order_by = { 'saline', 'low', 'high' };

plt = normed.rm( 'saline' );

plt.bar( pl, 'doses', 'session_numbers', 'monkeys' );

f = FigureEdits( gcf );
f.one_legend();

if ( save_plots )
  for i = 1:numel(formats)
    if ( ~isempty(strfind(formats{i}, 'eps')) )
      ext = 'eps';
    else
      ext = formats{i};
    end
    saveas( gcf, fullfile(base_save_path, ...
      sprintf('normalized.%s', ext)), formats{i} );
  end
end


