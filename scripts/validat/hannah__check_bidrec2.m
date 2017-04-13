measures = load( 'measures_outliersremoved.mat' );
measures = measures.outliers_removed;

looks = namespace_categories( measures.lookdur, {'genders','gazes','expressions'} );
looks = looks.to_container();
looks = looks.sparse();
%%
means = looks.rm( 'face' );

nonsoc = means.where( {'outdoors','scrambled'} );
means( 'images', ~nonsoc ) = 'social';

means = means.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );

sal = means.only( 'saline' );
high = means.only( 'high' );
low = means.only( 'low' );

high = high.opc( sal, 'doses', @rdivide );
low = low.opc( sal, 'doses', @rdivide );

high('doses') = 'divSal';
low('doses') = 'divSal';
sal('doses') = 'divSal';

high.data = (high.data - 1) * 100;
low.data = (low.data - 1) * 100;

pl.default();
pl.y_lim = [-100 100];
pl.x_lim = [500 3500];
pl.add_fit_line = true;
pl.marker_size = 40;
pl.scatter( sal.only('social'), high.only('social'), 'monkeys', 'doses' );

%%

pl.default();
pl.order_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.bar( only(low.append(high), {'social'}), 'monkeys', 'doses', 'rois' );

%%

high( 'doses' ) = 'high';
low( 'doses' ) = 'low';

meaned = high.append( low );
social = meaned.only( 'social' );

collapsed = meaned.do_per( {'monkeys', 'doses'}, @mean );






