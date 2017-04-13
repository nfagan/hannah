function labels = labels_for_anova( obj, groups )

groups = Labels.ensure_cell( groups );

labs = obj.labels.full();
labs = labs.get_fields( groups );
labels = cell(1, numel(groups) );
for i = 1:numel( groups )
  labels{i} = labs(:, i);
end

end