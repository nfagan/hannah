function output_data = add_expr_gaze_gender_labs(combined_data)

category_field_name = 'images';   %   important -- these might change over time, 
                                            %   and are hardcoded
gender_field_name = 'genders';
expression_field_name = 'expressions';
gaze_field_name = 'gazes';

output_data = combined_data;
data_fields = fieldnames(output_data);
labels = fieldnames(output_data.(data_fields{1}).labels);

if any(strcmp(data_fields,'eyes'))
    error('Use this function after combining data across rois')
end

for i = 1:length(data_fields)

image_categories = output_data.(data_fields{i}).labels.(category_field_name);
proper_length_index = cellfun(@(x) length(x) == 4,image_categories);

% gender
if ~any(strcmp(labels,gender_field_name));
    genders = cell(size(image_categories));
    female_index = cellfun(@(x) x(2) == 'g',image_categories) & proper_length_index;
    male_index = cellfun(@(x) x(2) == 'b',image_categories) & proper_length_index;

    if (sum(female_index) + sum(male_index) + sum(~proper_length_index)) ~= length(image_categories)
        error('gender lengths don''t match');
    end

    genders(female_index,:) = {'female'};
    genders(male_index,:) = {'male'};
    genders(~proper_length_index,:) = {'na'};
    
    output_data.(data_fields{i}).labels.(gender_field_name) = genders;
else
    fprintf('\nNot adding gender labels because they already exist');
end

% expression
if ~any(strcmp(labels,expression_field_name));
    expressions = cellfun(@(x) x(4),image_categories,'UniformOutput',false);
    expressions(~proper_length_index,:) = {'na'};
    
    output_data.(data_fields{i}).labels.(expression_field_name) = expressions;
else
    fprintf('\nNot adding expression labels because they already exist');
end

% gaze
if ~any(strcmp(labels,gaze_field_name));
    gaze = cell(size(image_categories));
    direct_index = cellfun(@(x) x(3) == 'd',image_categories) & proper_length_index;
    indirect_index = cellfun(@(x) x(3) == 'i',image_categories) & proper_length_index;

    gaze(direct_index,:) = {'direct'};
    gaze(indirect_index,:) = {'indirect'};
    gaze(~proper_length_index,:) = {'na'};

    if (sum(direct_index) + sum(indirect_index) + sum(~proper_length_index)) ~= length(image_categories)
        error('gender lengths don''t match');
    end
    
    output_data.(data_fields{i}).labels.(gaze_field_name) = gaze;
else
    fprintf('\nNot adding gaze labels because they already exist');
end

end

