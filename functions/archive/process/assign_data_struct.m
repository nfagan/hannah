function output_values = assign_data_struct(values,labels,values_to_assign,varargin)

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
        matches_current_label = false(length(values),1);
        current_labels = labels.(current_field);
        if ischar(current_labels{1})
            for k = 1:length(desired_labels)
                matches_current_label = matches_current_label | ...
                    strcmp(current_labels,desired_labels{k});
            end
        else % if labels are a cell array of integers (block number, etc.)
            for k = 1:length(desired_labels)
                matches_current_label = matches_current_label | ...
                    current_labels == desired_labels{k};
            end
        end
    else
        matches_current_label = true(length(values),1);
    end
    use_index = use_index & matches_current_label;
end

if sum(use_index) > size(values_to_assign,1)
    error('There are more values to assign than were passed as input to this function.');
elseif sum(use_index) < size(values_to_assign,1)
    error('There are fewer values to assign than were passed as input to this function.');
end

output_values = values;
output_values(use_index) = values_to_assign;
% output_labels = labels;
% for i = 1:length(label_fields);
%     output_labels.(label_fields{i})(~use_index) = [];
% end




