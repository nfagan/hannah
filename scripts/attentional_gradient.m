%%  ATTENTIONAL GRADIENT -- SCRAMBLED -> DIRECTED
%
%   For each session, for each image, for each dose, divide a mean by the
%   grand saline mean per monkey, dose, image.
%
%   Then separate images into scrambled, landscapes, averted, and directed,
%   and plot for up / down group.

roi = 'image';
extr = looks.only( roi );

meaned = extr.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
sal = do_per( extr.only('saline'), {'monkeys', 'doses', 'images'}, @mean );

[objs, inds] = meaned.enumerate( {'monkeys', 'doses', 'images', 'sessions'} );
for i = 1:numel( objs )
  current = objs{i};
  monk_lab = char( current('monkeys') );
  image_lab = char( current('images') );
  sal_ind = sal.where( {monk_lab, image_lab} );
  meaned.data( inds{i} ) = meaned.data(inds{i}) ./ sal.data(sal_ind); 
end

normed = meaned;

direct_ind = normed.where( 'gazes__direct' );
indirect_ind = normed.where( 'gazes__indirect' );

normed( 'images', direct_ind ) = 'direct_image';
normed( 'images', indirect_ind ) = 'indirect_image';

normed = normed.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
normed.data = (normed.data-1) * 100;

%%

normed = normed.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
normed = normed.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

%%
figure;
pl = ContainerPlotter();
pl.default();
pl.y_lim = [-40 80];
pl.order_by = { 'scrambled', 'outdoors', 'indirect_image', 'direct_image' };
pl.marker_size = 5;
pl.add_points = true;
pl.point_label_categories = { 'monkeys' };

pl.plot_by( normed, 'images', 'monkeys', 'doses' );