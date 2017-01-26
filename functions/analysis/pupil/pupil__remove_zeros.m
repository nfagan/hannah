function obj = pupil__remove_zeros( obj )

data = obj.data;
any_zeros = any( data == 0, 2 );
obj = obj( ~any_zeros );

end
