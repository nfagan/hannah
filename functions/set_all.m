function labels = set_all(labels,field,val)

possible_fields = fieldnames(labels);

if ~any(strcmpi(possible_fields,field))
    error('The desired field (%s) is not present in the labels struct',field);
end

labels.(field) = repmat({val},size(labels.(field),1),1);

end

