function [storeValues,storeLabs] = normalize_by(values,labels,normBy,varargin)

params = struct(...
    'withinSessions',1, ...
    'imageType','Scr' ...
    );

params = structInpParse(params,varargin);

if strcmp(normBy,'saline');
    params.withinSessions = 0;
end

image_type = params.imageType;
fprintf('\n%s',image_type);

if iscell(labels)
    all_sessions = unique(labels{5});
    all_images = unique(labels{4});
    all_doses = unique(labels{3});
    all_monkeys = unique(labels{2});
    all_rois = unique(labels{1});
    new_method = 0;
elseif isstruct(labels)
    all_sessions = unique(labels.sessions);
    all_images = unique(labels.images);
    all_doses = unique(labels.doses);
    all_monkeys = unique(labels.monkeys);
    all_rois = unique(labels.rois);
    new_method = 1;
end

if ~any(strcmp(all_images,params.imageType))
    error('The specified image ''%s'' does not exist in the current labels struct',params.imageType);
end

if ~new_method
    storeLabs = cell(1,length(labels));
else
    field_names = fieldnames(labels);
    for i = 1:length(field_names);
%         storeLabs.(field_names{i}) = [];
        storeLabs.(field_names{i}) = cell(size(values,1),1);
    end
end

storeValues = nan(size(values,1),size(values,2)); stp = 0;
for m = 1:length(all_monkeys)
    for i = 1:length(all_images);
        for d = 1:length(all_doses);
            for r = 1:length(all_rois);
                if ~params.withinSessions
                    all_sessions = {'all'};
                end
                for s = 1:length(all_sessions);
                    if ~new_method
                        [realValues,realLabels] = separate_data_hannah(...
                            values,labels,'monkeys',{all_monkeys{m}},...
                            'images',{all_images{i}},'doses',{all_doses{d}},...
                            'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                    else
                        [realValues,realLabels] = separate_data_struct(...
                            values,labels,'monkeys',{all_monkeys{m}},...
                            'images',{all_images{i}},'doses',{all_doses{d}},...
                            'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                    end
                    
                    switch normBy
                        case {'scrambled','imageType'}
                            if ~new_method
                                normalizeBy = separate_data_hannah(...
                                    values,labels,'monkeys',{all_monkeys{m}},...
                                    'images',{image_type},'doses',{all_doses{d}},...
                                    'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                            else
                                normalizeBy = separate_data_struct(...
                                    values,labels,'monkeys',{all_monkeys{m}},...
                                    'images',{image_type},'doses',{all_doses{d}},...
                                    'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                            end
                        case 'saline'
                            if ~new_method
                                normalizeBy = separate_data_hannah(...
                                    values,labels,'monkeys',{all_monkeys{m}},...
                                    'images',{all_images{i}},'doses',{'saline'},...
                                    'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                            else
                                 normalizeBy = separate_data_struct(...
                                    values,labels,'monkeys',{all_monkeys{m}},...
                                    'images',{all_images{i}},'doses',{'saline'},...
                                    'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                            end
                    end
                    
                    if ~isempty(realValues) && ~isempty(normalizeBy);
                        normalizeBy = mean(normalizeBy(:,1));
                        realValues(:,1) = realValues(:,1) ./ normalizeBy;
                        
                        update_size = size(realValues,1);
                        
                        if ~new_method
                            for n = 1:length(realLabels);
                                storeLabs{n} = [storeLabs{n};realLabels{n}];
                            end
                        else
                            for n = 1:length(field_names);
                                storeLabs.(field_names{n})(1+stp:stp+update_size) = ...
                                    realLabels.(field_names{n});
                            end
                        end
                        storeValues(1+stp:stp+update_size,:) = realValues;
%                         storeValues = [storeValues;realValues]; % store the 
                                                                % processed
                                                                % values
                        stp = stp+update_size;
                    end
                end
            end
        end
    end
end

to_remove = isnan(storeValues(:,1));
storeValues = storeValues(~to_remove,:);

if new_method
%     empty_index = cellfun('isempty',storeLabs.(field_names{1}));
    for i = 1:length(field_names);
        storeLabs.(field_names{i})(to_remove,:) = [];
    end
end

