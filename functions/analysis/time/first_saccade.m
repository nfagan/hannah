%{
    first_saccade.m -- finds the timepoint of the first saccade after each
    start time present in <time>. The start times in <time> ought to be
    obtained from times_of_first_eye_look.m, which returns the timepoints
    of the first fixations following a look to the eyes.
    
%}

function store_per_session = first_saccade(time,pupil)

vel_thresh = 50;        %   deg/s
min_vel_thresh = 0.01;  %   deg/s
look_window = 1000;  %   ms
saccade_thresh = [100 1000]; %   min / max saccade duration, in ms

if ~isa(time,'DataObject') || ~isa(pupil,'DataObject')
    error('Inputs must be data objects');
end

sessions = unique(time.labels.sessions);

counts.total = 0; counts.error = 0;
for s = 1:length(sessions)
    fprintf('\n%s',sessions{s});
    session = time(time == sessions{s});
    pup = pupil(pupil == sessions{s});
    pup = pup.data; pup = pup{1};

    starts = unique(session(:,1).data);

    rows = 1:length(pup.t);
    
    store_per_image = cell(length(starts),1);
    
    for i = 1:length(starts) %  for each image presentation time ...
        counts.total = counts.total + 1;
        outputs = preallocate({'x','y','saccade_length','saccade_start','saccade_end'}, [1 1]);

        start_index = rows(pup.t == starts(i));

        if isempty(start_index) %   debug
            disp(starts(i)); disp(max(pup.t));
            disp(sessions{s});
            error('could not find start index');
        end

        end_index = start_index + look_window;

        if end_index > max(rows)
            error('Time data ends before window end');
        end
        
        windowed.x = pup.x(start_index:end_index)';
        windowed.y = pup.y(start_index:end_index)';
        windowed.t = pup.t(start_index:end_index)'./1000;
                
        vel = get_velocity(windowed,10); %    2nd input = window size, in samples
        
        startsaccade = min([find(vel.x > vel_thresh,1,'first'),find(vel.y > vel_thresh,1,'first')]);
        
        %   after the start of a saccade, find the first time point at
        %   which velocity is below <min_vel_thresh> -- this is the end of
        %   a saccade
        
        subwindowed = vel; pupfields = fieldnames(windowed);
        for k = 1:length(pupfields)
            subwindowed.(pupfields{k}) = vel.(pupfields{k})(startsaccade:end);
        end
        
        endsaccade = min([find(subwindowed.x <= min_vel_thresh,1,'first'),...
            find(subwindowed.y <= min_vel_thresh,1,'first')]) + ...
            (startsaccade-1);
        
        if isempty(startsaccade) || isempty(endsaccade)
            counts.error = counts.error + 1; continue;
        end
        
        start_ind = find(windowed.t == vel.t(startsaccade));
        end_ind = find(windowed.t == vel.t(endsaccade));
        
        saccade_length = end_ind - start_ind;
        
        %   if the saccade is (physiologically speaking) too short or too
        %   long, reject it
        
        if saccade_length < saccade_thresh(1) || saccade_length > saccade_thresh(2)
            counts.error = counts.error + 1; continue;
        end
        
        %   otherwise, record the ending (x,y) position of the saccade, the
        %   length of the saccade, and the 
        
        outputs.x = pup.x(end_ind + start_index-1);
        outputs.y = pup.y(end_ind + start_index-1);
        outputs.saccade_length = saccade_length;
        outputs.saccade_start = vel.t(startsaccade) * 1e3; %    convert back to ms
        outputs.saccade_end = vel.t(endsaccade) * 1e3;
        
        store_per_image(i) = {outputs};
    end
    
    new_struct.data = store_per_image;
    new_struct.labels = session.labels;
    
    if s == 1
        store_per_session = DataObject(new_struct);
    else
        store_per_session = [store_per_session;DataObject(new_struct)];
    end
    
end

empty = cellfun(@isempty,store_per_session.data);

store_per_session = store_per_session(~empty);

end

function output = preallocate(fields,sizes)

    output = struct();
    for i = 1:length(fields)
        output.(fields{i}) = zeros(sizes);
    end

end