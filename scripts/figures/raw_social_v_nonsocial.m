%%  raw per-dose looking behavior, per group, social vs. nonsocial

plt = looks;

plt = plt.do_per( {'monkeys', 'doses', 'images'}, @mean );

nonsoc_ind = plt.where( {'outdoors', 'scrambled'} );
plt( 'images', nonsoc_ind ) = 'nonsocial';
plt( 'images', ~nonsoc_ind ) = 'social';

plt = plt.collapse( 'images' );

plt = plt.do_per( {'monkeys', 'doses', 'images'}, @mean );

plt = plt.replace( {'ephron', 'kubrick', 'tarantino'}, 'upGroup' );
plt = plt.replace( {'lager', 'hitch', 'cron'}, 'downGroup' );

%%  group1 - group2 

down = plt.only( 'downGroup' );
up = plt.only( 'upGroup' );

subbed = down.opc( up, 'monkeys', @minus );
subbed( 'monkeys' ) = 'downMinusUp';

%%  social - nonsocial

social = plt.only( 'social' );
nonsocial = plt.only( 'nonsocial' );
subbed = social.opc( nonsocial, {'images', 'genders', 'gazes', 'expressions', 'imgGaze'}, @minus );
subbed( 'images' ) = 'socialMinusNonsocial';

%%  plot

figure;
pl = ContainerPlotter();
pl.default();
% pl.order_by = { 'social', 'nonsocial' };
pl.order_by = { 'upGroup', 'downGroup' };
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.y_lim = [];

% pl.bar( plt, 'images', 'doses', 'monkeys' );
pl.bar( plt, 'monkeys', 'doses', 'images' );