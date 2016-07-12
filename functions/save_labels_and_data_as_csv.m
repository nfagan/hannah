function save_labels_and_data_as_csv(data_obj,filename)

labels_file_name = sprintf('%s_labels.csv',filename);
data_file_name = sprintf('%s_data.csv',filename);

data = data_obj.data;
labels = data_obj.labels;
label_fields = fieldnames(labels);

data_cell = cell(size(labels.(label_fields{1}),1)+1,length(label_fields));
for i = 1:length(label_fields)
    data_cell(2:end,i) = labels.(label_fields{i});
end
data_cell(1,:) = label_fields;

fid = fopen(labels_file_name ,'w');
for i = 1:size(data_cell,1);
    fprintf(fid,'%s,',data_cell{i,1:end-1});
    fprintf(fid,'%s\n',data_cell{i,end});
end
fclose(fid);

dlmwrite('test_values.csv',data);





