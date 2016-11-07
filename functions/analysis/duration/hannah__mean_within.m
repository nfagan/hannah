function store = hannah__mean_within(obj, varargin)

params = struct( ...
    'magnitudeChange', false, ...
    'within', {{ 'images', 'doses', 'sessions', 'monkeys' }} ...
    );

params = parsestruct( params, varargin );

within = params.within;

if ( params.magnitudeChange )
    obj.data = abs( obj.data - 1 );
end

indices = obj.getindices( within );

% assert( numel(obj.uniques('images')) == 2, 'More than two image-types in the object' );

store = DataObject();

for i = 1:numel(indices)
    matrix = zeros( 1, 2 );
    
    extr = obj(indices{i}); 
    extr = extr.collapse( extr.fieldnames('-except', within) );
    
    extr = extr(~isnan(extr)); inf_ind = isinf(extr.data);
    extr = extr(~inf_ind);
    
    if ( isempty(extr) ); continue; end;
    
    matrix(1) = mean( extr.data );
    matrix(2) = SEM( extr.data );
    
    labels = extr(1);
    labels = labels.labels;
    
    store = store.append( DataObject(matrix, labels) );
end


end