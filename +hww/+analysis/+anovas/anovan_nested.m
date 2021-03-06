function data_struct = anovan_nested( obj, groups, nesting_matrix )

labels = labels_for_anova( obj, groups );

anova_opts = { 'varnames', groups, 'model', 'full', 'display', 'off' ...
  , 'nested', nesting_matrix };
mult_opts = { 'dimension', 1:numel(groups), 'display', 'off' };

[~, tbl, stats] = anovan( obj.data, labels, anova_opts{:} );
[c, ~, ~, gnames] = multcompare( stats, mult_opts{:} );

data = struct();
for i = 1:numel(groups)
  data.effects.(groups{i}).means = obj.do( groups{i}, @mean );
  data.effects.(groups{i}).devs = obj.do( groups{i}, @std );
end

data.effects.interaction.mean = obj.do( groups, @mean );
data.effects.interaction.dev = obj.do( groups, @std );

data.comparisons = c;
data.group_names = gnames;

data_struct = struct( 'table', {tbl}, 'descriptives', data );



end