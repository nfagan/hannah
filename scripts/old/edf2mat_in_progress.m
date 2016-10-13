edf_path = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/check_for_dups';
cd(edf_path);

edf_dir = dir('*.edf');
edf_file_name = edf_dir(1).name;

edf0 = Edf2Mat(edf_dir(1).name); % load ef file

edf_file_name = edf_file_name(1:end-4); % remove file extension

%% efix

efix_file = horzcat(edf0.Events.Efix.start',edf0.Events.Efix.end',edf0.Events.Efix.duration',...
    edf0.Events.Efix.posX',edf0.Events.Efix.posY',edf0.Events.Efix.pupilSize');

save_efix_name = sprintf('Efix %s.xls',edf_file_name);
xlswrite(save_efix_name,efix_file);

%% get data flags and image names
    % alternatively, you could define all_images manually like this:
    % all_images = {'ubil','ubdn',...};

messages = lower(edf0.Events.Messages.info');  % get all data flags
                                        
                                        % non scrambled + non outdoor
                                        % images start with U and are 4
                                        % characters -- look for them here
expression_images = unique(cellfun(@(x) lower(x(1:4)),messages,'UniformOutput',false));
first_letter_ind = strncmpi(expression_images,'u',1);
expression_images (~first_letter_ind) = [];

other_images = {'outdoors';'scrambled'};    % add scrambled + outdoor images

all_images = cat(1,expression_images,other_images);

%%

images = struct(...
    'ubdl',1, ...
    'ubdn',2, ...
    'ubds',3, ...
    'ubdt',4, ...
    'ubil',5, ...
    'ubin',6, ...
    'ubis',7, ...
    'ubit',8, ...
    'ugdl',9, ...
    'ugdn',10, ...
    'ugds',11, ...
    'ugdt',12, ...
    'ugil',13, ...
    'ugin',14, ...
    'ugis',15, ...
    'ugit',16, ...
    'outdoors',17, ...
    'scrambled',18 ...
);

all_images = fieldnames(images);

%% get times per image

time = edf0.Events.Messages.time';

store_times = []; store_labels = []; store_code = [];
for i = 1:length(all_images);
    current_image = all_images{i};
    current_image_index = strcmp(messages,current_image);
    
    times_per_image = num2cell(time(current_image_index));
    image_code = images.(all_images{i});
    image_code = repmat({image_code},size(times_per_image,1),1);
    image_labels = repmat({current_image},size(times_per_image,1),1);
    
    store_labels = [store_labels;image_labels];
    store_times = [store_times;times_per_image];
    store_code = [store_code;image_code];
end

store_labels(:,2) = store_times; store_labels(:,3) = store_code;


%%



% edit name
time = num2cell(edf0.Events.Messages.time);
Info = horzcat(edf0.Events.Messages.info',time');
% t_name = 'Info NeC0306.xls';
% t_name = 'Info test.xls';
% xlswrite(t_name, Info);

actual_time = [];