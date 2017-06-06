function data_struct = anovan( obj, groups, varargin )

defaults.dimension = 1:numel( groups );

params = parsestruct( defaults, varargin );

labels = labels_for_anova( obj, groups );

anova_opts = { 'varnames', groups, 'model', 'full', 'display', 'off' };
mult_opts = { 'dimension', params.dimension, 'display', 'off' };

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