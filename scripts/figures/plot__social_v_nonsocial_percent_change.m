%   For each session, for each image, for each dose, divide a mean by the
%   grand saline mean per monkey, dose, image.
%
%   Then average those normalized values per monkey, dose, session, and
%   image.
%   
%   Then identify social vs. nonsocial images, and average within social
%   vs. nonsocial, as well as within monkey, dose, and session.
%
%   Then subtract nonsocial from social, and average over sessions.

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

normed = normed.collapse( setdiff(normed.field_names(), {'monkeys', 'doses', 'images', 'sessions'}) );

difference = normed;

%%

social = difference.only( 'social' );
nonsocial = difference.only( 'nonsocial' );

difference = social.opc( nonsocial, 'images', @minus );
difference( 'images' ) = 'social_minus_nonsocial';
difference = difference.do_per( {'monkeys', 'doses', 'images'}, @mean );

%%  up vs. down

up_group_members = {'ephron', 'kubrick', 'tarantino'};
down_group_members = {'lager', 'hitch', 'cron'};
difference = difference.replace( up_group_members, 'upGroup' );
difference = difference.replace( down_group_members, 'downGroup' );

%%  get means and errors

means = difference.do_per( {'doses', 'images', 'monkeys'}, @mean );
devs = difference.do_per( {'doses', 'images', 'monkeys'}, @std );

%%  save

save( '2d_soc_minus_nonsocial_means.mat', 'means' );
save( '2d_soc_minus_nonsocial_devs.mat', 'devs' );

%%  plot

figure;
pl = ContainerPlotter();
pl.default();
pl.save_outer_folder = cd;
pl.y_lim = [-25 25];
pl.marker_size = 5;
% pl.order_by = { 'upGroup', 'downGroup' };
pl.order_by = { 'low', 'high' };
pl.order_groups_by = { 'low', 'high' };
pl.add_points = true;
pl.point_label_categories = { 'monkeys', 'doses', 'images' };

% pl.plot_and_save( difference.rm('saline'), 'images', @bar, 'doses', [], 'monkeys' );
pl.plot_and_save( difference.only([{'low', 'high'}, down_group_members]) ...
  , 'images', @bar, 'doses', [], 'rois' );