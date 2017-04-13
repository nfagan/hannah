function [within_quadrants, within_eyes] = hannah__mark_quadrants( x, y )

coords_file = load_excel_roi_coordinates();
combined = Structure( 'x', x, 'y', y );
combined = combined.enumerate( 'monkeys' );

within_quadrants = x;
within_eyes = x;

w_quad_data = within_quadrants.data;
w_eyes_data = within_eyes.data;

for i = 1:numel( combined{1} )
  fprintf( '\n - Processing %d of %d', i, numel(combined{1}) );
  files = unique( combined.x{i}( 'file_names' ) );
  current = combined.each( @subsref, struct('type', '{}', 'subs', {{i}}) );
  for k = 1:numel( files )
    fprintf( '\n\t - Processing %d of %d', k, numel(files) );
    file = files{k};
    extr = current.only( file );
    x = extr.x;
    y = extr.y;
    monk = char( unique(x('monkeys')) );
    roi = looking_coordinates_mult_images( file, monk, 'image', coords_file );
    quads = get_roi_quadrants( roi );
    bounds = zeros( size(x.data) );
    for j = 1:numel(quads)
      quad = quads{j};
      is_within_x = x.data >= quad(1) & x.data <= quad(2);
      is_within_y = y.data >= quad(3) & x.data <= quad(4);
      bounds( is_within_x & is_within_y ) = j;
    end
    ind = full( within_quadrants.where( {file, monk} ) );
    w_quad_data(ind, :) = bounds;
    % now get the eye roi
    roi = looking_coordinates_mult_images( file, monk, 'eyes', coords_file );
    bounds = zeros( size(x.data) );
    is_within_x = x.data >= roi.minX & x.data <= roi.maxX;
    is_within_y = y.data >= roi.minY & y.data <= roi.maxY;
    bounds( is_within_x & is_within_y ) = 1;
    w_eyes_data(ind, :) = bounds;
  end
end

within_quadrants.data = w_quad_data;
within_eyes.data = w_eyes_data;

end

function quads = get_roi_quadrants( roi )

quads = cell( 1, 4 );
half_x = ( (roi.maxX-roi.minX)/2 ) + roi.minX;
half_y = ( (roi.maxY-roi.minY)/2 ) + roi.minY;

quads{1} = [ half_x, roi.maxX, half_y, roi.maxY ];
quads{2} = [ roi.minX, half_x, half_y, roi.maxY ];
quads{3} = [ roi.minX, half_x, roi.minY, half_y ];
quads{4} = [ half_x, roi.maxX, roi.minY, half_y ];

% quads{1} = [ roi.minX, half_x, half_y, roi.maxY ];
% quads{2} = [ half_x, roi.maxX, half_y, roi.maxY ];
% quads{3} = [ roi.minX, half_x, roi.minY, half_y ];
% quads{4} = [ half_x, roi.maxX, roi.minY, half_y ];

end