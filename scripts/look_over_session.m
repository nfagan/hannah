function output = look_over_session(time,other,other_data_kind,varargin)

params = struct(...
    'yLims',[], ...
    'minutes',1 ... %   bin amount
);
params = structInpParse(params,varargin);

if ~isa(time,'DataObject')
    time = DataObject(time);
elseif ~isa(other,'DataObject')
    other = DataObject(other);
end

%   confirm that labels correspond first

if ~labeleq(time,other)
    error('Data labels are not equivalent');
end

[~,time_errors] = no_zeros(time);

time(time_errors,:) = [];
other(time_errors,:) = [];

images = unique(time.labels.images);
sessions = unique(time.labels.sessions);
doses = unique(time.labels.doses);

start_times = struct(); %   first get session start times
for i = 1:length(sessions)
    start_times.(['day_' sessions{i}]) = min(time(time == sessions{i},1));
end

figure; hold off;
for i = 1:length(images)
    
    store_time = zeros(1000,round(50/params.minutes)); stp = 1;
    for s = 1:length(sessions)
        
        session_start = start_times.(['day_' sessions{s}]);
        
        sesh_img_ind = time == images{i} & time == sessions{s};

        one_sesh_time = time(sesh_img_ind);
        image_times = unique(one_sesh_time(:,1).data);
        
        for j = 1:length(image_times)
            
            image_time_index = time(:,1).data == image_times(j);
            
            extr_other_data = other(image_time_index,:).data;
            
            presented_time = image_times(j) - session_start;
            
            %   convert to minutes-bins
            
            presented_time = floor(presented_time / 1000 / 60 / params.minutes) + 1;

            if strcmp(other_data_kind,'lookDuration')
                store_time(stp,presented_time) = sum(extr_other_data);
            end
            
            stp = stp + 1;
            
        end
        to_plot_values = zeros(1,size(store_time,2)); to_plot_errors = zeros(1,size(store_time,2));
        for e = 1:size(store_time,2)
            one_bin = store_time(:,e); one_bin = one_bin(one_bin ~= 0);
            if ~isempty(one_bin)
                to_plot_values(e) = mean(one_bin);
                to_plot_errors(e) = std(one_bin);
            end
        end  
    end
    hold on;
    plot(to_plot_values);
    
    output.(images{i}).values = to_plot_values;
    output.(images{i}).errors = to_plot_errors;
end

legend(images);

if ~isempty(params.yLims)
    ylim(params.yLims);
end

xlabel(sprintf('Bins -- %d minutes',params.minutes));
title_str = [];
for i = 1:length(doses)
    title_str = sprintf('%s %s',title_str,doses{i});
end
title(title_str);

