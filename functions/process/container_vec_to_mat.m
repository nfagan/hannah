function cont = container_vec_to_mat( obj, x_is, order_by )

assert( isa(obj, 'Container'), ['Inputted object must be a Container; was a' ...
  , ' ''%s'''], class(obj) );
assert( size(obj.data, 2) == 1, ['The data in the object must have only one' ...
  , ' column'] );

within = setdiff( obj.field_names(), x_is );

objs = obj.enumerate( within );

cont = Container();

for i = 1:numel(objs)
  current = objs{i};
  allocated = false;
  for j = 1:numel(order_by)
    extr = current.only( order_by{j} );
    if ( j == 1 && isempty(extr) ), continue; end;
    if ( ~allocated )
      new_data = nan( size(extr.data, 1), numel(order_by) );
      allocated = true;
    end
    if ( isempty(extr) ), continue; end;
    assert( size(extr.data, 1) == size(new_data, 1), 'Dimension mismatch.' );
    new_data(:, j) = extr.data;
  end
  labs = current(1).labels;
  labs = labs.collapse( x_is );
  cont = cont.append( Container(new_data, labs) );
end

end