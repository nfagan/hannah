function obj = add_ud(obj)

%   ADD_UD -- Add up vs. down group labels to the object.

obj = obj.require_fields( 'monk_group' );

up_ind = obj.where( {'ephron', 'kubrick', 'tarantino'} );
down_ind = obj.where( {'lager', 'hitch', 'cron'} );

assert( any(up_ind) && any(down_ind), ['Could not find any of the monkey' ...
  , ' search terms.'] );

obj( 'monk_group', up_ind ) = 'monk_group__up';
obj( 'monk_group', down_ind ) = 'monk_group__down';

end