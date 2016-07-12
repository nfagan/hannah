function specified_directory = prompt_for_valid_directory(prompt)

    original_directory = cd;
    
    if nargin == 0
        prompt = 'Please input a directory name.';
    end

    valid_directory = 0;
    
    while valid_directory == 0
        specified_directory = input(prompt);
        try 
            cd(specified_directory)
            valid_directory = 1;
            cd(original_directory);
        catch
            base_error_message = sprintf('The specified directory (%s) is invalid.',...
                specified_directory);
            if strncmpi(computer,'mac',3) && any(strfind(specified_directory,'\'))
                error_msg = sprintf(['%s. It looks like you''re using a Mac, but' ...
                    , ' your specified directory (%s) contains forward slashes.' ...
                    , ' Replace these with backslashes if you''re sure the specified' ...
                    , ' folder exists.'],base_error_message,specified_directory);
            elseif strncmpi(computer,'pc',2) && any(strfind(specified_directory,'/'))
                error_msg = sprintf(['%s. It looks like you''re using Windows, but' ...
                    , ' your specified directory (%s) contains backslashes.' ...
                    , ' Replace these with forward slashes if you''re sure the specified' ...
                    , ' folder exists.'],base_error_message,specified_directory);
            else
                error_msg = base_error_message;
            end
            fprintf('\nERROR: %s. Please input a valid directory.',error_msg);
        end
    end
end