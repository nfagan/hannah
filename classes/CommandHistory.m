classdef CommandHistory < handle
    
    properties (SetObservable, AbortSet, Access=public)
        Commands
        SaveDirectory
    end
    
    methods
        function this = CommandHistory(str)
            this.SaveDirectory = str;
            this.Commands = cell(1);
            addlistener(this,'SaveDirectory','PostSet',@CommandHistory.TestValidDirectory);
            TestValidDirectory([],[],this);
        end
        function TestValidDirectory(src,evnt,this)
            if nargin == 2
                current_save_directory = evnt.AffectedObject.SaveDirectory;
            else
                current_save_directory = this.SaveDirectory;
            end
            
            try 
                cd(current_save_directory)
            catch
                specified_directory = prompt_for_valid_directory(...
                    '\nSpecify the full or relative path of where to save\n>');
                if nargin == 2
                    evnt.AffectedObject.SaveDirectory = specified_directory;
                else
                    this.SaveDirectory = specified_directory;
                end
            end
            
        end
        function appendCommands(this,to_append)
            if ~iscell(to_append)
                error('Commands to be appended must be stored in a cell array');
            end
            new_commands = this.Commands;            
            if isempty(this.Commands{1})
                n_current_commands = 0;
            else
                n_current_commands = length(new_commands);
            end
            for i = 1:length(to_append)
                new_commands{n_current_commands+i} = to_append{i};
            end
            this.Commands = new_commands;
        end
        function clearAll(this)
            fprintf('\nClearing command history ...\nOK');
            this.Commands = cell(1);
        end
        function import(this,import_file_name)
            get_new_lines = true; stp = 1;
            
            current_commands = this.Commands;
            if ~isempty(current_commands{1})
                prompt = sprintf('\nWarning: Data in ''Commands'' will be ovewritten. Proceed? (Y/N)\n>');
                do_overwrite = ask_to_overwrite(prompt);
            else
                do_overwrite = true;
            end
            
            if do_overwrite
                try
                    id = fopen(import_file_name);
                catch
                    error('The specified file ''%s'' does not exist in the current path.',import_file_name);
                end
                while get_new_lines
                    current_line = fgetl(id);
                    if ischar(current_line)
                       imported_commands{stp} = current_line; 
                       stp = stp + 1; 
                    else
                        get_new_lines = false;
                    end
                end
                fclose(id);
                if stp > 1
                    this.Commands = imported_commands;
                else
                    fprintf('\nWarning: No Commands found in ''%s''. Skipping import ...',import_file_name);
                end
            else
                fprintf('\nSkipping import');
            end
            fprintf('\nOK');
        end
        function export(this,export_file_name)
            
            if nargin < 2
                error('Specify a file name to save');
            end
            
            save_directory = this.SaveDirectory;
            commands = this.Commands;
            
            if ~iscell(commands)
                error('Commands must be in a cell array');
            end
            
            cd(save_directory);
            if exist(export_file_name,'file') == 2
                prompt = sprintf(['\nWARNING: ''%s'' already exists and' ...
                    , ' would be overwritten by this operation.' ...
                    , ' Do you wish to overwrite it? (Y/N)\n>'],export_file_name);
                do_overwrite = ask_to_overwrite(prompt);
            else
                do_overwrite = true;
            end
            if do_overwrite
                id = fopen('hello.txt','w');
                for i = 1:length(commands)
                    if i == 1
                        print_command = sprintf('%s',commands{i});
                    else
                        print_command = sprintf('\n%s',commands{i});
                    end
                    fprintf(id,print_command);
                end
                fclose(id);
            else
                fprintf(['\nNot saving ''%s'' because user opted not to\n' ...
                    , ' overwrite a currently existing file.'],export_file_name);
            end
            fprintf('\nOK');
        end
    end
end
    