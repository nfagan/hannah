function file = load_save_field(filename,save_field_name)

if nargin < 2
    save_field_name = 'save_field';
end

file = load(filename);

save_field = fieldnames(file);
if length(save_field) > 1
    return;
else file = file.(save_field_name);
end

end

