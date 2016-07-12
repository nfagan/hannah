function edf2mat_multiple_rois(varargin)

% - 
% define global variables
% -

params = struct( ... % use to allow overwriting old .mat files. you will still be asked if you wish to overwrite a file.
    'loadEdfIfMatExists',false, ...
    'askToOverwrite',true ...
    );
params = structInpParse(params,varargin);

base_edf_path = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/edfs';
save_path = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/processed_mat_files_new_rois';

monkeys = {'ephron','hitch'};
doses = {'low','high','saline'};

roi_coordinates_excel_file = ...
    '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/roi_coordinates/ROI Coordinates_one_sheet_2.xlsx';
coordinates_and_labels = load_excel_roi_coordinates(roi_coordinates_excel_file);

image_extensions = {'.jpg'};        % image urls are found by their extensions; if there are more
                                    % extensions than .jpg, add them here
regions = {'face','eyes','mouth','image'};

image_presentation_length = 5000; % ms

default_rois.minX = -10e3; default_rois.maxX = 10e3;    % debug fallback in case image is not found in excel file
default_rois.minY = -10e3; default_rois.maxY = 10e3;
default_roi_fields = fieldnames(default_rois);

% -
% manually define scrambled + outdoors rois
% - 

for i = 1:length(regions)
    outdoor_rois.(regions{i}).minX = -10e3;
    outdoor_rois.(regions{i}).maxX = 10e3;
    outdoor_rois.(regions{i}).minY = -10e3;
    outdoor_rois.(regions{i}).maxY = 10e3;
    
    scrambled_rois.(regions{i}).minX = -10e3;
    scrambled_rois.(regions{i}).maxX = 10e3;
    scrambled_rois.(regions{i}).minY = -10e3;
    scrambled_rois.(regions{i}).maxY = 10e3;
end

roi_fieldnames = fieldnames(outdoor_rois.(regions{1}));

% -
% get .mat file names to avoid processing old files
% -

cd(save_path); mat_files = dir('*.mat'); mat_file_names = {mat_files(:).name};

for monks = 1:length(monkeys)
    fprintf('\nIn monkey directory %d of %d (%s)',monks,length(monkeys),monkeys{monks});
    for ds = 1:length(doses) 
        fprintf('\n\tIn dose directory %d of %d (%s)',ds,length(doses),doses{ds});
        
        % -
        % specify current monkey/dose folder and list edf files within
        % -
        
        full_edf_path = fullfile(base_edf_path,monkeys{monks},doses{ds});
        cd(full_edf_path); 
        
        edf_dir = dir('*.edf');     
                                    
        for edfs = 1:length(edf_dir)
            edf_file_name = edf_dir(edfs).name;
            fprintf('\n\t\tProcessing file %d of %d (%s)',edfs,length(edf_dir),edf_file_name);
            session_id = edf_file_name(1:end-4);    % remove file extension
            
            % -
            % check whether current edf file has already been processed
            % - 
            
            session_id_exists_in_mat_file = ...
                sum(cellfun(@(x) ~isempty(strfind(x,session_id)),mat_file_names)) >= 1;
            
            if ~session_id_exists_in_mat_file || params.loadEdfIfMatExists;

                edf0 = Edf2Mat(edf_file_name);          % load edf file

                % - 
                % get date of current file, and store file name as the session
                % id
                % -

                day_and_session = session_id(~isstrprop(session_id,'alpha'));

                day = day_and_session(1:4);
                session = day_and_session;

                % - 
                % image times
                % - 

                messages = lower(edf0.Events.Messages.info');   % all data flags
                time = edf0.Events.Messages.time';              % time of each data flag

                % - 
                % parse image urls to get image file name
                % -

                is_image_url = false(length(messages),1);

                for i = 1:length(image_extensions)
                    is_image_url = strcmpln(messages,image_extensions{i},length(image_extensions{i})) ...
                        | is_image_url;
                end

                image_urls = messages(is_image_url);

                backslash_ind = cellfun(@(x) strfind(x,'\'),image_urls,'UniformOutput',false);
                period_ind = cellfun(@(x) strfind(x,'.'),image_urls,'UniformOutput',false);

                img_file_names = cell(size(image_urls)); image_categories = cell(size(image_urls));
                for i = 1:length(backslash_ind)
                    img_file_names{i} = image_urls{i}(backslash_ind{i}+1:period_ind{i}-1);
                    image_categories{i} = image_urls{i}(1:backslash_ind{i}-1);
                end

                out_imgs = strncmpi(img_file_names,'out',3);    % out and scrambled images aren't currently
                scr_imgs = strncmpi(img_file_names,'scr',3);    % in the ROI coordinates excel file, so we must
                                                                % define them manually, for now

                % - 
                % get image presentation times
                % - 

                image_times = time(is_image_url);       %   image start time
                image_times(:,2) = image_times + image_presentation_length; % image end time

                % -
                % get pos boundaries for each image file name
                % -

                for i = 1:length(regions) % preallocate
                    rois.(regions{i}) = cell(size(img_file_names));
                end

                stp = 1; could_not_find = [];   % for debugging -- check which images
                                                % were not found in the
                                                % excel file
                for i = 1:length(regions)
                    for k = 1:length(img_file_names)
                        if out_imgs(k) % define outdoor image rois manually
                            for j = 1:length(roi_fieldnames)
                                rois.(regions{i}){k}.(roi_fieldnames{j}) = ...
                                    outdoor_rois.(regions{i}).(roi_fieldnames{j});
                            end
                        elseif scr_imgs(k) % define scrambled image rois manually
                            for j = 1:length(roi_fieldnames)
                                rois.(regions{i}){k}.(roi_fieldnames{j}) = ...
                                    scrambled_rois.(regions{i}).(roi_fieldnames{j});
                            end
                        else    
                            try
                                rois.(regions{i}){k} = ...
                                    looking_coordinates_mult_images(img_file_names{k},regions{i},coordinates_and_labels);
                            catch
                                fprintf('\n\t\tWARNING: Could not find ''%s'' in ''%s''. Using default roi coordinates', ...
                                    img_file_names{k},edf_file_name);
                                for j = 1:length(default_roi_fields);
                                    rois.(regions{i}){k}.(default_roi_fields{j}) = ...
                                        default_rois.(default_roi_fields{j});
                                end
                                could_not_find{stp} = img_file_names{k}; stp = stp+1;
                            end
                        end
                    end
                end

                % - 
                % efix events
                % -     

                efix_file = horzcat(edf0.Events.Efix.start',edf0.Events.Efix.end',edf0.Events.Efix.duration',...
                    edf0.Events.Efix.posX',edf0.Events.Efix.posY',edf0.Events.Efix.pupilSize');                
                
                % -
                % pupil size
                % - 
                
                pupil_size = [edf0.Samples.time edf0.Samples.pupilSize];

                % - 
                % save all outputs as an image_data .mat variable
                % -     

                image_data.data.fix_events = efix_file;
                image_data.data.pupil_size = pupil_size;
                image_data.data.rois = rois;
                image_data.data.time = image_times;

                % - 
                % data labeling
                % -

                image_data.labels.day = repmat({day},size(image_categories,1),1);
                image_data.labels.session = repmat({session},size(image_categories,1),1);
                image_data.labels.file_names = img_file_names;
                image_data.labels.category = image_categories;
                image_data.labels.monkey = repmat({monkeys{monks}},size(image_categories,1),1);
                image_data.labels.dose = repmat({doses{ds}},size(image_categories,1),1);

                %%% special case for rois, since there are multiple

                for i = 1:length(regions)
                    image_data.labels.rois.(regions{i}) = repmat({regions{i}},size(image_categories,1),1);
                end
                
                %%% get genders, expressions and gaze based on image categories
                    % these categories have 4 characters
                
                % gender
                genders = cell(size(image_categories));
                proper_length_index = cellfun(@(x) length(x) == 4,image_categories);
                female_index = cellfun(@(x) x(2) == 'g',image_categories) & proper_length_index;
                male_index = cellfun(@(x) x(2) == 'b',image_categories) & proper_length_index;
                
                if (sum(female_index) + sum(male_index) + sum(~proper_length_index)) ~= length(image_categories)
                    error('gender lengths don''t match')
                end
                
                genders(female_index,:) = {'female'};
                genders(male_index,:) = {'male'};
                genders(~proper_length_index,:) = {'na'};
                
                % expression
                expressions = cellfun(@(x) x(4),image_categories,'UniformOutput',false);
                expressions(~proper_length_index,:) = {'na'};
                
                % gaze
                gaze = cell(size(image_categories));
                direct_index = cellfun(@(x) x(3) == 'd',image_categories) & proper_length_index;
                indirect_index = cellfun(@(x) x(3) == 'i',image_categories) & proper_length_index;
                
                gaze(direct_index,:) = {'direct'};
                gaze(indirect_index,:) = {'indirect'};
                gaze(~proper_length_index,:) = {'na'};
                
                if (sum(direct_index) + sum(indirect_index) + sum(~proper_length_index)) ~= length(image_categories)
                    error('gender lengths don''t match')
                end
                
                image_data.labels.genders = genders;
                image_data.labels.expressions = expressions;
                image_data.labels.gazes = gaze;

                % - actual saving

                save_img_data_name = sprintf('ImageData %s_new.mat',session_id);
                full_save_path = fullfile(save_path,save_img_data_name);

                if exist(full_save_path,'file') == 2 && params.askToOverwrite;
                    prompt = sprintf(['''%s'' already exists in the current folder.' ...
                        , ' Do you wish to overwrite it? (Y/N)'],save_img_data_name);
                    check_to_overwrite = input(prompt);
                    if strcmpi(check_to_overwrite,'y')
                        save(full_save_path,'image_data');
                    end
                else
                    save(full_save_path,'image_data');
                end
            else
                fprintf('\n\t\t\tSkipping %s because it already exists in the save_path',edf_file_name);
            end
        end
    end
end













