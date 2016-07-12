function pos = define_custom_rois(region)

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
    otherwise
        error('''%s'' is not a recognized region.',region);
end