%{

    times_of_first_eye_look.m - function for obtaining the timepoint of the
    first fixation to the eyes, per image.

%}

function time = times_of_first_eye_look(time)

time = no_zeros(time);

sessions = unique(time.labels.sessions);

keep = false(count(time,1),1);

for s = 1:length(sessions)
    
    session_index = time == sessions{s} & time == 'eyes';
    one_session = time(session_index);
    
    if count(one_session,1) >= 1
        
        times = one_session.data;
        starts = unique(times(:,1));
        
        min_indices = false(size(times,1),1);
        
        for i = 1:length(starts)
            current_image_index = times(:,1) == starts(i);
            offset = find(current_image_index == 1,1,'first');            
            current_image_times = times(current_image_index,:);
            min_index = find(current_image_times(:,3) == min(current_image_times(:,3)));
            min_indices(offset-1+min_index) = true;
        end
        
    else min_indices = false(size(session_index));
    end
    
    keep(session_index) = min_indices;
    
end

time = time(keep);


end