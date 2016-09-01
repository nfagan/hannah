function to_keep = trials_with_first_looks_to_eye(eye_times,quad_times)

threshold = 100;

eye_errors = eye_times.data(:,1) ~= 0;
eye_times = index_obj(eye_times,eye_errors);

quad_errors = quad_times.data(:,1) ~= 0;
quad_times = index_obj(quad_times,quad_errors);

eye_start_times = unique(eye_times.data(:,1));

to_keep = true(size(quad_times.data(:,1),1),1);
for i = 1:length(eye_start_times)
    eye_fix_events = eye_times.data(eye_times.data(:,1) == eye_start_times(i),:);
    
    quad_ind = quad_times.data(:,1) == eye_start_times(i);    
    
    if sum(quad_ind)
        
        first_eye_event = min(eye_fix_events(:,3));

        quad_fix_events = quad_times.data(quad_ind,:);

        %   index of when first fix event start was after the first fix to the
        %   eye

%         after_eye_fix_ind = quad_fix_events(:,3) > first_eye_event;
        after_eye_fix_ind = (quad_fix_events(:,3) - first_eye_event) > threshold;

        %   keep all elements of quad_times except those that occurred before
        %   the first eye fix event

        to_keep(quad_ind) = after_eye_fix_ind;
        
    else
        fprintf('\nSkipping ...');
    end
   
end






