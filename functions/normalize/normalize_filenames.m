%{

    normalize.m -- function for normalizing the data in <obj> to the
    mean of the corresponding saline data. <within> controls the
    specificity of the normalization. Usually, we will normalize within
    monkey, file, dose, and roi.

    <obj> must be a DataObject; otherwise, the function will attempt to 
    convert it into one. Try typing ''help DataObject'' if you are unsure
    about its usage.

    N.B. It is advisable that you first call remove_outliers(obj) and
    truthy(obj) before attempting to normalize.

%}

function [obj, keep] = normalize_filenames(obj,within, extra_search)

if ( nargin < 3 ); extra_search = 'images'; end

tic;

if nargin < 2
    within = {'monkeys','doses','rois'};
end

%   ensure that 'doses' is in <within>, and mark its place

doses_index = strcmp(within,'doses');

if ~any(doses_index)
    error('<within> must include ''doses''');
end

if ~isa(obj,'DataObject');
    obj = DataObject(obj);
end

%   getindices returns <indices> of all the unique combinations of unique
%   labels in the categories of <within>. <combs> indicates the combination
%   of labels used to construct each index.

[indices, combs] = getindices(obj,within,'showProgress');

keep = false(count(obj,1),1);
for i = 1:length(indices)
    fprintf('\nNormalizing %d of %d',i,length(indices));
    
    data = obj(indices{i});
    
    %   look for all the same labels in combs, except for dose; replace it
    %   with saline
    
    search = [combs(i,~doses_index) {'saline'}];
    
    saline = obj(eq(obj,search,within));    %   same as saying obj(obj == search)
                                            %   but much faster, because we
                                            %   limit which fields to
                                            %   search through
    
    if isempty(saline)
        continue;
    end
    
    filenames = data.uniques( extra_search );
    
    int_keep = false( size(data.data,1), 1 );
    
    for k = 1:numel(filenames)
        
        extr_keep = eq( data, filenames{k}, extra_search );
        
        if ( ~any(extr_keep) ); continue; end;
        
        extr = data.data( extr_keep );
        extr_sal = saline.only(filenames{k});
        
        if ( isempty(extr_sal) ); continue; end;
        
        normed = extr ./ mean(extr_sal.data);
        
        data(extr_keep) = normed;
        int_keep(extr_keep) = true;
        
    end
      
    obj(indices{i}) = data.data;
    keep(indices{i}) = int_keep;
    
end

obj = obj(keep);

toc;
end