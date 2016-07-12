classdef ExecuteCommands < handle
    properties (Access=public)
        Data
        Labels
        Commands
        Output
    end
    methods
        function this = ExecuteCommands(data_struct,command_hist_obj)
           this.Data = data_struct.data;
           this.Labels = data_struct.labels;
           commands_to_execute = command_hist_obj.Commands;
           this.Commands = commands_to_execute;
           this.execute();
        end
        function execute(this)
            commands_to_execute = this.Commands;
            data = this.Data;
            labels = this.Labels;
            for i = length(commands_to_execute)
                try
                    eval(commands_to_execute{i});
                catch
                    error('Could not evaluate line %d:\n%s',i,commands_to_execute{i});
                end
            end
            
            if ~(exist('data','var') == 1)
                error('The ultimate output of your command sequence must be called ''data''');
            end
            
            this.Output.data = data;
            this.Output.labels = labels;
        end
    end
end