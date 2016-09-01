function [quads,all_keep] = looks_after_eyes(time)

if ~isa(time,'DataObject')
    time = DataObject(time);
end

time = no_zeros(time);

eyes = time(time == 'eyes');
quads = time(time ~= {'eyes','mouth','image','face'});

starttimes = unique(eyes(:,1).data);

all_keep = true(count(quads,1),1);
for i = 1:length(starttimes)
    fprintf('\n%d perc',round(i/length(starttimes)));
    
    eye_image = eyes(eyes(:,1).data == starttimes(i));
    quad_index = quads(:,1).data == starttimes(i);
    quad_image = quads(quad_index);
    
    rois = unique(quad_image.labels.rois);
    
    eye_minimum = min(eye_image(:,3).data); %   first fix event to eyes
    
    keep_index = true(count(quad_image,1),1);
    for r = 1:length(rois)
        roi_index = quad_image == rois{r};
        oneroi = quad_image(roi_index);
       
        came_after_eye_minimum = oneroi(:,3).data > eye_minimum;
        keep_index(roi_index) = came_after_eye_minimum;
    end
    
    all_keep(quad_index) = keep_index;
    
end


quads = quads(all_keep);






