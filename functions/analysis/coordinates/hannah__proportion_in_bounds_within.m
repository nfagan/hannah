function proportion = hannah__proportion_in_bounds_within( x, y, within, region )

assert( isa(x, 'Container') && isa(y, 'Container') ...
  , 'Expected x and y to be Containers' );
assert( x.labels == y.labels, 'The label objects of x and y must equivalent' );
x_y = Structure( struct('x', x, 'y', y) );
coords_file = load_excel_roi_coordinates();
monks = unique( x('monkeys') );
proportion = Container();
for i = 1:numel(monks)
  fprintf( '\n - Processing %s (%d of %d)', monks{i}, i, numel(monks) );
  one_monk = x_y.only( monks{i} );
  file_names = unique( one_monk{1}('file_names') );
  for k = 1:numel( file_names )
    fprintf( '\n\t - Processing %s (%d of %d)' ...
      , file_names{k}, k, numel(file_names) );
    one_file = one_monk.only( file_names{k} );
    inds = one_file{1}.get_indices( within );
    roi = looking_coordinates_mult_images( file_names{k}, monks{i}, region ...
      , coords_file );
    roi = roi_struct_to_double( roi );
    for j = 1:numel(inds)
      extr = one_file.keep( inds{j} );
      extr_x = extr.x;
      extr_y = extr.y;
      prop = hannah__proportion_in_bounds( extr_x, extr_y, roi );
      proportion = proportion.append( prop );
    end
  end
end

end

function dbl = roi_struct_to_double( roi )
dbl = [ roi.minX, roi.maxX, roi.minY, roi.maxY ];
end