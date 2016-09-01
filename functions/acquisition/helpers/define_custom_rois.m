function pos = define_custom_rois(region)

img_x_0 = -200;
img_y_0 = -200;
img_height = 400;
img_width = 400;

screen_width = 1280;
screen_height = 960;

switch region
    case 'eyes'
        pos.minX = -10e3;
        pos.maxX = 10e3;
        pos.minY = -10e3;
        pos.maxY = 10e3;
    case 'mouth'
        pos.minX = -10e3;
        pos.maxX = 10e3;
        pos.minY = -10e3;
        pos.maxY = 10e3;
    case 'image'
        pos.minX = -10e3;
        pos.maxX = 10e3;
        pos.minY = -10e3;
        pos.maxY = 10e3;
    case 'face'
        pos.minX = -10e3;
        pos.maxX = 10e3;
        pos.minY = -10e3;
        pos.maxY = 10e3;
    case 'littleQuadrant1'
%         pos.minX = 0;
%         pos.maxX = img_width/2;
%         pos.minY = 0;
%         pos.maxY = img_height/2;
        pos.minX = screen_width/2 + img_x_0 + img_width/2;
        pos.maxX = screen_width/2 + img_x_0 + img_width;
        pos.minY = screen_height/2 + img_y_0;
        pos.maxY = screen_height/2 + img_y_0 + img_height/2;
    case 'littleQuadrant2'
%         pos.minX = -img_width/2;
%         pos.maxX = 0;
%         pos.minY = 0;
%         pos.maxY = img_height/2;
        pos.minX = screen_width/2 + img_x_0;
        pos.maxX = screen_width/2 + img_x_0 + img_width/2;
        pos.minY = screen_height/2 + img_y_0;
        pos.maxY = screen_height/2 + img_y_0 + img_height/2;
    case 'littleQuadrant3'
%         pos.minX = -img_width/2;
%         pos.maxX = 0;
%         pos.minY = -img_height/2;
%         pos.maxY = 0;
        pos.minX = screen_width/2 + img_x_0;
        pos.maxX = screen_width/2 + img_x_0 + img_width/2;
        pos.minY = screen_height/2 + img_y_0 + img_height/2;
        pos.maxY = screen_height/2 + img_y_0 + img_height;
    case 'littleQuadrant4'
%         pos.minX = 0;
%         pos.maxX = img_width/2;
%         pos.minY = -img_height/2;
%         pos.maxY = 0;
        pos.minX = screen_width/2 + img_x_0 + img_width/2;
        pos.maxX = screen_width/2 + img_x_0 + img_width;
        pos.minY = screen_height/2 + img_y_0 + img_height/2;
        pos.maxY = screen_height/2 + img_y_0 + img_height;
    case 'quadrant1'
%         pos.minX = 0;
%         pos.maxX = screen_width/2;
%         pos.minY = screen_height/2;
%         pos.maxY = screen_height;
        pos.minX = screen_width/2;
        pos.maxX = screen_width;
        pos.minY = 0;
        pos.maxY = screen_height/2;
    case 'quadrant2'
%         pos.minX = -screen_width/2;
%         pos.maxX = 0;
%         pos.minY = 0;
%         pos.maxY = screen_height/2;
        pos.minX = 0;
        pos.maxX = screen_width/2;
        pos.minY = 0;
        pos.maxY = screen_height/2;
    case 'quadrant3'
%         pos.minX = -screen_width/2;
%         pos.maxX = 0;
%         pos.minY = -screen_height/2;
%         pos.maxY = 0;
        pos.minX = 0;
        pos.maxX = screen_width/2;
        pos.minY = screen_height/2;
        pos.maxY = screen_height;
    case 'quadrant4'
%         pos.minX = 0;
%         pos.maxX = screen_width/2;
%         pos.minY = -screen_height/2;
%         pos.maxY = 0;
        pos.minX = screen_width/2;
        pos.maxX = screen_width;
        pos.minY = screen_height/2;
        pos.maxY = screen_height;
    otherwise
        error('''%s'' is not a recognized region.',region);
end