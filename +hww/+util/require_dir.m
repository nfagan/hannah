function require_dir(pathstr)

if ( exist(pathstr, 'dir') ~= 7 ), mkdir( pathstr ); end;

end