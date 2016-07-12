
startDirectory = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/data';

monkeys = {'ephron'};
doses = {'saline','low','high'};

for i = 1:length(monkeys)
    for k = 1:length(doses);
        dataDirectory = get_umbr_dir_hannah(startDirectory,monkeys{i},doses{k});
        [allTimes,allEvents] = getFilesDoug(dataDirectory);
        
    end
end

% dataDirectory = '/Users/hannahweinberg-wolf/Documents/5HTP_FV_Analysis_Code/codes_for_hannah/new_test_data/High';
% cd('/Users/hannahweinberg-wolf/Documents/5HTP_FV_Analysis_Code/codes_for_hannah');

[allTimes,allEvents] = getFilesDoug(dataDirectory);


%%

imageDisplayLength = 5000; %ms

allTimes2 = cell(1,length(allTimes));
for i = 1:length(allTimes);
    oneTimes = allTimes{i};
    startTimes = oneTimes(:,2);
    startTimes(:,2) = startTimes(:,1) + imageDisplayLength; %ms
    allTimes2{i} = startTimes;
end

%% create index of wanted trials and initialize metrics

trialindex = {'UBDT', 'UBDS', 'UBDN', 'UBDL', 'UBIT', 'UBIS', 'UBIN', 'UBIL', 'UGDT', 'UGDS', 'UGDN', 'UGDL', 'UGIT', 'UGIS', 'UGIN', 'UGIL', 'Scr', 'Out'}; 
% hlookimageall = [];
% hlookfixall = [];

hcompletedtrials = [];

hlookimage = [];
hfixlook = [];

hlookimagesem = [];
hfixlooksem = [];

hfixnum = [];

%%
for i = 1:18; 
    wantedTrials = char(trialindex{i});

switch wantedTrials
    case 'UBDT';
        extractCode = 1;
    case 'UBDS';
        extractCode = 2;
    case 'UBDN';
        extractCode = 3;
    case 'UBDL';
        extractCode = 4;
    case 'UBIT';
        extractCode = 5;
    case 'UBIS';
        extractCode = 6;
    case 'UBIN';
        extractCode = 7;
    case 'UBIL';
        extractCode = 8;
    case 'UGDT';
        extractCode = 9;
    case 'UGDS';
        extractCode = 10;
    case 'UGDN';
        extractCode = 11;
    case 'UGDL';
        extractCode = 12;
    case 'UGIT';
        extractCode = 13;
    case 'UGIS';
        extractCode = 14;
    case 'UGIN';
        extractCode = 15;
    case 'UGIL';
        extractCode = 16;
    case 'Scr';
        extractCode = 17;
    case 'Out';
        extractCode = 18;
end

output_allTimes = cell(1,length(allTimes));
for i = 1:length(allTimes);
    indexOfWantedTrials = allTimes{i}(:,1) == extractCode;
    output_allTimes{i} = allTimes2{i}(indexOfWantedTrials,:);
end

%% add ROI coordinates

width = 1280; %% check these
height = 960;
shiftAmt = 200; %% confirm that units is pixels

middleX = width/2;
middleY = height/2;

% probable resolution 1280x960
% middle resolution = 

pos.minX = middleX - shiftAmt; %define in pixels
pos.maxX = middleX + shiftAmt;
pos.minY = middleY - shiftAmt;
pos.maxY = middleY + shiftAmt;

%% remove pos input to getDur to ignore positional boundaries

% data = getDur_pupilSize700(allTimes2,allEvents,pos);
data = getDur_pupilSize700(output_allTimes,allEvents,pos);

%% get outputs from data structure

% ignore second column

lookingDuration = data.lookingDuration'; %sum total of duration of all fixation events, per image flipped
nSuccessfulTrials = length(lookingDuration);
lengthFixEvents = data.fixEventDuration'; %length of each individual fixation flipped
pupilSizePerFixEvent = data.pupilSizePerFixEvent;

sumlookingDuration = sum(lookingDuration,2);
sumlengthFixEvents = sum(lengthFixEvents,2);

semlookimage = std(lookingDuration(1,:))/sqrt(length(lookingDuration));
semfixlook = std(lengthFixEvents(1,:))/sqrt(length(lengthFixEvents));


%%%%%%%%%% PER IMAGE CATEGORY CHANGE PER RUN

% hlookimageall = [hlookimageall;lookingDuration(1,:)];
% hlookfixall = [hlookfixall;lengthFixEvents(1,:)];

hcompletedtrials = [hcompletedtrials, nSuccessfulTrials];

hlookimage = [hlookimage, sumlookingDuration(1)/length(lookingDuration)];

hlookimagesem = [hlookimagesem, semlookimage];
hfixlook = [hfixlook, sumlengthFixEvents(1)/length(lengthFixEvents)];
hfixlooksem = [hfixlooksem,
    semfixlook];

hfixnum = [hfixnum, (length(lengthFixEvents)/length(lookingDuration))];

end

%%

% run stats, etc. ....

rawFixNumPerSession{dose}{imageCategory} = 1;
rawFixNumPerSession{dose}








