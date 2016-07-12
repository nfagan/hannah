function output_data = remove_zeros_from_data_struct(combined_data,fields_to_analyze)

if ~iscell(fields_to_analyze)
    error(['Wanted fields must be input into a cell array, comma-separated. If wanting' ...
        , ' all fields, use: {''all''}']);
end

data_fields = fieldnames(combined_data);

if any(strcmp(data_fields,'eyes'))
    error('Input data must be combined across rois before errors can be removed');
end

% - only adjust those data fields in fields_to_analyze, unless
% fields_to_analyze = 'all'

if ~strcmp(fields_to_analyze,'all');
    check_if_present_field = zeros(size(fields_to_analyze));
    for i = 1:length(fields_to_analyze)
        check_if_present_field(i) = any(cellfun(@(x) strcmp(x,fields_to_analyze{i}),data_fields));
    end
    if sum(check_if_present_field) ~= length(fields_to_analyze)
        error('At least one of the requested fields is not present in the inputted data structure.');
    end
    
    new_data_fields = cell(size(fields_to_analyze));
    for i = 1:length(fields_to_analyze)
        index_of_curr_data_field = strcmp(data_fields,fields_to_analyze{i});
        new_data_fields(i) = data_fields(index_of_curr_data_field);
    end
data_fields = new_data_fields;
end

label_fields = fieldnames(combined_data.(data_fields{1}).labels);
output_data = combined_data;

for i = 1:length(data_fields)
    values = combined_data.(data_fields{i}).data;
    
    % index based on zeros, nans, etc.
    
    error_index = values == 0 | isnan(values);
    
    % delete errors from values and labels
    
    output_data.(data_fields{i}).data(error_index,:) = [];
    
    for k = 1:length(label_fields)
        output_data.(data_fields{i}).labels.(label_fields{k})(error_index,:) = [];
    end
end