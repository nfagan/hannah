function [storeValues,storeLabels] = sum_within_sessions(values,labels,varargin)

params = struct(...
    'withinCategory',0, ...
    'withinROI',0 ...
    );

params = structInpParse(params,varargin);

all_sessions = unique(labels{5});
all_images = unique(labels{4});
all_doses = unique(labels{3});
all_monkeys = unique(labels{2});
all_rois = unique(labels{1});

storeLabels = cell(1,length(labels)); storeValues = []; stp = 1;
for m = 1:length(all_monkeys)
    for d = 1:length(all_doses);
        if ~params.withinROI;
            all_rois = {'image'};
        end
        for r = 1:length(all_rois);
            if ~params.withinCategory
                all_images = {'all'};
            end
            for i = 1:length(all_images);
                for s = 1:length(all_sessions);
                    [realValues,realLabels] = separate_data_hannah(...
                        values,labels,'monkeys',{all_monkeys{m}},...
                        'doses',{all_doses{d}},'rois',{all_rois{r}},...
                        'sessions',{all_sessions{s}},'images',{all_images{i}});
                    if ~isempty(realValues)
                        realValues = sum(realValues);
                        for n = 1:length(realLabels);
                            storeLabels{n}{stp,1} = realLabels{n}{1};
                        end
                        storeValues = [storeValues;realValues];
                        stp = stp + 1;
                    end
                end
            end
        end
    end
end