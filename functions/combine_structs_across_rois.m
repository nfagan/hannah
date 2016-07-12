function output_data = combine_structs_across_rois(data)

rois = fieldnames(data);

if isempty(rois)
    error(['The input data structure is not properly formatted. The first level of data must be' ...
        , ' an roi (eyes, mouth, image, etc.)']);
end

data_fields = fieldnames(data.(rois{1}));

if isempty(data_fields)
    error(['The input data structure is not properly formatted. The second level of data must be' ...
        , ' a data-value field (e.g., lookingDuration, nSuccessfulTrials,etc.)']);
end

label_fields = fieldnames(data.(rois{1}).(data_fields{1}).labels);

% - quickly determine how long each vector will be, so that we can
% accurately preallocate

store_lengths = zeros(length(data_fields),length(rois));
for i = 1:length(data_fields)
    for k = 1:length(rois)
        store_lengths(i,k) = size(data.(rois{k}).(data_fields{i}).data,1);
    end
end

preallocate_sizes = sum(store_lengths,2);
output_data = struct();

for i = 1:length(data_fields)
    stp = 0;
    if ~iscell(data.(rois{1}).(data_fields{i}).data)
        store_values_across_rois = nan(preallocate_sizes(i),size(data.(rois{1}).(data_fields{i}).data,2));
    else
        store_values_across_rois = cell(preallocate_sizes(i),1);
    end
    for k = 1:length(label_fields)
        store_labels_across_rois.(label_fields{k}) = cell(preallocate_sizes(i),1);
    end
    for k = 1:length(rois)
        values_for_current_roi = data.(rois{k}).(data_fields{i}).data;
        labels_for_current_roi = data.(rois{k}).(data_fields{i}).labels;
        
        update_size = size(values_for_current_roi,1);
        store_values_across_rois(stp+1:stp+update_size,:) = values_for_current_roi;
        
        for j = 1:length(label_fields)
            store_labels_across_rois.(label_fields{j})(stp+1:stp+update_size,1) = labels_for_current_roi.(label_fields{j});
        end
        stp = stp + update_size;
    end
    output_data.(data_fields{i}).data = store_values_across_rois;
    output_data.(data_fields{i}).labels = store_labels_across_rois;
    
end

