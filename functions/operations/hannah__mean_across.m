function meaned = hannah__mean_across(obj, across)

within = obj.fieldnames( '-except', across );
indices = getindices( obj, within );

meaned = DataObject();

for i = 1:numel(indices)    
    tomean = obj( indices{i} );
    
    tomean = tomean.collapse( across );
    
    data = mean(tomean);
    labels = tomean(1); labels = labels.labels;
    
    meaned = meaned.append( DataObject(data, labels) );
end



end