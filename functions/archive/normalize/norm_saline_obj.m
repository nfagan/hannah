function obj = norm_saline_obj(obj)

if ~isa(obj,'DataObject')
    error('This function expects a data object as input');
end

monks = unique(obj.labels.monkeys);

for i = 1:length(monks)
    monk_ind = obj == monks{i};
    
    one_monk = obj(monk_ind);
    
    saline = mean(one_monk(one_monk == 'saline'));
    
    normed = obj(monk_ind) ./ saline;
    
    obj(monk_ind) = normed.data;
    
end