% - 
% define global variables
% -

edf_path = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/check_for_dups';
save_path = edf_path;

images = struct(...     % Define image codes. We could do this automatically,
    'ubdt',     1, ...  % but at the expense of legibility / clarity
    'ubds',     2, ...
    'ubdn',     3, ...      
    'ubdl',     4, ...      
    'ubit',     5, ...
    'ubis',     6, ...
    'ubin',     7, ...
    'ubil',     8, ...
    'ugdt',     9, ...
    'ugdn',     10, ...
    'ugds',     11, ...
    'ugdl',     12, ...
    'ugit',     13, ...
    'ugis',     14, ...
    'ugin',     15, ...
    'ugil',     16, ...
    'scrambled',17, ...
    'outdoors', 18 ...
);

all_images = fieldnames(images);    % confirm that we've inputted the image names correctly

% -
% load in edf file
% -

cd(edf_path); 
edf_dir = dir('*.edf');     
                            % if wanting to loop through .edf files, start here:
                            % for k = 1:length(edf_dir)     
                            %   edf_file_name = edf_dir(k).name
edf_file_name = edf_dir(1).name;

edf0 = Edf2Mat(edf_file_name); % load edf file
edf_file_name = edf_file_name(1:end-4); % remove file extension

% - 
% image times
% - 

messages = lower(edf0.Events.Messages.info');   % all data flags
time = edf0.Events.Messages.time';              % time of each data flag

stp = 0; store_times = nan(1000,2); % arbitrarily huge since preallocation
                                    % speeds things up, and we don't know
                                    % how many images were presented
for i = 1:length(all_images)
    current_image = all_images{i};
    current_image_index = strcmp(messages,current_image);
    
    times_per_image = time(current_image_index);
    update_size = size(times_per_image,1);
                                            % store an image code for as
                                            % many images exist / were
                                            % presented
    code_per_image = repmat(images.(all_images{i}),update_size,1);
    
    store_times(stp+1:stp+update_size,:) = [code_per_image times_per_image];
    stp = stp + update_size;
    
end

store_times(isnan(store_times(:,1)),:) = []; % get rid of excess nans

% - 
% efix events
% - 

efix_file = horzcat(edf0.Events.Efix.start',edf0.Events.Efix.end',edf0.Events.Efix.duration',...
    edf0.Events.Efix.posX',edf0.Events.Efix.posY',edf0.Events.Efix.pupilSize');

% - 
% save Time and Efix files
% - 

save_efix_name = sprintf('Efix %s_new.xls',edf_file_name);
save_time_name = sprintf('Time %s_new.xls',edf_file_name);

xlswrite(fullfile(save_path,save_efix_name),efix_file);
xlswrite(fullfile(save_path,save_efix_name),store_times);

% end -- end the loop here
