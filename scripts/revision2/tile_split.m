pathinit; pathadd( 'hannah' ); pathadd( 'global' );
meas_type = 'pupil_fixation';
pupil = hww.io.get_matched_pupil_and_lookdur();
%%

tiles = 4;

pup = pupil.pupil_size;
pup.data = mean( cell2mat(pup.data), 2 );
looks = pupil.looking_duration;

assert( isequal(looks('rois'), {'image'}) );
assert( isequal(pup('rois'), {'image'}) );
assert( looks.labels == pup.labels );

% rebuild `looks` and `pup` so that the labels are identical to those of
% `index`.
dummy_func = @(x) x;
tile_field = 'tile';
tile_within = { 'sessions' };

normalize_func = @(x) set_data(x, get_data(x) ./ mean(get_data(x)));

pup = pup.for_each( tile_within, normalize_func );
looks = looks.for_each( tile_within, normalize_func );
index = pup.for_each( tile_within, @hww.process.get_percentile_index, tiles );
looks = looks.for_each( tile_within, dummy_func );
pup = pup.for_each( tile_within, dummy_func );

tile_labs = arrayfun( @(x) sprintf('%s__%d', tile_field, x), index.data, 'un', false );
looks = looks.require_fields( tile_field );
index = index.require_fields( tile_field );
pup = pup.require_fields( tile_field );
looks( tile_field ) = tile_labs;
pup( tile_field ) = tile_labs;
index( tile_field ) = tile_labs;

assert( looks.labels == pup.labels && looks.labels == index.labels );

%%

I = pup.get_indices( tile_within );

re_pup = Container();
re_looks = Container();

for idx = 1:numel(I)
  [pup_, looks_] = hww.process.get_n_minus_n( pup(I{idx}), looks(I{idx}), 1 );
  looks_.labels = pup_.labels;
  re_pup = append( re_pup, pup_ );
  re_looks = append( re_looks, looks_ );
end

%%
mean_looks = re_looks.collapse('images');
% mean_looks = mean_looks.replace( {'outdoors', 'scrambled'}, 'nonsocial' );
% mean_looks('images', ~mean_looks.where('nonsocial') ) = 'social';
mean_looks = mean_looks.each1d( {'sessions', 'images', tile_field}, @rowops.mean );

%%

pl = ContainerPlotter();

pl.order_by = { 'saline', 'low', 'high' };

figure(1); clf(); colormap( 'default' );

plt = hww.process.add_ud( mean_looks );

pl.bar( plt, 'doses', tile_field, {'images', 'monk_group'} );

f = FigureEdits( gcf() ); f.one_legend();

%%

tiles = re_looks('tile', :);
new_tiles = zeros( size(tiles) );
for i = 1:numel(tiles), new_tiles(i) = str2double(tiles{i}(numel('tile__')+1:end)); end
tiles = new_tiles;

figure(1); clf();

selectors = {'lager', 'saline'};

monk_ind = re_pup.where(selectors);
pup_plt = re_pup(selectors);
look_plt = re_looks(selectors);

gscatter(pup_plt.data, look_plt.data, tiles(monk_ind));

