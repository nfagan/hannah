function raw_plots()

%%  load

looks = hww.io.load_sparse_measures( 'lookdur' );
looks = looks.only( 'image' );

savepath = fullfile( pathfor('plots'), '051817', 'lookdur', 'raw' );
if ( exist(savepath, 'dir') ~= 7 ), mkdir( savepath ); end;

pl = ContainerPlotter();

%%  plot s l h 

meaned = looks.do( 'sessions', @mean );
meaned = meaned.do( {'monkeys', 'doses'}, @mean );
labs = meaned.full();
labs = labs.labels;
doses = labs.get_fields( 'doses' );
monks = labs.get_fields( 'monkeys' );
ordering = { 'saline', 'low', 'high' };
num_doses = zeros( size(doses) );
f1 = figure; hold on;
for i = 1:numel(ordering)
  num_doses( strcmp(doses, ordering{i}) ) = i;
end
h = gscatter( num_doses, meaned.data, monks );
boxplot( meaned.data, num_doses );
set( gca, 'xtick', unique(num_doses) );
set( gca, 'xticklabels', ordering );
set( h, 'markersize', 22 );

xlims = get( gca, 'xlim' );
ylims = get( gca, 'ylim' );

f2 = figure;
pl.default();
pl.order_by = { 'saline', 'low', 'high' };
h = pl.plot_by( meaned, 'doses', 'monkeys', [] );
set( h, 'xlim', xlims );
set( h, 'ylim', ylims );

filename = 'saline_vs_low_vs_high_box.eps';
saveas( f1, fullfile(savepath, filename), 'epsc' );
filename = 'saline_vs_low_vs_high_lines.eps';
saveas( f2, fullfile(savepath, filename), 'epsc' );

means = meaned.do( {'doses', 'monkeys'}, @mean );
devs = meaned.do( {'doses', 'monkeys'}, @std );


end