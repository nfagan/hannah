load_path = ...
  fullfile( pathfor('processedImageData'), '110716', 'sparse_measures_outliersremoved.mat' );
measures = load( load_path );
fields = fieldnames( measures );
measures = measures.( fields{1} );

orig = measures.lookdur;
orig = orig.only( 'image' );

anovas = Container();

%%
looks = orig;
looks = looks.do( 'sessions', @mean );

groups = { 'doses' };
labels = labels_for_anova( looks, groups );

[~, tbl, stats] = anovan( looks.data, labels, 'varnames', groups, 'model', 'full' );
[c, ~, ~, gnames] = multcompare( stats, 'dimension', 1:numel(groups) );

%%

means = looks.do( groups, @mean );
stds = looks.do( groups, @std );

dose_anova.comparisons = c;
dose_anova.group_names = gnames;

dose_anova.effects.doses.means = means;
dose_anova.effects.doses.devs = stds;

anova_labels.type = {'dose_only'};
data_struct = struct( 'table', {tbl}, 'descriptives', dose_anova );

anovas = anovas.append( Container(data_struct, anova_labels) );

cd ~/Desktop

save( 'dose_anova.mat', 'anovas' );
