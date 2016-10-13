function edf2mat_multiple_rois_old_method(varargin)

% - 
% define global variables
% -

params = struct( ...
    'loadEdfIfMatExists',false ...
    );
params = structInpParse(params,varargin);

base_edf_path = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/edfs';
save_path = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/old_method';

monkeys = {'ephron','hitch'};
doses = {'low','high','saline'};

roi_coordinates_excel_file = ...
    '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/roi_coordinates/ROI Coordinates_one_sheet.xlsx';
coordinates_and_labels = load_excel_roi_coordinates(roi_coordinates_excel_file);

image_extensions = {'.jpg'};
regions = {'face','eyes','mouth'};

image_presentation_length = 5000; % ms

% -
% get .mat file names to avoid processing old files
% -


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
            
            full_save_path = fullfile(save_path,monkeys{monks},doses{ds});
            cd(full_save_path);
            
            mat_files = dir('*.mat'); mat_file_names = {mat_files(:).name};
            
            session_id_exists_in_mat_file = ...
                sum(cellfun(@(x) ~isempty(strfind(x,session_id)),mat_file_names)) >= 1;
            
            cd(full_edf_path);
            
            if ~session_id_exists_in_mat_file && ~params.loadEdfIfMatExists;

                edf0 = Edf2Mat(edf_file_name);          % load edf file

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

                stp = 1;
                for i = 1:length(regions)
                    for k = 1:length(img_file_names)
                        if out_imgs(k) % define outdoor image rois manually
                %             rois.(regions{i}){k} = NaN;
                            rois.(regions{i}){k}.minX = -10e3;
                            rois.(regions{i}){k}.maxX = 10e3;
                            rois.(regions{i}){k}.minY = -10e3;
                            rois.(regions{i}){k}.maxY = 10e3;
                        elseif scr_imgs(k) % define scrambled image rois manually
                %             rois.(regions{i}){k} = NaN;
                            rois.(regions{i}){k}.minX = -10e3;
                            rois.(regions{i}){k}.maxX = 10e3;
                            rois.(regions{i}){k}.minY = -10e3;
                            rois.(regions{i}){k}.maxY = 10e3;
                        else    
                            try
                                rois.(regions{i}){k} = looking_coordinates_mult_images(img_file_names{k},regions{i},coordinates_and_labels);
                            catch
                %                 rois.(regions{i}){k} = NaN;
                                rois.(regions{i}){k}.minX = -10e3;
                                rois.(regions{i}){k}.maxX = 10e3;
                                rois.(regions{i}){k}.minY = -10e3;
                                rois.(regions{i}){k}.maxY = 10e3;

                                could_not_find{stp} = img_file_names{k};
                                stp = stp+1;
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
                % save all outputs as an image_data .mat variable
                % -     
                
                save_efix_name = sprintf('Efix %s_new.xls',session_id);
                save_time_name = sprintf('Time %s_new.xls',session_id);
                save_roi_name = sprintf('Roi %s_new.mat',session_id);

                xlswrite(fullfile(full_save_path,save_efix_name),efix_file);
                xlswrite(fullfile(full_save_path,save_time_name),image_times);
                save(fullfile(full_save_path,save_roi_name),'rois');
            else
                fprintf('\n\t\t\tSkipping %s because it already exists in the save_path',edf_file_name);
            end
        end
    end
end



% edf_path = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/check_for_dups';
% save_path = edf_path;













