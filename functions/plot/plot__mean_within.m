function plot__mean_within( currentMeasure, within, varargin )

params = struct( ...
    'manualOrder', true, ...
    'orders', struct( ...
        'monkeys', {{ 'ephron', 'kubrick', 'tarantino', 'lager', 'hitch', 'cron' }}, ...
        'doses', {{ 'low', 'high' }} ...
    ), ...
    'overlayMonkeyPoints', false, ...
    'xTick', 'auto' ...
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
xtick = 1:numel(means);

for i = 1:numel(indices)    
    extr = currentMeasure( indices{i} );
    
    if ( isempty(extr) ); continue; end;
    
    toLabel = combs(i,:);
    for k = 1:numel(toLabel)
        if ( k == 1 ); oneLabel = toLabel{1}; continue; end;
        oneLabel = sprintf( '%s %s', oneLabel, toLabel{k} );
    end
    
    if ( ~strcmp(params.xTick,'auto') ) && ( ~isempty(params.xTick) )
        if ( isa(params.xTick, 'DataObject') )
            matched = params.xTick.only( combs(i,:) );
            assert( ~isempty(matched), 'Could not find a match in the given xTick object' );
            xtick(i) = mean(matched.data(:,1));
        else
            assert( isa(params.xTick,'double'), ...
                'xTick params must be a DataObject or a double' );
%             assert( numel(params.xTick) == numel(xtick), ...
%                 'The number of elements for the xTick param is incorrect' );
%             xtick(i) = params.xTick(i);
        end
    else
        params.xTick = xtick;
    end
    
    labelPairs{i} = oneLabel;
    storeVectors{i} = struct();
    storeVectors{i}.data = extr.data(:,1);
    storeVectors{i}.monkeys = extr('monkeys');
    
    means(i) = mean( extr.data(:,1) );
    errors(i) = SEM( extr.data(:,1) );
end

xtick = params.xTick;
% xtick = [xtick; xtick];
% xtick = reshape(xtick, 1, numel(xtick));

figure;
errorbar( xtick, means, errors, 'linestyle','none', 'color', 'r' );
hold on;
bar( xtick, means, 'barwidth', 1 );

set( gca, 'xtick', xtick );
set( gca, 'xticklabels', labelPairs );

% d = 10;
% means = means(2:2:end);
% figure;
% scatter(xtick, means);
% 
% X = [xtick' means'];
% 
% idx = struct(); silh = struct(); distances = struct();
% for i = 1:4
%     iterString = ['iter' num2str(i)];
%     idx.(iterString) = kmeans(X, i, 'Distance', 'cityblock' );
%     silh.(iterString) = silhouette(X,idx.(iterString),'cityblock');
%     distances.(iterString) = mean(silh.(iterString));
% end

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