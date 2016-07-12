classdef RespondToSaveDirectoryChange < handle
    methods 
        function this = RespondToSaveDirectoryChange(evtobj)
            addlistener(evtobj,'save_directory','PostSet',@RespondToSaveDirectoryChange.TestValidSaveDirectory);
        end
    end
    methods (Static)
        function TestValidSaveDirectory()
            disp('would-print');
        end
    end
end
    