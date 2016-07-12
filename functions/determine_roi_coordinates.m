function pos = determine_roi_coordinates(roi)

width = 1280; % resolution of the screen
height = 960;

middleX = width/2;
middleY = height/2;

switch roi 
    case 'eyes'
        xUpper = 200;
        xLower = 200;
        yUpper = 200;
        yLower = 0;
    case 'mouth'
        xUpper = 200;
        xLower = 200;
        yUpper = 0;
        yLower = 200;
    case 'image'
        xUpper = 200;
        xLower = 200;
        yUpper = 200;
        yLower = 200;
    case 'screen'
        xUpper = width/2;
        xLower = width/2;
        yUpper = height/2;
        yLower = height/2;
end

pos.minX = middleX - xLower; %define in pixels
pos.maxX = middleX + xUpper;
pos.minY = middleY - yLower;
pos.maxY = middleY + yUpper;
