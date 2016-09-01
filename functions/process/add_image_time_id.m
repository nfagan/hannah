function obj = add_image_time_id(obj)

times = obj.data;
starttimes = unique(times(:,1));
labelfields = obj.label_fields;

ids = cell(size(obj.labels.(labelfields{1}),1),1);

for i = 1:length(starttimes)
    
    ind = times(:,1) == starttimes(i);
    
    ids(ind) = {num2str(i)};
    
end

labels = obj.labels;
labels.ids = ids;
labelfields{end+1} = 'ids';

obj.labels = labels;
obj.label_fields = labelfields;



end



