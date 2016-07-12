function [storeValues,storeLabs] = normalize_by(values,labels)

all_sessions = unique(labels{5});
all_images = unique(labels{4});
all_doses = unique(labels{3});
all_monkeys = unique(labels{2});
all_rois = unique(labels{1});

storeValues = []; storeLabs = cell(1,length(labels));
for m = 1:length(all_monkeys)
    for i = 1:length(all_images);
        for d = 1:length(all_doses);
            for r = 1:length(all_rois);
                for s = 1:length(all_sessions);
                    [realValues,realLabels] = separate_data_hannah(...
                        values,labels,'monkeys',{all_monkeys{m}},...
                        'images',{all_images{i}},'doses',{all_doses{d}},...
                        'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                    
                    switch normBy
                        case 'scrambled'
                            normalizeBy = separate_data_hannah(...
                                values,labels,'monkeys',{all_monkeys{m}},...
                                'images',{'Scr'},'doses',{all_doses{d}},...
                                'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                        case 'saline'
                            normalizeBy = separate_data_hannah(...
                                values,labels,'monkeys',{all_monkeys{m}},...
                                'images',{all_images{i}},'doses',{'saline'},...
                                'rois',{all_rois{r}},'sessions',{all_sessions{s}});
                    end
                    
                    if ~isempty(realValues) && ~isempty(normalizeBy);
                        normalizeBy = mean(normalizeBy);
                        realValues = realValues ./ normalizeBy;
                        for n = 1:length(realLabels);
                            storeLabs{n} = [storeLabs{n};realLabels{n}];
                        end
                        storeValues = [storeValues;realValues]; % store the 
                                                                % processed
                                                                % values
                    end
                end
            end
        end
    end
end
