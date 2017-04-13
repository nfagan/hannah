meaned = look__new.only( 'image' );
nonsoc = meaned.where( {'outdoors', 'scrambled'} );
meaned( 'images', ~nonsoc ) = 'social';

meaned = meaned.do_per( {'images', 'doses', 'sessions', 'monkeys'}, @mean );

sal = meaned.only( 'saline' );
low = meaned.only( 'low' );
high = meaned.only( 'high' );

low.data = low.data ./ sal.data;
high.data = high.data ./ sal.data;

normed = low.append( high );
normed.data = (normed.data - 1) * 100;
%%
normed = normed_measures.image__lookdur;
normed = namespace_categories( normed, {'genders', 'gazes', 'expressions'} );
normed = normed.to_container();
normed = normed.sparse();
%%
pl = ContainerPlotter();
%%
pl.default();
pl.y_lim = [-40 80];
pl.order_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.bar( normed, 'monkeys', 'doses', 'rois' );

% low_normed = low.opc( sal, {'doses', 'sessions'}, @rdivide );
% low_normed( 'doses' ) = 'low';
% high_normed = high.opc( sal, 'doses', @rdivide );
% high_normed( 'doses' ) = 'high';
% % 
% normed = low_normed.append( high_normed );
% normed.data = (normed.data - 1) * 100;

%%

normed2 = normed.do_per( {'monkeys', 'doses', 'images'}, @mean );
% normed2.data = (normed2.data - 1) * 100;

%%

extr = normed2.only( {'kubrick', 'high', 'social'} );
disp( extr.data );

%%

extr = b.only( {'kubrick', 'high', 'social'} );