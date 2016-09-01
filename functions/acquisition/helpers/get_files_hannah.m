function [output_files,day_data] = get_files_hannah(data_dir)

% necessary_file_types = {'time','efix','imagedata'};
% necessary_file_types = {'time','efix'};
necessary_file_types = {'imagedata'};
% data_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/fixed_dups_data/ephron/high';

data_files = remDir(rid_super_sub_folder_references(dir(data_dir)));
data_file_names = {data_files(:).name};
data_file_names = data_file_names(~strcmp(data_file_names,'.DS_Store'));

ids = cell(size(data_file_names)); file_types = cell(size(data_file_names));
for i = 1:length(data_file_names)
    space_index = strfind(data_file_names{i},' ');
    period_index = strfind(data_file_names{i},'.');
    if isempty(space_index) || isempty(period_index)
        error('Invalid id format for file %s',data_file_names{i});
    end
    ids{i} = data_file_names{i}(space_index+1:period_index-1);
    file_types{i} = lower(data_file_names{i}(1:space_index-1));
end
ids = unique(ids);

output_files = cell(size(ids));
for i = 1:length(ids)
    matches_id_ind = cellfun(@(x) ~isempty(strfind(x,ids{i})),data_file_names);
    current_file_names = data_file_names(matches_id_ind);
    if length(necessary_file_types) > length(current_file_names)
        error('The current id (%s) is missing one or more files (efix, time, or image data)',ids{i});
    end
    
    for k = 1:length(necessary_file_types)
        current_file = ...
            current_file_names(strncmpi(current_file_names,necessary_file_types{k},length(necessary_file_types{k})));
        if length(current_file) > 1
            error(['There are multiple files that correspond to the current id (%s).' ...
                , ' Remove the duplicates before proceeding.'],ids{i});
        end
        current_file = current_file{1};
        path_to_file = fullfile(data_dir,current_file);
        if strcmpln(current_file,'.xls',4) || strcmpln(current_file,'.xlsx',4)
            all_files.(necessary_file_types{k}) = xlsread(path_to_file);
        elseif strcmpln(current_file,'.mat',4)
            all_files.(necessary_file_types{k}) = load(path_to_file);
        end
    end
output_files{i} = all_files;
end

day_data = NaN;

% sessions = cellfun(@(x) x(~isstrprop(x,'alpha')),ids,'UniformOutput',false);
% unique_days = unique(cellfun(@(x) x(1:4),sessions,'UniformOutput',false));
%             
% day_labels = cell(size(sessions));
% for i = 1:length(unique_days)
%     current_day_index = strncmpi(sessions,unique_days{i},length(unique_days{i}));
%     day_labels(current_day_index) = {unique_days{i}};
% end
% 
% day_data.ids = ids; 
% day_data.day_labels = day_labels;



