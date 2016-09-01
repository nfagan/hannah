function output = add_session_id(obj)

sessions = obj.labels.sessions;
monks = obj.labels.monkeys;

for i = 1:length(sessions)
    sessions{i} = [monks{i}(1:2) sessions{i}];
end

inputs.data = obj.data;
inputs.labels = obj.labels;
inputs.labels.sessions = sessions;

output = DataObject(inputs);