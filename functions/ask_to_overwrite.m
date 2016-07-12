function do_overwrite = ask_to_overwrite(prompt)

if nargin < 1
    prompt = sprintf(['\nWARNING: a file or variable already exists and' ...
        , ' would be overwritten by this operation. Do you wish to overwrite it? (Y/N)\n>']);
end

valid_choice = false;
    
while ~valid_choice
    check_to_overwrite = input(prompt,'s');
    if strcmpi(check_to_overwrite,'y')
        do_overwrite = true;
        valid_choice = true;
    elseif strcmpi(check_to_overwrite,'n')
        do_overwrite = false;
        valid_choice = true;
    else
        fprintf('\nPlease input ''Y'' or ''N''');
    end
end 

end