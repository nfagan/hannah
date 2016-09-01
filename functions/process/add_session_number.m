function obj = add_session_number(obj)

if ~islabelfield(obj,'sessionNumbers')
    obj = addlabelfield(obj,'sessionNumbers');
end

sessions = obj('sessions');

sessions = cellfun(@(x) {x(end)}, sessions);

session_numbers = unique(sessions);

for k = 1:length(session_numbers)
    
    index = strcmp(sessions,session_numbers{k});
    
    obj('sessionNumbers',index) = ['session' session_numbers{k}];
    
end


end

