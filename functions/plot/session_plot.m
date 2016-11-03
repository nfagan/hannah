function [means, errors] = session_plot(obj,varargin)

if ~isa(obj,'DataObject')
    obj = DataObject(obj);
end

params = struct(...
    'wantedRoi',[], ...
    'calc','sum', ...
    'yLimits',[], ...
    'yLabel',[], ...
    'xLabel',[], ...
    'title',[] ...
);

params = structInpParse(params,varargin);

if isempty(params.wantedRoi)
    rois = unique(obj.labels.rois);
else
    rois = {params.wantedRoi};
end

for r = 1:length(rois)
    
[means,errors,labels] = per_session_means(obj(obj == rois{r}),params);

plot_means();

end



%   plot



function plot_means()
    
axis_size = length(labels.images) - 1;

figure; hold on;
bar(.3:1:.3+axis_size,means(:,3),.15,'b');
bar(.6:1:.6+axis_size,means(:,2),.15,'g');
bar(.9:1:.9+axis_size,means(:,1),.15,'r');
errorbar(.3:1:.3+axis_size,means(:,3),errors(:,3),'k.')
errorbar(.6:1:.6+axis_size,means(:,2),errors(:,2),'k.')
errorbar(.9:1:.9+axis_size,means(:,1),errors(:,1),'k.')

set(gca,'XTick',[.6:1:.6+axis_size])
set(gca,'xticklabel',labels.images);

if isempty(params.title)
    title(rois{r});
else
    title(params.title);
end
if ~isempty(params.yLabel)
    ylabel(params.yLabel);
end
if ~isempty(params.yLimits);
    ylim(params.yLimits);
end
if ~isempty(params.xLabel)
    xlabel(params.xLabel);
end

legend(flipud(labels.doses))

end


end



%   get means



function [means, errors, labels] = per_session_means(obj,params)

sums = struct();

images = unique(obj.labels.images);
doses = unique(obj.labels.doses);

means = zeros(length(images),length(doses));
errors = zeros(length(images),length(doses));

for i = 1:length(images)
    
    one_image = obj(obj == images{i});
    
    for d = 1:length(doses)
        
        one_dose = one_image(one_image == doses{d});
        
        sessions = unique(one_dose.labels.sessions);
        
        for s = 1:length(sessions)
            
            one_session = one_dose(one_dose == sessions{s});
            
            if ~strcmp(one_session.dtype,'cell')
            
                if strcmp(params.calc,'sum')
                    sums.(images{i}).(doses{d})(s) = nansum(one_session.data);
                elseif strcmp(params.calc','mean')
                    sums.(images{i}).(doses{d})(s) = nanmean(one_session.data);
                end
            
            else
                
                int_means = cellfun(@(x) mean(x), one_session.data);
                sums.(images{i}).(doses{d})(s) = mean(int_means);
                
            end
            
        end
        
        means(i,d) = nanmean(sums.(images{i}).(doses{d}));
        errors(i,d) = nanstd(sums.(images{i}).(doses{d}));
        
    end
        
end

labels.images = images; labels.doses = doses;

end

% h = bar(means); set(h,'BarWidth',1);
% hold on;
% groups = size(means,1); bars = size(means,2);
% groupwidth = min(0.8, bars/(bars+1.5));
% 
% for i = 1:bars
%   x = (1:groups) - groupwidth/2 + (2*i-1) * groupwidth / (2*bars); 
%   errorbar(x, means(:,i), errors(:,i), 'k', 'linestyle', 'none');
% end

% set(gca,'xtick',1:size(means,1));
