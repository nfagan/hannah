%%  SUPPLEMENTARY
%
%   For each session, for each image, for each dose, divide a mean by the
%   grand saline mean per monkey, dose, image.
%
%   Then identify social vs. nonsocial images, and average within social
%   vs. nonsocial, as well as within dose, monkey, and session.

roi = 'image';
extr = looks.only( roi );
extr = extr.rm( {'outdoors', 'scrambled'} );

meaned = extr.do_per( {'monkeys', 'doses', 'gazes', 'expressions', 'sessions'}, @mean );

meaned = meaned.replace( 'expressions__l', 'lipsmack' );
meaned = meaned.replace( 'expressions__t', 'threat' );
meaned = meaned.replace( 'expressions__s', 'fear' );
meaned = meaned.replace( 'expressions__n', 'neutral' );

%%  collapse up v down group

meaned = meaned.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
meaned = meaned.replace( {'cron', 'hitch', 'lager'}, 'downGroup' );

%%
pl = ContainerPlotter();
%%  plot

pl.default();

pl.y_lim = [0 4.2e3];
pl.save_outer_folder = cd;
pl.order_by = { 'threat', 'fear', 'lipsmack', 'neutral' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.plot_and_save( meaned, 'monkeys', @bar, 'expressions', 'doses', {'gazes', 'monkeys'} );

%%  

saveas( gcf, sprintf('3a_bidirect_%s', roi), 'epsc' );