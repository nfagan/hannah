function [means, errors] = session_plot(obj,varargin)

params = struct(...
    'wantedRoi',[], ...
    'calc','mean' ...
);

if ~isa(obj,'DataObject')
    obj = DataObject(obj);
end

params = paraminclude('Params__plot',params);   %   add global plot paramaters
params = parsestruct(params,varargin);          %   overwrite with inputs   

if isempty(params.wantedRoi)
    rois = unique(obj('rois'));
else rois = {params.wantedRoi};
end

for roi = rois'

[means,errors,labels] = session_means(obj(obj == roi),params);

params.title = roi;
Helper__Plot__bar_image_dose(means,errors,labels,params);

end

% [means,errors,labels] = per_session_means(obj(obj == rois{r}),params);

end

%   get means

function [means, errors, labels] = session_means(obj,params)

within = {'images','doses','sessions'};

images = unique(obj('images'));
doses = unique(obj('doses'));

indices = getindices(obj,within,'showProgress');

store = layeredstruct({images,doses});
store_stp = layeredstruct({images,doses},1);

for i = 1:length(indices)
    
    extracted = obj(indices{i});
    
    dose = char(unique(extracted('doses')));
    image = char(unique(extracted('images')));
    
    stp = store_stp.(image).(dose);
    store_stp.(image).(dose) = stp + 1;
    
    if strcmp(extracted.dtype,'cell')
        int_means = cellfun(@(x) mean(x), extracted.data);
        store.(image).(dose)(stp) = mean(int_means);
        continue; 
    end
    
    if strcmp(params.calc,'sum')
        store.(image).(dose)(stp) = nansum(extracted.data);
    elseif strcmp(params.calc,'mean')
        store.(image).(dose)(stp) = nanmean(extracted.data);
    end
                
end

%   restructure

means = zeros(length(images),length(doses));
errors = zeros(length(images),length(doses));

for i = 1:length(images)
    for k = 1:length(doses)
        means(i,k) = mean(store.(images{i}).(doses{k}));
        errors(i,k) = SEM(store.(images{i}).(doses{k}));
    end
end

labels.images = images; labels.doses = doses;

end



% function [means, errors, labels] = per_session_means(obj,params)
% 
% images = unique(obj.labels.images);
% doses = unique(obj.labels.doses);
% 
% means = zeros(length(images),length(doses));
% errors = zeros(length(images),length(doses));
% 
% sums = struct();
% 
% for i = 1:length(images)
%     
%     sums.(images{i}) = preallocate_struct(doses);
%     
%     one_image = obj(obj == images{i});
%     
%     for d = 1:length(doses)
%         
%         one_dose = one_image(one_image == doses{d});
%         
%         sessions = unique(one_dose.labels.sessions);
%         
%         for s = 1:length(sessions)
%             
%             one_session = one_dose(one_dose == sessions{s});
%             
%             if ~strcmp(one_session.dtype,'cell')
%             
%                 if strcmp(params.calc,'sum')
%                     sums.(images{i}).(doses{d})(s) = nansum(one_session.data);
%                 elseif strcmp(params.calc,'mean')
%                     sums.(images{i}).(doses{d})(s) = nanmean(one_session.data);
%                 end
%                 
%             else
%                 
%                 int_means = cellfun(@(x) mean(x), one_session.data);
%                 sums.(images{i}).(doses{d})(s) = mean(int_means);
%                 
%             end
%             
%         end
%         
%         means(i,d) = nanmean(sums.(images{i}).(doses{d}));
%         errors(i,d) = nanstd(sums.(images{i}).(doses{d}));
%         
%     end
%         
% end
% 
% labels.images = images; labels.doses = doses;
% 
% end
% 
% function s = preallocate_struct(fields, with)
% 
% if nargin < 2
%     with = [];
% end
% 
% s = struct();
% 
% for i = 1:length(fields)
%     s.(fields{i}) = with;
% end
% 
% end
