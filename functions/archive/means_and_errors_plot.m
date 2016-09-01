function [means,errors] = means_and_errors_plot(values,labels,varargin)

params = struct(...
    'calc','mean', ...
    'withinSession',0, ...
    'yLimits',[], ...
    'saveString', [], ...
    'yLabel',[], ...
    'xLabel',[], ...
    'xtickLabel',[], ...
    'title',[] ...
    );

params = structInpParse(params,varargin);

if strcmp(params.calc,'mean')
    take_mean = 1;
elseif strcmp(params.calc,'sum')
    take_mean = 0;
else
    error('''calc'' must be either ''mean'' or ''sum''');
end

if iscell(labels);
%     all_sessions = unique(labels{5});
    all_images = unique(labels{4});
    all_doses = unique(labels{3});
    all_monkeys = unique(labels{2});
    all_rois = unique(labels{1});
    new_method = 0;
elseif isstruct(labels);
    all_images = unique(labels.images);
    all_doses = unique(labels.doses);
    all_monkeys = unique(labels.monkeys);
    all_rois = unique(labels.rois);
    new_method = 1;
end

means = cell(1,length(all_rois)); errors = cell(1,length(all_rois));
plotDoses = cell(1,length(all_rois)); plotImages = cell(1,length(all_rois));


n_doses = length(all_doses);
n_images = length(all_images);

for i = 1:length(all_images);
    for d = 1:length(all_doses);
        for r = 1:length(all_rois);
            if ~new_method
                [realValues,realLabels] = separate_data_hannah(...
                    values,labels,'monkeys',{'all'},...
                    'images',{all_images{i}},'doses',{all_doses{d}},...
                    'rois',{all_rois{r}},'sessions',{'all'});
            else
                [realValues,realLabels] = separate_data_struct(...
                    values,labels,'monkeys',{'all'},...
                    'images',{all_images{i}},'doses',{all_doses{d}},...
                    'rois',{all_rois{r}},'sessions',{'all'});
            end

            if ~isempty(realValues)
                if take_mean
                    if ~iscell(realValues)
                        means{r}(d,i) = nanmean(realValues(:,1));
                        errors{r}(d,i) = nanSEM(realValues(:,1));
                    else
                        means{r}(d,i) = nanmean(concatenateData(realValues));
                        errors{r}(d,i) = nanstd(concatenateData(realValues));
                    end
                else
                    means{r}(d,i) = sum(realValues(:,1));
                    errors{r}(d,i) = 0;
                end

                plotDoses{r}{d,i} = all_doses{d};
                plotImages{r}{d,i} = all_images{i};
            end
        end
    end
end


imageLabels = [plotImages{1}];
ridIndex = zeros(size(imageLabels,1),size(imageLabels,2));
ridIndex(1,:) = 1;
toLabel = imageLabels(logical(ridIndex))';

doseLabels = [plotDoses{1}];
ridIndex = zeros(size(imageLabels,1),size(imageLabels,2));
ridIndex(:,1) = 1;
toLegend = doseLabels(logical(ridIndex))';
toLegend = fliplr(toLegend);

% plot 

n_categories = length(all_images);
axisSize = n_categories - 1;

scrsz = get(groot,'ScreenSize');
for r = 1:length(all_rois)
    figure('Position',[1 scrsz(2) scrsz(3) scrsz(4)]);
    hold on;
    
    
    
    bar(.3:1:.3+axisSize,means{r}(3,:),.15,'b');
    bar(.6:1:.6+axisSize,means{r}(2,:),.15,'g');
    bar(.9:1:.9+axisSize,means{r}(1,:),.15,'r');
    errorbar(.3:1:.3+axisSize,means{r}(3,:),errors{r}(1,:),'k.')
    errorbar(.6:1:.6+axisSize,means{r}(2,:),errors{r}(2,:),'k.')
    errorbar(.9:1:.9+axisSize,means{r}(1,:),errors{r}(3,:),'k.')
    set(gca,'XTick',[.6:1:.6+axisSize])
    if isempty(params.xtickLabel)
        set(gca,'XTickLabel',toLabel)
    else
        set(gca,'XTickLabel',params.xtickLabel);
    end

    if isempty(params.yLabel);
        ylabel('Total Looking Time Per Image in ms')
    else
        ylabel(params.yLabel);
    end
        
    if isempty(params.xLabel);
        xlabel('Image Category')
    else
        xlabel(params.xLabel);
    end
    
    if isempty(params.title);
        titleStr = sprintf('Total Looking Time Per Image - %s',all_rois{r});
        title(titleStr);
    else
        title(params.title);
    end

%     legend('Saline','Low','High')
%     legend(toLegend);
    
    if ~isempty(params.yLimits)
        ylim(params.yLimits);
    end

if ~isempty(params.saveString)
    
    saveDir = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/plots';
    saveString = sprintf('%s_%s',params.saveString,all_rois{r});
    fullPath = fullfile(saveDir,saveString);
%     saveas(gcf,fullPath,'jpg');
    img = getframe(gcf);
    imwrite(img.cdata, [fullPath, '.png']);
end
    
end





