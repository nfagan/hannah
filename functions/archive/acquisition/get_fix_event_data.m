function data = get_fix_event_data(processed_image_data,data_labels)

tic;

% - parse global inputs
   
image_times = processed_image_data.image_times;
fix_events = processed_image_data.fix_events;
positional_boundaries = processed_image_data.roi_data;
pupil_data = processed_image_data.pupil_data;

label_fields = fieldnames(data_labels);

% - pupil paramaters

look_back_from_image_start = -300;  % ms - t = 0 for getting pupil data
pupil_vector_length = 300;          % ms - amount of pupil data to get

stp = 1;
for i = 1:length(image_times);
    
    one_session_times = image_times{i}; %get one file's timing info
    one_session_fix_events = fix_events{i}; %get one file's fixation events
    one_session_rois = positional_boundaries{i};
    one_session_pup_data = pupil_data{i};
    
    fix_starts = one_session_fix_events(:,1); %separate columns of fixation events for clarity; start of all fixations
    fix_ends = one_session_fix_events(:,2); %end of all fixations
    dur = one_session_fix_events(:,3); %durations
    x = one_session_fix_events(:,4);
    y = one_session_fix_events(:,5);
    pupSize = one_session_fix_events(:,6);
    
    rowN = 1:length(fix_starts); %for indexing
    
    for j = 1:size(one_session_times,1); %for each image display time ...
        
        minX = one_session_rois{j}.minX;
        maxX = one_session_rois{j}.maxX;
        minY = one_session_rois{j}.minY;
        maxY = one_session_rois{j}.maxY;
        
        if one_session_times(j,2) < max(fix_ends); % if valid display time
            
            startEndTimes = [one_session_times(j,1) one_session_times(j,2)];
            timeIndex = zeros(1,2); firstLastDur = zeros(1,2);        

            for k = 1:2;

                toFindTime = startEndTimes(k);        
                testIndex = toFindTime >= fix_starts & toFindTime <= fix_ends;                      

                if sum(testIndex) == 1;
                    timeIndex(k) = rowN(testIndex);
                    if k == 1;                    
                        firstLastDur(k) = fix_ends(timeIndex(k)) - toFindTime;          
                    else
                        firstLastDur(k) = toFindTime - fix_starts(timeIndex(k));
                    end
                else
                    lastGreater = find(toFindTime <= fix_starts,1,'first');
                    if k == 1;                    
                        timeIndex(k) = lastGreater;
                        firstLastDur(k) = dur(timeIndex(k));            
                    else                    
                        timeIndex(k) = lastGreater-1;
                        firstLastDur(k) = dur(timeIndex(k));
                    end
                end

            end

            start_index = timeIndex(1);
            end_index = timeIndex(2);

            if start_index ~= end_index         
                all_durs = dur(start_index:end_index);
                all_durs(1) = firstLastDur(1); all_durs(end) = firstLastDur(2); %replace first and last durations with adjusted durations;        
            else
                all_durs = firstLastDur(1);
            end
            
            fixEvents = [fix_starts(start_index:end_index) fix_ends(start_index:end_index)];

            allPup = pupSize(start_index:end_index);      
            allX = x(start_index:end_index);
            allY = y(start_index:end_index); 
            
            if start_index > end_index
                warning('Start indices are greater than end indices. Data will be missing and skipped');
            end

            checkXBounds = allX >= minX & allX <= maxX;
            checkYBounds = allY >= minY & allY <= maxY;
            checkBounds = checkXBounds & checkYBounds;

            all_durs(~checkBounds) = [];
            allPup(~checkBounds) = [];
            
            %   gather looking duration, fix event duration, and an index 
            %   of successful trials
            
            if ~isempty(all_durs)
                looking_duration.data(stp) = sum(all_durs);
                fix_event_duration.data{stp} = all_durs;
                successful_trial.data(stp) = 1;
                n_fixations.data{stp} = length(all_durs);
                x_y_coords.data{stp} = [allX(checkBounds) allY(checkBounds)];
                time.data{stp} = [repmat(startEndTimes,size(fixEvents(checkBounds,:),1),1) fixEvents(checkBounds,:)];
            else
                looking_duration.data(stp) = 0;
                fix_event_duration.data{stp} = 0;
                successful_trial.data(stp) = 0;
                n_fixations.data{stp} = 0;
                x_y_coords.data{stp} = [NaN NaN];
                time.data{stp} = [0 0 0 0];
            end
            
            %   begin pupil data gathering
            
            for_row_indexing = 1:size(one_session_pup_data,1);
            
            pupil_start_time = startEndTimes(1) + look_back_from_image_start;
            pupil_end_time = pupil_start_time + pupil_vector_length;
            
            pupil_start_index = one_session_pup_data(:,1) == pupil_start_time; 
            pupil_end_index = one_session_pup_data(:,1) == pupil_end_time;
            if isempty(pupil_start_index) || isempty(pupil_end_index)
                error('Could not find the image start time or end time in this pupil data');
            end
            
            pupil_start_index = for_row_indexing(pupil_start_index); % get the indices, (equiv. to 'find(...)')
            pupil_end_index = for_row_indexing(pupil_end_index);
            
            one_image_pupil_size = one_session_pup_data(pupil_start_index:pupil_end_index,2);
            per_image_pupil_size.data{stp} = one_image_pupil_size; % store for each image
            
            %   store labels
            
            for lab = 1:length(label_fields)
                looking_duration.labels(stp).(label_fields{lab}) = ...
                    repmat({data_labels.(label_fields{lab}){i}{j}},length(looking_duration.data(stp)),1);
                
                fix_event_duration.labels(stp).(label_fields{lab}) = ...
                    repmat({data_labels.(label_fields{lab}){i}{j}},length(fix_event_duration.data{stp}),1);
                
                successful_trial.labels(stp).(label_fields{lab}) = ...
                    repmat({data_labels.(label_fields{lab}){i}{j}},length(successful_trial.data(stp)),1);
                
                n_fixations.labels(stp).(label_fields{lab}) = ...
                    repmat({data_labels.(label_fields{lab}){i}{j}},length(n_fixations.data{stp}),1);
                
                per_image_pupil_size.labels(stp).(label_fields{lab}) = ...
                    repmat({data_labels.(label_fields{lab}){i}{j}},length(per_image_pupil_size.data{stp}),1);
                
                x_y_coords.labels(stp).(label_fields{lab}) = ...
                    repmat({data_labels.(label_fields{lab}){i}{j}},size(x_y_coords.data{stp},1),1);
                
                time.labels(stp).(label_fields{lab}) = ...
                    repmat({data_labels.(label_fields{lab}){i}{j}},size(time.data{stp},1),1);
                
            end
            
            stp = stp + 1;
%             fprintf('\n%d',stp);
        end
        
    end
    
end

% -
% Begin output section. Note that pupil size is handled separately from the
% other outputs, because it must be stored as an array of cell arrays,
% rather than a vector
% - 

data.lookingDuration = looking_duration;
data.fixEventDuration = fix_event_duration;
data.trialSuccessIndex = successful_trial;
data.nFixations = n_fixations;
data.Coordinates = x_y_coords;
data.Time = time;

% - transform the data labels into cell arrays of the same length as the
% data values they accompany

output_data_fieldnames = fieldnames(data);

for i = 1:length(output_data_fieldnames)    %  for each field of 'data'
    fprintf('\nProcessing labels for %s',output_data_fieldnames{i});
    if iscell(data.(output_data_fieldnames{i}).data)
        data.(output_data_fieldnames{i}).data = ...
            concatenateData(data.(output_data_fieldnames{i}).data);
    else    %   Store data values row-wise
        data.(output_data_fieldnames{i}).data = ...
            data.(output_data_fieldnames{i}).data';
    end
    for k = 1:length(label_fields)  %   for each data label, concatenate the data labels
                                    %   across image presentations
        fprintf('\n%d',k);
        current_labels = ...
            concatenateData({data.(output_data_fieldnames{i}).labels(:).(label_fields{k})}');

        fixed_labels.(label_fields{k}) = current_labels;           
    end
    data.(output_data_fieldnames{i}).labels = fixed_labels;
end

% - pupil is special case -- we don't want an individual label for each ms
% of pupil data -- only for the image associated with the data

data_cell_method.pupilSize = per_image_pupil_size;

data_cell_fields = fieldnames(data_cell_method);

for j = 1:length(data_cell_fields)
    fprintf('\nProcessing labels for %s',data_cell_fields{j});
    fixed_labels = [];
    fixed_data = data_cell_method.(data_cell_fields{j}).data'; % N.B.: transposition
    for i = 1:length(label_fields)
        for k = 1:length(per_image_pupil_size.data)
            fixed_labels.(label_fields{i}){k} = data_cell_method.(data_cell_fields{j}).labels(k).(label_fields{i}){1};
        end
    end
    fixed_labels = structfun(@(x) x',fixed_labels,'UniformOutput',false); % make into row-vector
    data.(data_cell_fields{j}).data = fixed_data;
    data.(data_cell_fields{j}).labels = fixed_labels;
end

toc;





