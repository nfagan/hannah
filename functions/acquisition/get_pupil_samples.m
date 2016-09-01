function store_pupilsamples = get_pupil_samples()

edfdir = pathfor('edfs');
savedir = fullfile(pathfor('pupilSamples'),'0815');

monks = filenames(only_folders(rid_super_sub_folder_references(dir(edfdir))));

firstsession = true;
for i = 1:length(monks)
    monkpath = fullfile(edfdir,monks{i});
    doses = filenames(only_folders(rid_super_sub_folder_references(dir(monkpath))));
    for d = 1:length(doses)
        cd(fullfile(monkpath,doses{d}));
        edfs = dir('*.edf');
        sessions = sessionnames(edfs);
        if length(sessions) ~= length(edfs)
            error('each edf file must have a session name');
        end
        
        for s = 1:length(sessions)
            edf_dir = sessionindex(edfs,sessions{s});
            edf = Edf2Mat(edf_dir(1).name);
            
            pupilsamples = struct();
            
            pupilsamples.data = cell(1,1);
            pupilsamples.data{1} = struct();
            
            pupilsamples.data{1}.x = edf.Samples.posX;
            pupilsamples.data{1}.y = edf.Samples.posY;
            pupilsamples.data{1}.t = edf.Samples.time;
            
            pupilsamples.labels.monkeys = {monks{i}};
            pupilsamples.labels.sessions = {sessions{s}};
            pupilsamples.labels.doses = {doses{d}};
            
            pupilsamples = DataObject(pupilsamples);
            
            if firstsession
                store_pupilsamples = pupilsamples;
                firstsession = false;
            else
                store_pupilsamples = [store_pupilsamples;pupilsamples];
            end
            
        end
        
    end
end

cd(savedir);

pupilsamples_struct = obj2struct(store_pupilsamples);

save('pupilSamples.mat','pupilsamples_struct');

end

function names = filenames(direc)
    names = {direc(:).name}';
end

function sessions = sessionnames(direc)
    sessions = filenames(direc);
    sessions = cellfun(@(x) x(isstrprop(x,'digit')),sessions,'UniformOutput',false);
    empty_ind = cellfun(@isempty,sessions);
    sessions(empty_ind) = [];
end

function direc = sessionindex(direc,session)
    names = filenames(direc);
    session_ind = cellfun(@(x) ~isempty(strfind(x,session)),names);
    
    if sum(session_ind) > 1
        error('More than one possible session');
    end
    
    session_ind = find(session_ind == 1);
    direc = direc(session_ind);
end