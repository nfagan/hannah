function fixedLabels = set_all_h(labels,varargin)

params = struct(...
    'rois',[],...
    'monkeys',[],...
    'doses',[],...
    'images',[],...
    'sessions',[] ...
    );

params = structInpParse(params,varargin);

fields = fieldnames(params);

for i = 1:length(fields);
    if (~isempty(params.(fields{i}))) && (~iscell(params.(fields{i})))
        params.(fields{i}) = {params.(fields{i})};
    end
end
    
N = length(labels{1});

fixedLabels = labels;

if ~isempty(params.rois);
    fixedLabels{1} = repmat(params.rois,N,1);
end

if ~isempty(params.monkeys);
    fixedLabels{2} = repmat(params.monkeys,N,1);
end

if ~isempty(params.doses);
    fixedLabels{3} = repmat(params.doses,N,1);
end

if ~isempty(params.images);
    fixedLabels{4} = repmat(params.images,N,1);
end

if ~isempty(params.blocks);
    fixedLabels{5} = repmat(params.sessions,N,1);
end



    







    