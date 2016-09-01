function new_obj = concat_data_obj(varargin)

first_obj = varargin{1};

label_fields = fieldnames(first_obj.labels);

new_obj.data = [];
new_obj.labels = struct([]);

for i = 1:length(varargin)
    to_concat = varargin{i};
    new_obj.data = vertcat(new_obj.data,to_concat.data);
    
    for j = 1:length(label_fields)
        new_obj.labels.(label_fields{j}) = vertcat(new_obj.labels.(label_fields{j}),to_concat.labels.(label_fields{j}));
    end
end