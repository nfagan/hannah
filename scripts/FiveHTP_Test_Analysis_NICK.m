
startDirectory = '/Users/hannahweinberg-wolf/Documents/5HTP_FV_Analysis_Code/codes_for_hannah/new_test_data';

imageDisplayLength = 5000; %ms

rois = {'eyes','mouth','image','screen'};
monkeys = {'ephron'};
doses = {'saline','low','high'};
% images = {'UBDT'};
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

            for l = 1:length(images); % for each image ...
                fprintf('\n\t\t\tUsing Image %s',images{l});
                separatedTimes = separate_images(imageTimes,imageCategory,images{l});
                [nonEmptyTimes,nonEmptyEvents,nonEmptyIds] = fixLengths2(separatedTimes,allEvents,ids);
                
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
                        lookingDuration = data.lookingDuration(:,1); % sum total of duration 
                                                                 % of all fixation events, 
                                                                 % per image flipped
                        nSuccessfulTrials = length(lookingDuration(lookingDuration ~= 0));
                        lengthFixEvents = data.fixEventDuration(:,1);% length of each 
                                                                 % individual fixation 
                                                                 % flipped
                    else
                        lookingDuration = 0;
                        nSuccessfulTrials = 0;
                        lengthFixEvents = 0;
                    end
                    storeLookingDuration = [storeLookingDuration;lookingDuration];
                    storeNSuccessfulTrials = [storeNSuccessfulTrials;nSuccessfulTrials];
                    storeLengthFixEvents = [storeLengthFixEvents;lengthFixEvents];

                    lookLabels{step} = get_labels(lookingDuration,rois{r},...
                        monkeys{m},doses{k},images{l},nonEmptyIds{id},gender,gaze,expression);
                    trialLabels{step} = get_labels(nSuccessfulTrials,rois{r},...
                        monkeys{m},doses{k},images{l},nonEmptyIds{id},gender,gaze,expression);
                    fixLabels{step} = get_labels(lengthFixEvents,rois{r},...
                        monkeys{m},doses{k},images{l},nonEmptyIds{id},gender,gaze,expression);
                    step = step + 1;
                end
            end
        end
    end
end

lookLabels = concat_labels(lookLabels);
trialLabels = concat_labels(trialLabels);
fixLabels = concat_labels(fixLabels);




