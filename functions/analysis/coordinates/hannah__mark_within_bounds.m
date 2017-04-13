function within_bounds = hannah__mark_within_bounds( x, y, regions, or_v_and )

if ( nargin < 4 ), or_v_and = 'and'; end;

assert( isa(x, 'Container') && isa(y, 'Container') ...
  , 'Expected x and y to be Containers' );
assert( x.labels == y.labels, 'The label objects of x and y must equivalent' );
if ( ~iscell(regions) ), regions = { regions }; end;
coords_file = load_excel_roi_coordinates();
within_bounds = Container();
inds = cell( 1, numel(regions) );
for i = 1:numel(regions)
  one_region = per_region( x, y, regions{i}, coords_file );
  one_region( 'rois' ) = regions{i};
  if ( ~isequal(or_v_and, 'or') )
    within_bounds = within_bounds.append( one_region );
  else
    inds{i} = one_region.data == 1;
  end
end

if ( ~isequal(or_v_and, 'or') ), return; end;
within_bounds = one_region;
within_bounds.data = zeros( size(within_bounds.data) );
leftovers = true( size(inds{1}) );
for i = 1:numel(inds)
  within_bounds.data( inds{i} ) = i;
  leftovers = leftovers & ~inds{i};
end
% if ( any(leftovers) )
%   within_bounds.data( leftovers ) = { 'leftover_roi' };
% end
within_bounds( 'rois' ) = strjoin( regions, ',' );

end

function within_bounds = per_region( x, y, region, coords_file )

x_y = Structure( struct('x', x, 'y', y) );
monks = unique( x('monkeys') );
within_bounds = Container();
for i = 1:numel(monks)
  fprintf( '\n - Processing %s (%d of %d)', monks{i}, i, numel(monks) );
  one_monk = x_y.only( monks{i} );
  file_names = unique( one_monk{1}('file_names') );
  for k = 1:numel( file_names )
    fprintf( '\n\t - Processing %s (%d of %d)' ...
      , file_names{k}, k, numel(file_names) );
    one_file = one_monk.only( file_names{k} );
    roi = looking_coordinates_mult_images( file_names{k}, monks{i}, region ...
      , coords_file );
    roi = roi_struct_to_double( roi );
    is_within_bounds = hannah__is_within_bounds( one_file.x, one_file.y, roi );
    within_bounds = within_bounds.append( is_within_bounds );
  end
end

end

function dbl = roi_struct_to_double( roi )

dbl = [ roi.minX, roi.maxX, roi.minY, roi.maxY ];

end