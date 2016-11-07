%{
    remove_outliers.m -- function for identifying and removing outliers
    from data. <data> is expected to be a DataObject, although the function
    will attempt to create a DataObject from <data> if it's in some other
    form. Try typing help DataObject if the usage of DataObjects is
    unclear.

    Outliers are defined in the attached function within_outlier_bounds.
    Right now, outliers are data that are beyond +/- 2 S.D.s of the mean.

%}

function out = remove_outliers(data,within)

if ~isa(data,'DataObject')
    data = DataObject(data);
end

if ( nargin < 2 )
    within = {'sessions', 'images', 'rois'};
end

obj = data;

assert( ~strcmp(obj.dtype, 'cell'), 'Cannot currently remove outliers of cell-type data' );

ind = isnan(data) | isinf(data.data) | data.data == 0;  %   remove errors
data = data(~ind);

indices = getindices(data,within,'showProgress');   %   get the index of each unique combination
                                                    %   of the unique labels in <within>,
                                                    %   ignoring empty indices

keep = false(count(data,1),1);

data = data.data;

for i = 1:length(indices)
    fprintf('\nProcessing %d of %d',i,length(indices));
    
    index = indices{i};
    within_bounds = within_outlier_bounds(data,index);
    keep(index) = within_bounds;        %   keep data that are within the outlier
                                        %   bounds defined in the function below
end

obj = obj(keep);

out.object = obj;
out.index = keep;

end


function within_bounds = within_outlier_bounds(data,index)

data = data(index);     %   extract data for this session and
                        %   this image
    
deviation = std(data);

bounds = [mean(data) + deviation*2, mean(data) - deviation*2];

within_bounds = data <= bounds(1) & data >= bounds(2);

end
% 
% function within_bounds = within_outlier_bounds_cell(data, index)
% 
% data = concatenateData( data(index) );
% 
% deviation = std( data(:) );
% bounds = [mean(data(:)) + deviation*2, mean(data(:)) - deviation * 2];
% 
% within_bounds = data <= bounds(1) & data >= bounds(2);
% 
% within_bounds = sum( within_bounds, 2 ) == 
% 
% 
% end
