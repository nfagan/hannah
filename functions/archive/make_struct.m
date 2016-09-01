% make_struct.m - helper function for transforming the raw cell-array
% output of fiveHTP_Test_Analysis... script such that each data label has a
% name associated with it.

function struct_labels = make_struct(labels,label_names)

if size(labels,2) ~= length(label_names)
    error('The number of original data labels and new data label names must match');
end

struct_labels = struct();
for i = 1:length(label_names)
    struct_labels.(label_names{i}) = labels{i};
end

