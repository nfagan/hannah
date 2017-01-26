function obj = mean_across(obj, cat)

obj = obj.collapse( cat );

unvisited = true( shape(obj,1), 1 );
retain = false( shape(obj,1), 1 );

while ( any(unvisited) )
  fprintf( '\n ! mean_across: %d remaining', sum(unvisited) );
  first_new = find( unvisited, 1, 'first' );
  one = obj( first_new );
  
  switch ( class(one.labels) )
    case 'SparseLabels'
      labs = one.labels.labels;
    case 'Labels'
      labs = one.uniques();
      labs = [ labs{:} ];
    case 'struct'
      labs = one.uniques();
  end
  
  others_index = obj.where( labs );
  others = obj( others_index );
  unvisited( others_index ) = false;
  retain( first_new ) = true;
  obj.data( first_new, : ) = mean( others.data, 1 );
end

obj = obj( retain );

end