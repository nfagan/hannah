%{
    collapse.m -- function for collapsing image category labels across
    gender, gaze, and/or expression.
%}

function obj = cat_collapse(obj,across)

if ( ~isa(obj, 'Container') && ~isa(obj,'DataObject') )
    obj = DataObject(obj);
end

if ~iscell(across), across = {across}; end

%   DIFFERENT METHOD IF OBJ IS A CONTAINER

if ( isa(obj, 'Container') )
  images = unique( obj('images') );
  images = images( cellfun(@(x) numel(x) == 4, images) );
  replace_with = images;
  fs = { 'gender', 'gaze', 'expression' };
  ind = cellfun( @(x) find(strcmp(fs, x)), across );
  for i = 1:numel(ind)
    ref = struct( 'type', '()', 'subs', {{ind(i)}} );
    replace_with = cellfun( @(x) subsasgn(x, ref, 'a'), ...
      replace_with, 'UniformOutput', false );
  end
  for i = 1:numel(replace_with)
    obj = obj.replace( images(i), replace_with{i} );
  end
  return;
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