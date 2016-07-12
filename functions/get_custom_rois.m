%   reference_rois is necessary to copy the data-structure of the per-image
%   rois. Technically, reference_rois can be roi_data, image_times, or any
%   nested-cell array in which the first (outer) level corresponds to
%   session, and the second (inner) level corresponds to an image
%   presentation.

function output_rois = get_custom_rois(pos,reference_rois)

reference_rois_formatting_error = ...
    sprintf(['The reference data structure must be a nested cell array with two levels, the first' ...
        , ' corresponding to session, and the second to an image presentation.']);

if ~iscell(reference_rois)
    error(reference_rois_formatting_error);
end

if ~isstruct(pos)
    error('pos must be a struct with minX, maxX, minY and maxY fields');
end

% - 
% for each session & for each image, store a new structure with the fields
% and corresponding values of 'pos'
% -

pos_fields = fieldnames(pos);
output_rois = cell(size(reference_rois));
for i = 1:length(reference_rois)
    rois = cell(size(reference_rois{i},1),1);
    for k = 1:length(reference_rois{i})
        for j = 1:length(pos_fields)
            rois{k}.(pos_fields{j}) = pos.(pos_fields{j});
        end
    end
    output_rois{i} = rois;
end
