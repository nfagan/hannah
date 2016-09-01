function plot_saccade_length(saccades)

sessions = unique(saccades.labels.sessions);
images = unique(saccades.labels.images);
doses = unique(saccades.labels.doses);

store = struct();

for i = 1:length(images) %  preallocate
    store.(images{i}) = struct();
    for d = 1:length(doses)
        store.(images{i}).(doses{d}) = 0;
        firstloop.(images{i}).(doses{d}) = true;
    end
end

for i = 1:length(images)
    for s = 1:length(sessions)
        one_session = saccades(saccades == images{i} & saccades == sessions{s});
        
        if isempty(one_session)
            continue;
        end
        
        data = one_session.data;
        
        dose = unique(one_session.labels.doses);
        
        dose = dose{1};
        
        saccade_length = cellfun(@(x) x.saccade_length,data);
        
        if firstloop.(images{i}).(dose)
            firstloop.(images{i}).(dose) = false;
            store.(images{i}).(dose)(1) = mean(saccade_length);
        else store.(images{i}).(dose)(end+1) = mean(saccade_length);
        end
        
    end
end

means = zeros(length(images),length(doses));
errors = zeros(length(images),length(doses));
for i = 1:length(images)
    for d = 1:length(doses)
        means(i,d) = mean(store.(images{i}).(doses{d}));
        errors(i,d) = SEM(store.(images{i}).(doses{d}));
    end
end

labels.images = images; labels.doses = doses; 

%   plot via helper function

Helper__Plot__bar_image_dose(means,errors,labels);


end

