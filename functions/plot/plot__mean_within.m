function plot__mean_within( currentMeasure, within, varargin )

params = struct( ...
    'manualOrder', true, ...
    'orders', struct( ...
        'monkeys', {{ 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' }}, ...
        'doses', {{ 'low', 'high' }} ...
    ), ...
    'overlayMonkeyPoints', false ...
);

params = parsestruct( params, varargin );

if params.manualOrder
    [indices, combs] = get_manual_combs_and_indices( currentMeasure, params );
else [indices, combs] = getindices( currentMeasure, within );
end

means = zeros( 1, numel(indices) );
errors = zeros( size(means) );
labelPairs = cell( size(means) );
storeVectors = cell( size(means) );

for i = 1:numel(indices)    
    extr = currentMeasure( indices{i} );
    
    if ( isempty(extr) ); continue; end;
    
    toLabel = combs(i,:);
    for k = 1:numel(toLabel)
        if ( k == 1 ); oneLabel = toLabel{1}; continue; end;
        oneLabel = sprintf( '%s %s', oneLabel, toLabel{k} );
    end
    
    labelPairs{i} = oneLabel;
    storeVectors{i} = struct();
    storeVectors{i}.data = extr.data(:,1);
    storeVectors{i}.monkeys = extr('monkeys');
    
    means(i) = mean( extr.data(:,1) );
    errors(i) = SEM( extr.data(:,1) );
end

figure;
errorbar( means, errors, 'linestyle','none', 'color', 'r');
hold on;
bar( means );

set( gca, 'xtick', 1:numel(means) );
set( gca, 'xticklabels', labelPairs );

if ( params.overlayMonkeyPoints )
    for i = 1:numel(storeVectors)
        for k = 1:numel(storeVectors{i}.data)
            color = get_monkey_color_map( storeVectors{i}.monkeys{k} );
            color = [color '*'];
            plot(i, storeVectors{i}.data(k), color, 'linewidth', .1);
        end
    end
end

end

function [indices, combs] = get_manual_combs_and_indices( obj, params )

fields = fieldnames( params.orders );
orders = cell( 1, numel(fields) );
for i = 1:numel(fields)
    orders{i} = params.orders.(fields{i});
end
combs = allcomb( orders );
indices = cell( size(combs,1), 1 );
for i = 1:numel(indices)
    indices{i} = obj.where( combs(i,:) );
end

end

function color = get_monkey_color_map( monkey )

map = struct( ...
    'hitch', 'r', ...
    'cron', 'b', ...
    'kubrick', 'k', ...
    'ephron', 'y', ...
    'tarantino', 'g', ...
    'lager', 'm' ...
);

monks = fieldnames( map );

if ~any( strcmp(monks, monkey) ); error('No color defined for %s', monkey ); end;

color = map.(monkey);

end