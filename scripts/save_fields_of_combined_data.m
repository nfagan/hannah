fields = fieldnames(combined_data);

for i = 1:length(fields)
    save_field = combined_data.(fields{i});
    save([fields{i} '.mat'],'save_field'); 
end