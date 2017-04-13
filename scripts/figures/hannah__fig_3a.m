%%  FIG 3A.
%
%   For each session, for each image, for each dose, divide a mean by the
%   grand saline mean per monkey, dose, image.
%
%   Then identify social vs. nonsocial images, and average within social
%   vs. nonsocial, as well as within dose, monkey, and session.

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

social_index = ~normed.where( {'outdoors', 'scrambled'} );
normed( 'images', social_index ) = 'social';
normed( 'images', ~social_index ) = 'nonsocial';

normed = normed.do_per( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
normed.data = (normed.data-1) * 100;

%%  get means
means = normed.do_per( {'monkeys', 'doses', 'images'}, @mean );
devs = normed.do_per( {'monkeys', 'doses', 'images'}, @mean );
%%  save
save( sprintf('3a_bidirect_means_%s.mat', roi), 'means' );
save( sprintf('3a_bidirect_devs_%s.mat', roi), 'devs' );
%%
pl = ContainerPlotter();
%%  plot

pl.default();
pl.y_lim = [-40 120];
pl.order_by = { 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' };
pl.order_groups_by = { 'low', 'high' };
pl.bar( normed.rm( 'saline' ), 'monkeys', 'doses', 'images' );

%%  

saveas( gcf, sprintf('3a_bidirect_%s', roi), 'epsc' );