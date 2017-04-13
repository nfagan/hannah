img_ = img;
soc = ~img_.where( {'outdoors', 'scrambled'} );
img_( 'images', soc ) = 'social';
img_( 'images', ~soc ) = 'nonsocial';

img_ = img_.do_per( {'monkeys', 'doses', 'images'}, @mean );

%%

sal = img_.only( 'saline' );
low = img_.only( 'low' );
high = img_.only( 'high' );

low = low.opc( sal, 'doses', @rdivide );
high = high.opc( sal, 'doses', @rdivide );
low( 'doses' ) = 'low';
high( 'doses' ) = 'high';

img_ = low.append( high );
img_.data = (img_.data - 1) * 100;

%%

current_dose = 'high';

perc = img_.only( {current_dose, 'social'} );
perc = perc.collapse( setdiff(perc.field_names(), {'monkeys'}) );

sal_raw = raw.only( 'saline' );
sal_raw = sal_raw.collapse( setdiff(sal_raw.field_names(), {'monkeys'}) );

sal_raw( 'doses' ) = current_dose;
perc( 'doses' ) = current_dose;

%%
pl.default();
pl.y_lim = [-100 100];
pl.marker_size = 30;
pl.add_fit_line = true;
pl.scatter( sal_raw, perc, 'monkeys', 'doses' );

%%  change from saline

sal = img.only( 'saline' );
others = img;
sal = sal.do_per( {'monkeys', 'doses'}, @mean );
monks = others( 'monkeys' );
for i = 1:numel( monks )
  other_ind = others.where( monks{i} );
  sal_ind = sal.where( monks{i} );
  others.data( other_ind ) = others.data( other_ind ) / sal.data( sal_ind );
end

others.data = (others.data - 1) * 100;
%%  social vs. nonsocial

nonsoc_ind = others.where( {'outdoors', 'scrambled'} );
others( 'images', nonsoc_ind ) = 'nonsocial';
others( 'images', ~nonsoc_ind ) = 'social';

%%
plt = others.only( {'social', 'low', 'high'} );
pl.default();
pl.y_lim = [-40 120];
pl.order_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.order_groups_by = { 'low', 'high' };
pl.bar( plt, 'monkeys', 'doses', 'rois' );


