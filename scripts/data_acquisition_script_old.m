%%

data_dir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/processed_mat_files';

rois = {'eyes','mouth','face'};
image_presentation_length = 5000; % ms

for r = 1:length(rois)
    current_roi = rois{r};
    fprintf('\nUsing roi %s',current_roi);
    
    all_files = get_files_hannah(data_dir);
    all_files = cellfun(@(x) x.imagedata,all_files,'UniformOutput',false);
    
    %   get the image presentation times in cell array form       
           
    image_times = cellfun(@(x) x.image_data.data.time,all_files,'UniformOutput',false);
    for i = 1:length(image_times)
        image_times{i}(:,2) = image_times{i}(:,1) + image_presentation_length;
    end

    %   get the positional boundaries associated with each image, and the fix events for each
    %   session. Each cell of image_categories, roi_data, etc. is a
    %   unique session

    roi_data = cellfun(@(x) x.image_data.data.rois.(rois{r}),all_files,'UniformOutput',false);
    fix_events = cellfun(@(x) x.image_data.data.fix_events,all_files,'UniformOutput',false);

    %   get data labels in cell array form
    
    all_labels.days = cellfun(@(x) x.image_data.labels.day,all_files,'UniformOutput',false);
    all_labels.sessions = cellfun(@(x) x.image_data.labels.session,all_files,'UniformOutput',false);
    all_labels.file_names = cellfun(@(x) x.image_data.labels.file_names,all_files,'UniformOutput',false);
    all_labels.monkeys = cellfun(@(x) x.image_data.labels.monkey,all_files,'UniformOutput',false);
    all_labels.doses = cellfun(@(x) x.image_data.labels.dose,all_files,'UniformOutput',false);
    all_labels.image_categories = cellfun(@(x) x.image_data.labels.category,all_files,'UniformOutput',false);
    all_labels.rois = cellfun(@(x) x.image_data.labels.rois.(current_roi),all_files,'UniformOutput',false);

    data.(rois{r}) = get_fix_event_data(image_times,fix_events,all_labels,roi_data);
            
end

combined_data = combine_structs_across_rois(data);
combined_data = add_expr_gaze_gender_labs(combined_data);
combined_data = remove_zeros_from_data_struct(combined_data,{'lookingDuration'});













%%
%     all_labels.days = days;
%     all_labels.sessions = sessions;
%     all_labels.file_names = file_names;
%     all_labels.monkeys = monkeys;
%     all_labels.doses = doses;
%     all_labels.category = image_categories;
%     all_labels.rois = roi_labels;

%%
image_presentation_length = 5000; % ms

for r = 1:length(rois)
    fprintf('\nUsing roi %s',rois{r});
    for m = 1:length(monkeys)
        fprintf('\n\tUsing Monkey %s',monkeys{m});
        for k = 1:length(doses);
            fprintf('\n\t\tUsing Dose %s',doses{k});
            
            full_data_dir = get_umbr_dir_hannah(base_data_dir,monkeys{m},doses{k});
            [all_files,day_data] = get_files_hannah(full_data_dir);
            
            sessions = day_data.ids; day_labels = day_data.day_labels;
            days = unique(day_labels);
            
            image_times = cellfun(@(x) x.imagedata.time,all_files,'UniformOutput',false);
            for i = 1:length(image_times)
                image_times{i}(:,2) = image_times{i}(:,1) + image_presentation_length;
            end
            
            %   get image category labels, the positional boundaries
            %   associated with each image, and the fix events for each
            %   session. Each cell of image_categories, roi_data, etc. is a
            %   unique session
            
            image_categories = cellfun(@(x) x.imagedata.labels.category,all_files,'UniformOutput',false);
            roi_data = cellfun(@(x) x.imagedata.data.rois.(rois{r}),all_files,'UniformOutput',false);
            fix_events = cellfun(@(x) x.imagedata.data.efix,all_files,'UniformOutput',false);
            
%             fix_events = cellfun(@(x) x.efix,all_files,'UniformOutput',false);
            
            for i = 1:length(image_categories)
                day_labels{i} = repmat({day_labels{i}},length(image_categories{i}),1);
                sessions{i} = repmat({sessions{i}},length(image_categories{i}),1);
                roi_labels{i} = repmat(rois{r},length(image_categories{i}),1);
                monk_labels{i} = repmat(monkeys{m},length(image_categories{i}),1);
            end
            
            all_labels.rois = roi_labels;
            all_labels.monkeys = monk_labels;
            all_labels.days = day_labels;
            all_labels.sessions = sessions;
            all_labels.category = image_categories;
            
            data = get_fix_event_data(image_times,fix_events,all_labels,roi_data);
            
        end
    end
end


%%
            
            
            
            
            
            
            
            
            
            
            
            
%             
%             
%             for d = 1:length(days)
%                 day_index = strcmp(day_labels,days{d});
%                 
%                 
%                 
%                 for c = 1:length(categories)
%                     current_category = categories{c};
%                     index_of_wanted_category = cellfun(@(x) strcmpi(x,current_category),image_categories,'UniformOutput',false);
%                     
% 
% 
% 
%                 end
%             end
%         end
%     end
% end
            
            
            
            
            
            
            
            
            
            
            
            
            
            
%             [allTimes,allEvents,~,sessions] = getFilesHannah(full_data_dir);

            imageTimes = cell(1,length(allTimes));
            imageCategory = cell(1,length(allTimes));
            
            for i = 1:length(allTimes);
                oneTimes = allTimes{i};
                startTimes = oneTimes(:,2);
                startTimes(:,2) = startTimes(:,1) + imageDisplayLength; %ms
                imageTimes{i} = startTimes;
                imageCategory{i} = allTimes{i}(:,1);
            end
            
            %%% figure out which sessions are specific to a single day
            
            sessions = cellfun(@(x) x(~isstrprop(x,'alpha')),sessions,'UniformOutput',false);
            unique_days = unique(cellfun(@(x) x(1:4),sessions,'UniformOutput',false));
            
            for d = 1:length(unique_days)
                current_day_index = strncmpi(sessions,unique_days{d},length(unique_days{d}));
                
                current_day = unique_days{d};
                image_categories_one_day = imageCategory(current_day_index);
                image_times_one_day = imageTimes(current_day_index);
                events_one_day = allEvents(current_day_index);
                sessions_one_day = sessions(current_day_index);
                
                start_time = image_times_one_day{1}(1,1); 
                start_times.(['day_' current_day]) = start_time;

                for l = 1:length(images); % for each image ...
%                     fprintf('\n\t\t\tUsing Image %s',images{l});
                    separatedTimes = separate_images(image_times_one_day,image_categories_one_day,images{l});
                    [nonEmptyTimes,nonEmptyEvents,nonEmptyIds] = fixLengths2(separatedTimes,events_one_day,sessions_one_day);

                    if strcmpi(images{l}(2),'b'); % get gender of image
                        gender = 'male';
                    elseif strcmpi(images{l}(2),'g');
                        gender = 'female';
                    else
                        gender = 'na';
                    end

                    if strcmpi(images{l}(3),'d'); % get gaze-type of image
                        gaze = 'direct';
                    elseif strcmpi(images{l}(3),'i'); %
                        gaze = 'indirect';
                    else
                        gaze = 'na';
                    end

                    if length(images{l}) == 4; % get expression of iamge
                        expression = images{l}(4);
                    else
                        expression = 'na';
                    end
                    
                    % - new roi coordinates based on the image

                    for id = 1:length(nonEmptyIds) % for each session ...
                        
                        data = getDur_hannah2({nonEmptyTimes{id}},{nonEmptyEvents{id}},pos);
                        if ~isempty(data.lookingDuration)
                            lookingDuration = data.lookingDuration(:,[1 end]); % sum total of duration 
                                                                     % of all fixation events, 
                                                                     % per image flipped
                            trial_start_time = min(lookingDuration(~isnan(lookingDuration(:,2)),2));
                            if isempty(trial_start_time);
                                trial_start_time = NaN;
                            end
                            nSuccessfulTrials = length(lookingDuration(lookingDuration(:,1) ~= 0));
                            nSuccessfulTrials(:,2) = repmat(trial_start_time,size(nSuccessfulTrials,1),1);
                            lengthFixEvents = data.fixEventDuration(:,[1 end]);% length of each 
                                                                     % individual fixation 
                                                                     % flipped
                        else
                            lookingDuration = [0 NaN];
                            nSuccessfulTrials = [0 NaN];
                            lengthFixEvents = [0 NaN];
                        end
                        storeLookingDuration = [storeLookingDuration;lookingDuration];
                        storeNSuccessfulTrials = [storeNSuccessfulTrials;nSuccessfulTrials];
                        storeLengthFixEvents = [storeLengthFixEvents;lengthFixEvents];

                        lookLabels{step} = get_labels(lookingDuration,rois{r},...
                            monkeys{m},doses{k},images{l},nonEmptyIds{id},gender,gaze,expression,current_day);
                        trialLabels{step} = get_labels(nSuccessfulTrials,rois{r},...
                            monkeys{m},doses{k},images{l},nonEmptyIds{id},gender,gaze,expression,current_day);
                        fixLabels{step} = get_labels(lengthFixEvents,rois{r},...
                            monkeys{m},doses{k},images{l},nonEmptyIds{id},gender,gaze,expression,current_day);
                        step = step + 1;
                    end
                end
            end
        end
    end
end

lookLabels = concat_labels(lookLabels);
trialLabels = concat_labels(trialLabels);
fixLabels = concat_labels(fixLabels);

label_names = {...
    'rois','monkeys','doses','images','sessions','genders','gazes','expressions'...
    ,'days'};

lookLabels = make_struct(lookLabels,label_names);
trialLabels = make_struct(trialLabels,label_names);
fixLabels = make_struct(fixLabels,label_names);

