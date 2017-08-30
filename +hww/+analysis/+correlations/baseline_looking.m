function corred = baseline_looking(obj)

real_data_norm = saline_normalize( obj );
real_data_norm = real_data_norm.parfor_each( {'monkeys', 'doses'}, @mean );

real_data_baseline = obj.parfor_each( {'monkeys', 'doses', 'images', 'sessions'}, @mean );
real_data_baseline = real_data_baseline.parfor_each( {'monkeys', 'doses'}, @mean );
real_data_baseline = real_data_baseline.only( 'saline' );
real_data_norm = real_data_norm.remove( 'saline' );


end