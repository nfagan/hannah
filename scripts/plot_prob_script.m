%%
load('/Volumes/My Passport/NICK/Chang Lab 2016/hannah/new_data_structure/pre_processed_data/0725/Time.mat');
time = save_field;
%%

modified = separate_data_obj(time,'images',{'--outdoors'});
modified = separate_data_obj(modified,'images',{'--scrambled'});

%%

%   collapse across gender

modified.labels = collapse_across({'gender'},modified.labels);

%   specify a drug dose

monkeys = {'hitch','ephron'};
doses = {'high','low','saline'};
% doses = {'high'};

for i = 1:length(monkeys)
for j = 1:length(doses)

monkey = monkeys{i};
dose = doses{j};

gender_collapsed_separated = separate_data_obj(modified,...
    'doses',{dose},...
    'monkeys',{monkey});

roi_look_order(gender_collapsed_separated,{'eyes','mouth'},100,...
    'flip',true,...
    'method','multP',...
    'appendToDirectory',sprintf('0727/subtr/%s/%s',monkey,dose), ...
    'monkey',monkey ...
    );

end
end