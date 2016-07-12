function outputLabels = concat_labels(labels)

outputLabels = cell(1,length(labels{1}));
for i = 1:length(labels{1});
    for k = 1:length(labels);
        outputLabels{i} = [outputLabels{i};labels{k}{i}];
    end
end
    