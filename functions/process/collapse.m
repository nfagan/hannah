%{
    collapse.m -- function for collapsing image category labels across
    gender, gaze, and/or expression.
%}

function obj = collapse(obj,across)

if ~isa(obj,'DataObject')
    obj = DataObject(obj);
end

if ~iscell(across)
    across = {across};
end

images = obj('images');

pattern_fn = @(x) length(x) == 4 & ... %    get rid of outdoors + scrambled images
    ~strcmp(x,'outdoors') & ...
    ~strcmp(x,'scrambled');

pattern_matches = cellfun(pattern_fn,images);

images = images(pattern_matches);

for i = 1:length(images)
    for k = 1:length(across)
        
        switch across{k}
            case 'gender'
                images{i}(2) = 'a';
            case 'gaze'
                images{i}(3) = 'a';
            case 'expression'
                images{i}(4) = 'a';
            otherwise
                error('Unsupported collapse term %s',across{k});
        end 
    end
end

obj('images',pattern_matches) = images;

% obj.labels = collapse_across(across,obj.labels);

end