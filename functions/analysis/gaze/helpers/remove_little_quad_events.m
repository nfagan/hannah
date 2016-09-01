function to_keep = remove_little_quad_events(eye_times,quad_times)

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
        
        quad_fix_events = quad_times.data(quad_ind,:);
        
        int_keep = false(size(quad_fix_events,1),1);
        for k = 1:size(quad_fix_events,1);
            if ~any(quad_fix_events(k,3) == eye_fix_events(:,3))
                int_keep(k) = true;
            end
        end
        
        to_keep(quad_ind) = int_keep;
    else
        fprintf('\nSkipping ...');
    end
   
end