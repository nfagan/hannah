function output_Times = separate_images(imageTimes,imageCategory,wantedCategory)

allCategories = {'UBDT', 'UBDS', 'UBDN', 'UBDL', 'UBIT', 'UBIS', 'UBIN', ...
    'UBIL', 'UGDT', 'UGDS', 'UGDN', 'UGDL', 'UGIT', 'UGIS', 'UGIN', 'UGIL', ...
    'Scr', 'Out'};

rows = 1:length(allCategories);
codeIndex = strcmp(allCategories,wantedCategory);
extractCode = rows(codeIndex);

for i = 1:length(imageTimes);
    indexOfWantedTrials = imageCategory{i}(:,1) == extractCode;
    output_Times{i} = imageTimes{i}(indexOfWantedTrials,:);
end




