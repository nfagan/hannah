[bounds, eye_bounds] = hannah__mark_quadrants( x, y );
%%
firsts = hannah__get_first_quadrant_following_eye( bounds, eye_bounds );
% firsts = hannah__get_first_quadrant( bounds );
firsts = firsts.keep( firsts.data > 0 );
congruent = hannah__mark_congruent_quadrant( firsts );
%%
valid = congruent;
valid = valid.rm( '5' );
valid.data = double( valid.data );
% valid( 'images' ) = 'social';
valid = cat_collapse( valid, {'gender'} );
valid = valid.do_per( {'sessions', 'images'}, @mean );
valid.data = valid.data * 100;
%%
group1 = { 'ephron', 'kubrick', 'tarantino' };
group2 = { 'lager', 'hitch', 'cron' };
valid = valid.replace( group1, 'upGroup' );
valid = valid.replace( group2, 'downGroup' );
%%
pl = ContainerPlotter();
%%
pl.default();
pl.shape = [];
% valid( 'images' ) = 'uaaa';
pl.y_label = '% Congruent';
pl.y_lim = [0 100];
pl.order_groups_by = { 'saline', 'low', 'high' };
pl.bar( valid, 'images', 'doses', 'rois' );