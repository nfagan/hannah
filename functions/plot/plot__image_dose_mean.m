function h = plot__image_dose_mean( obj, varargin )

params = struct( ...
  'transpose', false, ...
  'save', false, ...
  'savePath', [], ...
  'formats', {{ 'epsc' }}, ...
  'yLims', [] ...
);
params = parsestruct( params, varargin );

if ( isa(obj, 'DataObject') ), obj = obj.to_container(); end;
assert( all(obj.contains_fields( {'images', 'doses'} )), ...
  'Required fields ''images'' and ''doses'' are missing' );

inds = obj.get_indices( {'images', 'doses'} );
images = unique( obj('images') );
doses = unique( obj('doses') );

matrix = zeros( numel(images), numel(doses) );
errors = zeros( size(matrix) );

for i = 1:numel(inds)
  extr = obj( inds{i} );
  one = extr(1);
  img = char( one('images') );
  dose = char( one('doses') );
  means = mean( extr.data );
  sems = SEM( extr.data );
  assert( numel(means) == 1, 'Data have too many columns' );
  row = strcmp( images, img );
  col = strcmp( doses, dose );
  matrix(row, col) = means;
  errors(row, col) = sems;
end

if ( params.transpose )
  matrix = matrix';
  legend_items = images; 
  xtick_items = doses;
else
  legend_items = doses; 
  xtick_items = images;
end

h = barwitherr( errors, matrix );
legend( legend_items );
set( gca, 'xtick', 1:numel(xtick_items) );
set( gca, 'xticklabels', xtick_items );

if ( ~isempty(params.yLims) ), ylim( params.yLims ); end;
if ( ~params.save || isempty(params.savePath) ), return; end;

for i = 1:numel( params.formats )
  saveas( gcf, params.savePath, params.formats{i} );
end

close gcf;

end