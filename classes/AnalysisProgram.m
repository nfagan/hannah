classdef AnalysisProgram < handle
    properties (SetObservable)
        Sets
        CurrentSet
        SaveDirectory
    end
    
    methods
        
        % // Init
        
        function this = AnalysisProgram(data_struct,init_params)
            if nargin < 2
                this.CurrentSet = 'Set1';
                this.Sets.(this.CurrentSet).CommandHistory = CommandHistory('');
                this.SaveDirectory = this.Sets.(this.CurrentSet).CommandHistory.SaveDirectory;
            else
                this.CurrentSet = init_params.set_name;
                this.SaveDirectory = init_params.save_directory;
                this.Sets.(this.CurrentSet).CommandHistory = CommandHistory(init_params.save_directory);
            end
            
            this.Sets.(this.CurrentSet).Original.Data = data_struct.data;
            this.Sets.(this.CurrentSet).Original.Labels = data_struct.labels;
            this.Sets.(this.CurrentSet).InUse = this.Sets.(this.CurrentSet).Original;
            fprintf('\nUsing Original Values');
            
            addlistener(this,'CurrentSet','PostSet',@AnalysisProgram.switchSet);
        end
        
        % // Functions defining data-set load in and save
        
        function loadData(this,filename)
            sets = load(filename);
            this.Sets = sets.Sets;
            this.CurrentSet = '';
        end
        
        function saveData(this,filename)
            Sets = this.Sets;
            filename = fullfile(this.SaveDirectory,filename);
            if exist(filename,'file') == 2
               do_save = ask_to_overwrite();
            else
                do_save = 1;
            end
            if do_save
                fprintf('\nSaving ''%s'' ...',filename);
                save(filename,'Sets');
            else
                fprintf('\nNot overwriting ''%s'' ...',filename);
            end
            fprintf('\nOK');
        end
        
        % // Functions defining data-set creation, deletion, renaming, and resetting
        
        function switchSet(src,evnt)
            sets = fieldnames(evnt.AffectedObject.Sets);
            new_set = evnt.AffectedObject.CurrentSet;
            if ~any(strcmp(sets,new_set))
                fprintf(['\nThe specified data set ''%s'' is not loaded into the AnalysisProgram.\n' ...
                    , 'Reseting CurrentSet to %s'],new_set,sets{1});
                evnt.AffectedObject.CurrentSet = sets{1};
            else
                fprintf('\nCURRENT SET: %s',new_set);
            end
            fprintf('\nOK');
        end        
        function reset(this)
            fprintf('\n\nResetting data-set ''%s'' to its original form',this.CurrentSet);
            this.Sets.(this.CurrentSet).InUse = this.Sets.(this.CurrentSet).Original;
            fprintf('\nOK'); event{1}.name = 'reset'; 
            commands = this.define_commands(event); this.addCommands(commands);
        end
        function default_set(this)
            all_sets = fieldnames(this.Sets);
            this.CurrentSet = all_sets{1};
            fprintf('\nSwitching CurrentSet to the default (%s) ...\nOK',all_sets{1});
        end
        function deleteSet(this,set_name)
            all_sets = fieldnames(this.Sets);
            if length(all_sets) > 1
                if any(strcmp(all_sets,set_name))
                    fprintf('\nDeleting set ''%s'' ...',set_name);
                    this.Sets = rmfield(this.Sets,set_name); 
                else
                    fprintf('\n''%s'' is not a recognized set name. Not deleting ...',set_name);
                end
                fprintf('\nOK');
                if strcmp(set_name,this.CurrentSet)
                    this.default_set();
                end
            else
                error('You can''t delete the only set in the program.');
            end
        end
        function newSet(this,set_name,data_struct)
            fprintf('\nAttempting to create new data set %s...',set_name)
            all_sets = fieldnames(this.Sets);
            do_make_new = 1;
            if any(strcmp(all_sets,set_name))
                prompt = sprintf(['\nWARNING: The specified set ''%s'' is already' ...
                    , ' present in this instance of the program.' ...
                    , ' Do you wish to overwrite it? (Y/N)\n>'],set_name);
                if ~ask_to_overwrite(prompt)
                    do_make_new = 0;
                    fprintf('\nNot overwriting DataSet ''%s'' ...',set_name);
                end
            end
            if do_make_new
                try
                    this.Sets.(set_name).Original.Data = data_struct.data;
                    this.Sets.(set_name).Original.Labels = data_struct.labels;
                catch
                    this.Sets.(set_name).Original.Data = data_struct.Data;
                    this.Sets.(set_name).Original.Labels = data_struct.Labels;
                end
                this.Sets.(set_name).InUse = this.Sets.(set_name).Original;
                this.Sets.(set_name).CommandHistory = CommandHistory(this.Sets.(all_sets{1}).CommandHistory.SaveDirectory);
                this.CurrentSet = set_name;
            end
            fprintf('\nOK');
        end
        function newSetFromSet(this,old_set,new_set)
            fprintf('\nAttempting to create new data set copied from %s...',old_set)
            if strcmp(new_set,old_set);
                error('The new set name cannot be the same as the old set name');
            end
            if ~this.isAPresentSet(old_set);
                error('Cannot copy a set (%s) that doesn''t exist.',old_set);
            end
            do_make_new = 1;
            if this.isAPresentSet(new_set)
                if ~ask_to_overwrite()
                    do_make_new = 0;
                    fprintf('\nNot overwriting DataSet ''%s'' ...',set_name);
                end
                if do_make_new
                    this.deleteSet(new_set);
                end
            end
            if do_make_new
                this.newSet(new_set,this.Sets.(old_set).InUse);
                this.setInUseAsOrig();
            end
        end
        function renameSet(this,old_set_name,new_set_name)
            if strcmp(new_set_name,old_set_name)
                error('The new set name cannot be the same as the old set name');
            end
            do_rename = 1;
            if ~this.isAPresentSet(old_set_name)
                error('Set name ''%s'' is not present in the program',old_set_name);
            elseif this.isAPresentSet(new_set_name)
                prompt = sprintf(['\nWARNING: The specified set ''%s'' is already' ...
                    , ' present in this instance of the program.' ...
                    , ' Do you wish to overwrite it? (Y/N)\n>'],new_set_name);
                if ~ask_to_overwrite(prompt)
                    do_rename = 0;
                    fprintf('\nNot overwriting DataSet ''%s'' ...',new_set_name);
                end
            end
            if do_rename
                fprintf('\nRenaming ''%s'' to ''%s'' ...',old_set_name,new_set_name);
                this.Sets.(new_set_name) = this.Sets.(old_set_name);
                this.Sets = rmfield(this.Sets,old_set_name);
                if strcmp(this.CurrentSet,old_set_name);
                    this.CurrentSet = new_set_name;
                end
                fprintf('\nOK');
            end
        end
        function setInUseAsOrig(this)
            this.Sets.(this.CurrentSet).Original = this.Sets.(this.CurrentSet).InUse;
        end
        function is_present = isAPresentSet(this,set_name)
            all_sets = fieldnames(this.Sets);
            if any(strcmp(all_sets,set_name))
                is_present = true;
            else
                is_present = false;
            end
        end
        
        % // Manipulating data / data labels
        
        function normalize(this,normalization_type,varargin)
            
            if nargin < 2
                error('Specify a kind of normalization to perform.');
            end
            
            values = this.Sets.(this.CurrentSet).InUse.Data;
            labels = this.Sets.(this.CurrentSet).InUse.Labels;
            
            switch normalization_type
                case 'roiToRoi'
                    norm_region = input('\nNormalize ...>','s'); norm_by_region = input('\nNormalize by ...>','s');
                    values = normalize_roi_to_roi(norm_region,norm_by_region,values,labels,varargin{:});
                case 'byX'
                    fprintf('\nWould normalize byX');
            end
            
            this.Sets.(this.CurrentSet).InUse.Data = values;
            this.Sets.(this.CurrentSet).InUse.Labels = labels;
            
        end
        
        function collapseAcross(this,to_collapse)
            fprintf('\nCollapsing labels ...');
            labels = this.Sets.(this.CurrentSet).InUse.Labels;
            labels = collapse_across(to_collapse,labels);
            this.Sets.(this.CurrentSet).InUse.Labels = labels;
            fprintf('\nOK');
            event{1}.name = 'collapse';
            commands = this.define_commands(event);
            this.addCommands(commands);
        end
        function querySelect(this,varargin)
            values = this.Sets.(this.CurrentSet).InUse.Data;
            labels = this.Sets.(this.CurrentSet).InUse.Labels;
            
            [output_values,output_labels,use_index] = separate_data_struct(values,labels,varargin{:});
            
            this.Sets.(this.CurrentSet).InUse.Data = output_values;
            this.Sets.(this.CurrentSet).InUse.Labels = output_labels;
            this.Sets.(this.CurrentSet).InUse.Index = use_index;
            
            event{1}.name = 'querySelect'; event{1}.selected = 'hitch';
            commands = this.define_commands(event);
            this.addCommands(commands);
        end
        
        % // Print current labels
        
        function list(this,varargin)
            labels = this.Sets.(this.CurrentSet).InUse.Labels;
            for i = 1:length(varargin)
                try
                    current_labels = labels.(varargin{i});
                    fprintf('\n%s',upper(varargin{i}));
                    uniques = unique(current_labels);
                    for k = 1:length(uniques)
                        fprintf('\n\t%s',uniques{k});
                    end
                catch
                    fprintf('\nNo ''%s'' field in labels struct.',varargin{i});
                end
            end
        end
        
        % // Plotting functions
        
        function bar_plots(this,varargin)
            values = this.Sets.(this.CurrentSet).InUse.Data;
            labels = this.Sets.(this.CurrentSet).InUse.Labels;
            means_and_errors_plot(values,labels,varargin{:});
        end
        
        % // Command storage, export, import, and resetting
        
        function importCommands(this,file_to_import)
            this.Sets.(this.CurrentSet).CommandHistory.import(file_to_import);
        end
        function exportCommands(this,file_to_export)
            this.Sets.(this.CurrentSet).CommandHistory.export(file_to_export);
        end
        function addCommands(this,command)
            this.Sets.(this.CurrentSet).CommandHistory.appendCommands(command);
        end
        function clearCommands(this)
            this.Sets.(this.CurrentSet).CommandHistory.clearAll();
        end
        
        % // Map command-strings to data manipulating / plotting events
        
        function commands = define_commands(this,events)
            str_if_unrecognized_event = 'unknown manipulation';
            if ~iscell(events)
                error('Events must be a cell array of structs');
            end
            commands = cell(1,length(events));
            for i = 1:length(events)
                switch events{i}.name
                    case 'querySelect'
%                         commands{i} = sprintf('Selected %s',events{i}.selected);
                        commands{i} = 'Selected values';
                    case 'plotted'
                        commands{i} = 'Plotted values';
                    case 'setGazeLabels'
                        commands{i} = 'set gaze labels';
                    case 'collapse'
                        commands{i} = 'Collapsed across gaze, gender, or expression';
                    case 'reset'
                        commands{i} = 'Reset data labels + values';
                    otherwise
                        fprintf(['\nWARNING: unrecognized event ''%s''. Setting command to' ...
                            , ' ''%s'''],events{i}.name,str_if_unrecognized_event);
                        commands{i} = str_if_unrecognized_event;
                end
            end
        end
        
    end
    
end