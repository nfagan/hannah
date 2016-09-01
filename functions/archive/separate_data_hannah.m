function [outputValues,outputLabels] = separate_data_hannah(storeValues,storeLabels,varargin)

all_rois = unique(storeLabels{1});
all_monkeys = unique(storeLabels{2});
all_dosages = unique(storeLabels{3});
all_categories = unique(storeLabels{4});
all_sessions = unique(storeLabels{5});

all_genders = unique(storeLabels{6});
all_gazes = unique(storeLabels{7});
all_expressions = unique(storeLabels{8});

params = struct(...
    'rois','all',...
    'monkeys','all',...
    'doses','all',...
    'images','all',...
    'sessions','all',...
    'genders','all',...
    'gazes','all',...
    'expressions','all',...
    'errorIfEmpty',0 ...
    );

params = structInpParse(params,varargin);

rois = params.rois;
monkeys = params.monkeys;
doses = params.doses;
images = params.images;
sessions = params.sessions;

genders = params.genders;
gazes = params.gazes;
expressions = params.expressions;

% -- parse desired variables

if strcmp(genders,'all');
    wantedGenders = all_genders;
else
    wantedGenders = genders;
end

if strcmp(gazes,'all');
    wantedGazes = all_gazes;
else
    wantedGazes = gazes;
end

if strcmp(expressions,'all');
    wantedExpressions = all_expressions;
else
    wantedExpressions = expressions;
end

if strcmp(rois,'all');
    wantedRois = all_rois;
else
    wantedRois = rois;
end

if strcmp(monkeys,'all');
    wantedMonkeys = all_monkeys;
else
    wantedMonkeys = monkeys;
end

if strcmp(doses,'all');
    wantedDoses = all_dosages;
else
    wantedDoses = doses;
end

if strcmp(images,'all');
    wantedImages = all_categories;
else
    wantedImages = images;
end

if strcmp(sessions,'all');
    wantedSessions = all_sessions;
else
    wantedSessions = sessions;
end

% -- extract based on wantedVariables

genderIndex = zeros(size(storeLabels{1},1),length(wantedGenders));
for i = 1:length(wantedGenders);
    genderIndex(:,i) = strcmp(storeLabels{6},wantedGenders{i});
end

gazeIndex = zeros(size(storeLabels{1},1),length(wantedGazes));
for i = 1:length(wantedGazes);
    gazeIndex(:,i) = strcmp(storeLabels{7},wantedGazes{i});
end

expressionIndex = zeros(size(storeLabels{1},1),length(wantedExpressions));
for i = 1:length(wantedExpressions);
    expressionIndex(:,i) = strcmp(storeLabels{8},wantedExpressions{i});
end

roiIndex = zeros(size(storeLabels{1},1),length(wantedRois));
for i = 1:length(wantedRois);
    roiIndex(:,i) = strcmp(storeLabels{1},wantedRois{i});
end

monkInd = zeros(size(storeLabels{1},1),length(wantedMonkeys));
for i = 1:length(wantedMonkeys);
    monkInd(:,i) = strcmp(storeLabels{2},wantedMonkeys{i});
end

doseIndex = zeros(size(storeLabels{1},1),length(wantedDoses));
for i = 1:length(wantedDoses);
    doseIndex(:,i) = strcmp(storeLabels{3},wantedDoses{i});
end

imageIndex = zeros(size(storeLabels{1},1),length(wantedImages));
for i = 1:length(wantedImages);
    imageIndex(:,i) = strcmp(storeLabels{4},wantedImages{i});
end

sessionIndex = zeros(size(storeLabels{1},1),length(wantedSessions));
for i = 1:length(wantedSessions);
    sessionIndex(:,i) = strcmp(storeLabels{5},wantedSessions{i});
end

genderInd = sum(genderIndex,2) >= 1;
gazeInd = sum(gazeIndex,2) >= 1;
expInd = sum(expressionIndex,2) >= 1;

monkInd = sum(monkInd,2) >= 1;
roiIndex = sum(roiIndex,2) >= 1;
doseIndex = sum(doseIndex,2) >= 1;
imageIndex = sum(imageIndex,2) >= 1;
sessionIndex = sum(sessionIndex,2) >= 1;

allInds = roiIndex & doseIndex & imageIndex & sessionIndex & monkInd ...
    & genderInd & gazeInd & expInd;

for k = 1:length(storeLabels);
    oneLab = storeLabels{k};
    outputLabels{k} = oneLab(allInds); %only keep wanted labels
end

outputValues = storeValues(allInds,:); % only keep wanted values;

if isempty(outputValues) && params.errorIfEmpty
    msg = sprintf(['\nNo data matched the input criteria.\n\n1) Confirm that your specified drugs and dosages'...
        , ' are also present in the global variables drugTypes and dosages.' ...
        , '\n2) If specifying block numbers, ensure you''re running the analysisPortion'...
        , ' with the appropriate number of blocks.\n3) As it stands, there are very few data files per drug / dose combination.'...
        , ' Thus, it may prove difficult or impossible to separate by session number.']);
    error(msg)
end
