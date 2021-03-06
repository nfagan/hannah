
startDirectory = '/Users/hannahweinberg-wolf/Documents/5HTP_FV_Analysis_Code/codes_for_hannah/new_test_data';

imageDisplayLength = 5000; %ms

rois = {'eyes','mouth','image','screen'};
monkeys = {'hitch'};
doses = {'saline','low','high'};
images = {'UBDT', 'UBDS', 'UBDN', 'UBDL', 'UBIT', 'UBIS', 'UBIN', ...
    'UBIL', 'UGDT', 'UGDS', 'UGDN', 'UGDL', 'UGIT', 'UGIS', 'UGIN', 'UGIL', ...
    'Scr', 'Out'};

step = 1; % prep for stepping in nested loop
storeLookingDuration = []; % clear stored variables
storeNSuccessfulTrials = [];
storeLengthFixEvents = [];
for r = 1:length(rois)
    fprintf('\nUsing roi %s',rois{r});
    pos = determine_roi_coordinates(rois{r});
    for m = 1:length(monkeys)
        fprintf('\n\tUsing Monkey %s',monkeys{m});
        for k = 1:length(doses);
            fprintf('\n\t\tUsing Dose %s',doses{k});
            dataDirectory = get_umbr_dir_hannah(startDirectory,monkeys{m},doses{k});
            [allTimes,allEvents,~,ids] = getFilesHannah(dataDirectory);

            imageTimes = cell(1,length(allTimes));
            imageCategory = cell(1,length(allTimes));
            
            for i = 1:length(allTimes);
                oneTimes = allTimes{i};
                startTimes = oneTimes(:,2);
                startTimes(:,2) = startTimes(:,1) + imageDisplayLength; %ms
                imageTimes{i} = startTimes;
                imageCategory{i} = allTimes{i}(:,1);
            end
            
            %%% figure out which ids are specific to a single day
            
            ids_only_letters = cellfun(@(x) x(~isstrprop(x,'alpha')),ids,'UniformOutput',false);
            unique_days = unique(cellfun(@(x) x(1:4),ids_only_letters,'UniformOutput',false));
            
            for d = 1:length(unique_days)
                current_day_index = strncmpi(ids_only_letters,unique_days{d},length(unique_days{d}));
                
                current_day = unique_days{d};
                image_categories_one_day = imageCategory(current_day_index);
                image_times_one_day = imageTimes(current_day_index);
                events_one_day = allEvents(current_day_index);
                ids_one_day = ids(current_day_index);
                
                start_time = image_times_one_day{1}(1,1); 
                start_times.(['day_' current_day]) = start_time;

                for l = 1:length(images); % for each image ...
%                     fprintf('\n\t\t\tUsing Image %s',images{l});
                    separatedTimes = separate_images(image_times_one_day,image_categories_one_day,images{l});
                    [nonEmptyTimes,nonEmptyEvents,nonEmptyIds] = fixLengths2(separatedTimes,events_one_day,ids_one_day);

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





