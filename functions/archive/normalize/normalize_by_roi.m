function [storeValues,storeLabs] = normalize_by_roi(values,labels)

if iscell(labels)
    all_sessions = unique(labels{5});
    all_images = unique(labels{4});
    all_doses = unique(labels{3});
    all_monkeys = unique(labels{2});
    new_method = 0;
elseif isstruct(labels)
    all_sessions = labels.sessions;
    all_images = labels.images;
    all_doses = labels.doses;
    all_monkeys = labels.monkeys;
    new_method = 1;
else
    error('Labels must be a cell array or struct');
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
            for r = 1:3;
                if r == 1;
                    all_rois = {'eyes','screen'};
                elseif r == 2;
                    all_rois = {'mouth','screen'};
                else
                    all_rois = {'image','screen'};
                end
                for s = 1:length(all_sessions);
                    if ~new_method
                        [realValues,realLabels] = separate_data_hannah(...
                            values,labels,'monkeys',{all_monkeys{m}},...
                            'images',{all_images{i}},'doses',{all_doses{d}},...
                            'rois',{all_rois{1}},'sessions',{all_sessions{s}});

                        normalizeBy = separate_data_hannah(...
                            values,labels,'monkeys',{all_monkeys{m}},...
                            'images',{all_images{i}},'doses',{all_doses{d}},...
                            'rois',{all_rois{2}},'sessions',{all_sessions{s}});
                    else
                        [realValues,realLabels] = separate_data_struct(...
                            values,labels,'monkeys',{all_monkeys{m}},...
                            'images',{all_images{i}},'doses',{all_doses{d}},...
                            'rois',{all_rois{1}},'sessions',{all_sessions{s}});

                        normalizeBy = separate_data_struct(...
                            values,labels,'monkeys',{all_monkeys{m}},...
                            'images',{all_images{i}},'doses',{all_doses{d}},...
                            'rois',{all_rois{2}},'sessions',{all_sessions{s}});
                    end
                    
                    if ~isempty(realValues) && ~isempty(normalizeBy);
                        realValues(:,1) = realValues(:,1) ./ normalizeBy;
                        if ~new_method
                            for n = 1:length(realLabels);
                                storeLabs{n} = [storeLabs{n};realLabels{n}];
                            end
                        else
                        update_size = size(realValues,1);
                            for n = 1:length(field_names);
                                storeLabs.(field_names{n})(stp+1:stp+update_size,1) = ...
                                    realLabels.(field_names{n});
                            end
                        end
                        
                        storeValues(stp+1:stp+update_size,:) = realValues;
                        stp = stp+update_size;
%                         storeValues = [storeValues;realValues]; % store the 
                                                                % processed
                                                                % values
                    end
                end
            end
        end
    end
end

storeValues = storeValues(~isnan(storeValues(:,1)),:);

if new_method
    empty_index = cellfun('isempty',storeLabs.(field_names{1}));
    for i = 1:length(field_names);
        storeLabs.(field_names{i})(empty_index,:) = [];
    end
end


