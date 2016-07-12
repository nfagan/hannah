function [output_values, output_labels, use_index] = separate_data_struct_test(values,labels,varargin)

if ~isstruct(labels)
    error(['This separate_data function requires the data labels to be made into a struct.' ...
        , ' Use make_struct.m to convert the cell array labels to struct-form.']);
end

label_fields = fieldnames(labels);

if length(values) ~= length(labels.(label_fields{1}))
    error(['The lengths of the data and data-labels do not match. Possibly you are using' ...
        , ' the wrong data labels.']);
end     

for i = 1:length(label_fields)  % by default, assume we want all data associated with
                                % each label
    params.(label_fields{i}) = 'all';
end

params = structInpParse(params,varargin); % overwrite 'all' labels with desired labels

use_index = true(length(values),1);
for i = 1:length(label_fields)
    current_field = label_fields{i};
    if ~sum(strcmp(params.(current_field),'all'))
        desired_labels = params.(current_field);
        current_labels = labels.(current_field);
        include = false(length(values),1);
        remove = false(length(values),1);
        for k = 1:length(desired_labels)
            if ~strncmpi(desired_labels{k},'--',2)
                include(strcmpi(current_labels,desired_labels{k}),:) = true;
            else
                remove(strcmpi(current_labels,desired_labels{k}(3:end)),:) = true;
            end
        end
        
    else
        include = true(length(values),1);
        remove = false(length(values),1);
    end
    
    include(remove,:) = false;
    use_index = use_index & include;
end

output_values = values(use_index,:);
output_labels = labels;
for i = 1:length(label_fields);
    output_labels.(label_fields{i})(~use_index) = [];
end




