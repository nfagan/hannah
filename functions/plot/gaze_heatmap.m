function binned = gaze_heatmap(coords,roi,bin,varargin)

params = struct(...
    'clims', [], ...
    'overlaidImage',[], ...
    'flip', false ...
    );
params = structInpParse(params,varargin);

if ~isa(coords,'DataObject');
    try
        coords = DataObject(coords);
    catch
        error('Make looking coordinates into a data object before proceeding');
    end
end

coords = obj2struct(coords);

bin_x = bin.x; % pixels
bin_y = bin.y; % pixels

x = coords.data(:,1);
y = coords.data(:,2);

validate_roi_struct(roi.minX,roi.maxX,bin_x);
validate_roi_struct(roi.minY,roi.maxY,bin_y);

roi_x = roi.minX:bin_x:roi.maxX;
roi_y = roi.minY:bin_y:roi.maxY;

binned = zeros(length(roi_x)-1,length(roi_y)-1);
for k = 1:length(roi_x)-1
    for j = 1:length(roi_y)-1
        binned(j,k) = sum((x >= roi_x(k) & x < roi_x(k+1)) & (y >= roi_y(j) & y < roi_y(j+1)));
    end
end

if ~isempty(params.clims)
    binned(binned < params.clims(1)) = params.clims(1);
    binned(binned > params.clims(2)) = params.clims(2);
end

if params.flip
    binned = flipud(binned);
end

figure;
imagesc(imgaussfilt(binned,2));
colormap('jet');
colorbar;

if ~isempty(params.overlaidImage)
    hold on;
    params.overlaidImage = scale_img(params.overlaidImage,binned);
    img = image(params.overlaidImage);
    set(img,'AlphaData',0.6);
end

function validate_roi_struct(roi_min,roi_max,bin)
    if rem((roi_max - roi_min)/bin,1) ~= 0
        error('Invalid bin size');
    end
end

end

function img = scale_img(img,binned)

img = imresize(img, [size(binned,1) size(binned,2) ]);

end

