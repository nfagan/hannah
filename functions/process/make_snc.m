function obj = make_snc( obj )

%   MAKE_SNC -- Make images -> social vs. nonsocial

nonsoc_ind = obj.where( {'outdoors', 'scrambled'} );
obj( 'images', nonsoc_ind ) = 'nonsocial';
obj( 'images', ~nonsoc_ind ) = 'social';

end