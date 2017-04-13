
meaned = looks.only( 'image' );
nonsoc = meaned.where( {'outdoors', 'scrambled'} );
meaned( 'images', nonsoc ) = 'nonsocial';
meaned( 'images', ~nonsoc ) = 'social';
meaned = meaned.do_per( {'sessions', 'images'}, @mean );
meaned = hannah__add_session_number( meaned );
session_numbers = hannah__get_session_numbers( meaned );

%%
pl = ContainerPlotter();
%%
pl.default();
pl.y_lim = [700 4000];
pl.x_lim = [0 25];
pl.add_legend = false;

monks = session_numbers( 'monkeys' );
for i = 1:numel(monks)
  pl.scatter( session_numbers.only( monks{i} ), meaned.only( monks{i} ) ...
  , 'monkeys', 'doses' );
  saveas( gcf, [monks{i} 'per_dose'], 'epsc' );
  saveas( gcf, [monks{i} 'per_dose'], 'png' );
end

%%
pl.default();
pl.shape = [3 2];
pl.x_lim = [0 25];
pl.y_lim = [700 4000];

selectors = { 'nonsocial' };

pl.scatter( session_numbers.only(selectors), meaned.only(selectors), 'doses', 'monkeys' );

saveas( gcf, 'all__monks__non_social', 'epsc' );

%%

img.from_day_start = hannah__from_day_start( img.from_session_start );
tc = hannah__tc_within_day( img.looking_duration, img.from_day_start ...
  , {'images', 'doses'}, 4 );

%%
selectors = { 'saline', 'low' };
pl.scatter( img.from_day_start.rm(selectors), img.looking_duration.rm(selectors), 'doses', 'monkeys' );

%%

pl.default();
pl.shape = [3 2];
pl.add_ribbon = true;

pl.plot( tc.rm({'outdoors','scrambled'}), 'doses', 'monkeys' );