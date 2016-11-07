function store = hannah__social_nonsocial_mean(obj, within)

if ( nargin < 2 )
    within = { 'images', 'doses', 'monkeys' };
end

% obj.data = abs( obj.data - 1 );

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