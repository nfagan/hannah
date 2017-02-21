function obj = hannah__get_trial_by_trial_prop( obj )

obj.data = sum( obj.data, 2 );
obj.data = obj.data / sum( obj.data );

end