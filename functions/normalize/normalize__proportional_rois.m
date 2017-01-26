function [obj, kept] = normalize__proportional_rois( obj, within, varargin )

params = struct( ...
  'rois', {{ 'mouth' }}, ...
  'denominatorRoi', 'face' ...
);
params = parsestruct( params, varargin );
convert_to_obj = false;

if ( nargin < 2 ), within = { 'file_names', 'doses', 'monkeys' }; end;
if ( isa(obj, 'DataObject') ), obj = obj.to_container(); convert_to_obj = true; end;
assert( all(obj.contains(params.rois)), ['At least one of the specified' ...
  , ' rois (above) is not in the object'] );

inds = obj.get_indices( within );
excel_rois = load_excel_roi_coordinates();
kept = true( shape(obj,1), 1 );

for i = 1:numel(inds)
  fprintf( '\n ! normalize__proportional_rois: Processing %d of %d', i, numel(inds) );
  
  extr = obj(inds{i});
  first_roi_data = extr.only( params.rois{1} );
  
  if ( isempty(first_roi_data) ), kept(inds{i}) = false; continue; end;
  
  file_name = first_roi_data( 'file_names' );
  monkey = first_roi_data( 'monkeys' );
  
  first_roi = looking_coordinates_mult_images( file_name{1}, monkey{1}, ...
    params.rois{1}, excel_rois );
  denominator_roi = looking_coordinates_mult_images( file_name{1}, monkey{1}, ...
    params.denominatorRoi, excel_rois );
  
  first_area = get_area( first_roi );
  denominator_area = get_area( denominator_roi );
  prop = first_area / denominator_area;
  
  obj.data(inds{i}) = obj.data(inds{i}) / prop;
end

obj = obj(kept);

if ( convert_to_obj )
  obj = obj.to_data_object();
end

end

function area = get_area( roi )

area = (roi.maxX - roi.minX) * (roi.maxY - roi.minY);

end