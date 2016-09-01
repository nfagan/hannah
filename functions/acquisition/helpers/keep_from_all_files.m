function all_files = keep_from_all_files(all_files,varargin)

if ~any(strcmp(varargin{1},'all'))

index_field = 'monkey';

empty_index = false(size(all_files));
for i = 1:length(all_files)
    data_obj = struct();
    data_obj.labels = all_files{i}.image_data.labels;
    label_fields = fieldnames(data_obj.labels);
    
    if ~any(strcmp(label_fields,index_field))
        error(['Fieldname ''%s'' is not in the labeling struct. Open up this function' ...
            , ' and define a new index field.'],index_field);
    end
    
    if strcmp(label_fields{1},'rois')
        data_obj.data = zeros(size(data_obj.labels.(label_fields{1}),1),1);
    else
        data_obj.data = zeros(size(data_obj.labels.('monkey'),1),1);
    end
    
    if any(strcmp(label_fields,'rois'))
        data_obj.labels = rmfield(data_obj.labels,'rois');
    end
    
    [~,ind] = separate_data_obj(data_obj,varargin{:});
    
    all_files{i} = data_field_indexing(all_files{i},'data',ind);
    all_files{i} = data_field_indexing(all_files{i},'labels',ind);
    
    if isempty(all_files{i}.image_data.labels.('monkey'))
        empty_index(i) = true;
    end
end

all_files(empty_index) = [];

end

end % end function

function all_files = data_field_indexing(all_files,type,ind)
data_or_label_fields = fieldnames(all_files.image_data.(type));
for k = 1:length(data_or_label_fields)
    current_field = all_files.image_data.(type).(data_or_label_fields{k});
    if ~isstruct(current_field)
        current_field = index(current_field,ind);
    else
        roi_fields = fieldnames(current_field);
        for j = 1:length(roi_fields)
            current_field.(roi_fields{j}) = index(current_field.(roi_fields{j}),ind);
        end
    end
    all_files.image_data.(type).(data_or_label_fields{k}) = current_field;
end
end

function indexed = index(field,ind)
    if length(field) == length(ind)
        indexed = field(ind,:);
    else
        indexed = field;
    end
end