function data = getDur_hannah2(wantedTimes,allEvents,pos)

% global addPupilData;

add_image_times = 1;

for i = 1:length(wantedTimes); % while we're not looking at pupil data, make
                   %pupil variable empty
    pupil{i}.pupil = [];
end
% pupil{1}.pupil = [];
addPupilData = 0; %don't add pupilData
pupilDurThreshold = 0;

fullTime = 1500; %ms
preImageTime = 200; %ms

addFixEventPupilSize = 0;
addFullTimeCourse = 1;

if addFullTimeCourse
    requireStartingFixation = 0;
else
    requireStartingFixation = 1;
end

if nargin < 3; %default values, if pos isn't specified

    minX = -10e3;
    maxX = 10e3;
    minY = -10e3;
    maxY = 10e3;
    
else
    
    minX = pos.minX;
    maxX = pos.maxX;
    minY = pos.minY;
    maxY = pos.maxY;
    
end

nFixationsPerImagePerFile = cell(1,length(wantedTimes));
fixEventDursPerImagePerFile = cell(1,length(wantedTimes));
durPerImagePerFile = cell(1,length(wantedTimes));
meanDurFixEventPerImagePerFile = cell(1,length(wantedTimes));
semDurFixEventPerImagePerFile = cell(1,length(wantedTimes));
pupilPerImagePerFile = cell(1,length(wantedTimes));
pupilSizePerImagePerFile = cell(1,length(wantedTimes));
pupilSizePerFixEventPerFile = cell(1,length(wantedTimes));
storePupilTimeCourse = [];

for i = 1:length(wantedTimes);
    
    onePupil = pupil{i}.pupil;
    oneTimes = wantedTimes{i}; %get one file's timing info
    oneFixEvents = allEvents{i}; %get one file's fixation events
    
    fixStarts = oneFixEvents(:,1); %separate columns of fixation events for clarity; start of all fixations
    fixEnds = oneFixEvents(:,2); %end of all fixations
    dur = oneFixEvents(:,3); %durations
    x = oneFixEvents(:,4);
    y = oneFixEvents(:,5);
    pupSize = oneFixEvents(:,6);
    
    rowN = 1:length(fixStarts); %for indexing
    step = 1; %for saving per image
    newStp = 1; %for saving pupil data
    
    pupilSizePerFixEvent = cell(1,length(oneTimes));
    nFixationsPerImage = cell(1,length(oneTimes));
    fixEventDursPerImage = cell(1,length(oneTimes));
    durPerImage = cell(1,length(oneTimes));    
    meanDurFixEventPerImage = cell(1,length(oneTimes));    
    semDurFixEventPerImage = cell(1,length(oneTimes));
    pupilPerImage = cell(1,length(oneTimes));
    pupilSizePerImage = cell(1,length(oneTimes));
    firstFixEventPup = nan(1000,pupilDurThreshold+preImageTime);%additional one for session number
    
    for j = 1:size(oneTimes,1); %for each image display time ...
        
        if oneTimes(j,2) < max(fixEnds); % if valid display time
            
            startEndTimes = [oneTimes(j,1) oneTimes(j,2)];
            timeIndex = zeros(1,2); firstLastDur = zeros(1,2);        

            for k = 1:2;

                toFindTime = startEndTimes(k);        
                testIndex = toFindTime >= fixStarts & toFindTime <= fixEnds;                      

                if sum(testIndex) == 1;
                    timeIndex(k) = rowN(testIndex);                
                    if k == 1;                    
                        firstLastDur(k) = fixEnds(timeIndex(k)) - toFindTime;          
                    else
                        firstLastDur(k) = toFindTime - fixStarts(timeIndex(k));
                    end
                else
                    lastGreater = find(toFindTime <= fixStarts,1,'first');
                    if k == 1;                    
                        timeIndex(k) = lastGreater;
                        firstLastDur(k) = dur(timeIndex(k));            
                    else                    
                        timeIndex(k) = lastGreater-1;
                        firstLastDur(k) = dur(timeIndex(k));
                    end
                end

            end

            startIndex = timeIndex(1);
            endIndex = timeIndex(2);

            if startIndex ~= endIndex         
                allDurs = dur(startIndex:endIndex);
                allDurs(1) = firstLastDur(1); allDurs(end) = firstLastDur(2); %replace first and last durations with adjusted durations;        
            else
                allDurs = firstLastDur(1);
            end
            
            fixEvents = [fixStarts(startIndex:endIndex) fixEnds(startIndex:endIndex)];

            allPup = pupSize(startIndex:endIndex);      
            allX = x(startIndex:endIndex);
            allY = y(startIndex:endIndex); 
            
            if startIndex > endIndex
                warning('Start indices are greater than end indices. Data will be missing and skipped');
            end
            
%             if isempty(allX) || isempty(allY)
% %                 disp(startIndex); disp(endIndex);
%                 disp(allPup);
%                 disp(oneTimes(j,:));
%                 error('missing');
%             end

            checkXBounds = allX >= minX & allX <= maxX;
            checkYBounds = allY >= minY & allY <= maxY;
            checkBounds = checkXBounds & checkYBounds;

            allDurs(~checkBounds) = [];
            allPup(~checkBounds) = [];
%             fixEvents(~checkBounds,:) = [];
               
            if ~isempty(allDurs); %%% if there're fixations within the defined positional bounds ...
                if ~isempty(checkBounds);
                    if addPupilData && requireStartingFixation
                        if checkBounds(1)
                            firstEvent = fixEvents(1,:);
                            startDiff = startEndTimes(1) - firstEvent(1);
                            if sign(startDiff) == 1;
                                pupilStart = startEndTimes(1);
                                pupilEnd = firstEvent(2);
                                if (pupilEnd - pupilStart) > pupilDurThreshold
    %                                 firstFixEventPup(newStp,1:pupilDurThreshold+preImageTime) = ...
    %                                     getPupilSize(onePupil,...
    %                                     [pupilStart pupilStart+pupilDurThreshold-1],-preImageTime);%get fixation baseline
                                    firstFixEventPup(newStp,:) = ...
                                        getPupilSize(onePupil,...
                                        [pupilStart pupilStart+pupilDurThreshold-1],-preImageTime);%get fixation baseline
    %                                 firstFixEventPup(newStp,end+1) = i;
                                    newStp = newStp + 1;

                                end
                            end
                        end
                    end
                end
                
                nFixationsPerImage{j} = [length(allPup) i];
                meanDurFixEventPerImage{j} = mean(allDurs);
                semDurFixEventPerImage{j} = [SEM(allDurs) (std(allDurs))^.2 length(allDurs) i];
                fixEventDursPerImage{j} = [allDurs repmat(i,length(allDurs),1)];
                durPerImage{j} = [sum(allDurs) i];
                pupilPerImage{step} = [mean(allPup) SEM(allPup) (std(allPup))^.2 length(allPup) i];
                step = step+1;
                
                if addFixEventPupilSize && addPupilData % if getting pupil data per fixation event, with some time-lag
                    fixEventPups = cell(length(fixEvents),1);
                    for ll = 1:length(fixEvents);
                        fixEventPups{ll} = getPupilSize(onePupil,fixEvents(ll,:),150); %adjust start time of fixation event to be 150ms to allow 
                    end

                    fixEventPups = concatenateData(fixEventPups);
                    fixEventPups(:,2) = i;
                    pupilSizePerFixEvent{step} = fixEventPups;

                    else 
                        pupilSizePerFixEvent{step} = [allPup repmat(i,length(allPup),1)];
                end
                
                if add_image_times %%%% Add start time of image presentation for creating a time-course
                    nFixationsPerImage{j} = [nFixationsPerImage{j} startEndTimes(1)];
                    meanDurFixEventPerImage{j} = [meanDurFixEventPerImage{j} startEndTimes(1)];
                    fixEventDursPerImage{j} = [fixEventDursPerImage{j} repmat(startEndTimes(1),size(allDurs,1),1)];
                    semDurFixEventPerImage{j} = [0 0 length(allDurs) i];
                    durPerImage{j} = [durPerImage{j} startEndTimes(1)];
                end

            else
                
                nFixationsPerImage{j} = [0 i];
                fixEventDursPerImage{j} = [0 i];
                durPerImage{j} = [0 i];
%                 pupilPerImage{step} = [mean(allPup) SEM(allPup) (std(allPup))^.2 length(allPup) i];
                nFixationsPerImage{j} = [NaN NaN];
                
                if add_image_times
                    nFixationsPerImage{j} = [nFixationsPerImage{j} NaN];
                    meanDurFixEventPerImage{j} = [0 NaN];
                    semDurFixEventPerImage{j} = [0 0 0 i];
                    fixEventDursPerImage{j} = [fixEventDursPerImage{j} NaN];
                    durPerImage{j} = [durPerImage{j} NaN];
                end
                
            end
            
            if ~isempty(checkBounds) && addPupilData && addFullTimeCourse %if adding full time-course of pupil changes (slows down code a lot)
                pupilData = getPupilSize(onePupil,...
                    [startEndTimes(1) startEndTimes(1) + fullTime],-preImageTime);
                pupilSizePerImage{j} = [pupilData' i];
%                 disp(size(pupilSizePerImage{j}));
            else                
                pupilSizePerImage{j} = nan(1,fullTime+preImageTime+2);
%                 disp(size(pupilSizePerImage{j}));
            end
        
        end %end if
        
        
    end
    
    if i == 1;
        storePupilTimeCourse = firstFixEventPup;
    else
        checkSize = size(storePupilTimeCourse);
        checkSize2 = size(firstFixEventPup);
        if checkSize ~= checkSize2
            error('sizes don''t match');
        end
        storePupilTimeCourse = [storePupilTimeCourse;firstFixEventPup];
    end
    
    [nFixationsPerImage,fixEventDursPerImage,durPerImage] = ...
        concatenateData(nFixationsPerImage,fixEventDursPerImage,durPerImage);
    
    
    [meanDurFixEventPerImage,semDurFixEventPerImage] = concatenateData(...
        meanDurFixEventPerImage,semDurFixEventPerImage);
    
    pupilPerImage = concatenateData(pupilPerImage);
    
    meanDurFixEventPerImagePerFile{i} = meanDurFixEventPerImage;
    semDurFixEventPerImagePerFile{i} = semDurFixEventPerImage;
    
    nFixationsPerImagePerFile{i} = nFixationsPerImage;
    fixEventDursPerImagePerFile{i} = fixEventDursPerImage;
    durPerImagePerFile{i} = durPerImage;
    
    pupilPerImagePerFile{i} = pupilPerImage;
    
    pupilSizePerImagePerFile{i} = concatenateData(pupilSizePerImage);
    pupilSizePerFixEventPerFile{i} = concatenateData(pupilSizePerFixEvent);
    
%     [dursPerImage,sizePerImage,nFixPerImage,firstLookPerImage,patchResidencePerImage] = ...
%         concatenateData(dursPerImage,sizePerImage,nFixPerImage,firstLookPerImage,patchResidencePerImage);
%     
%     meanDurPerImage = concatenateData(meanDurPerImage);
%     forProportion = concatenateData(forProportion);
%     
%     forPropPerFile{i} = forProportion;
%     meanDurPerFile{i} = meanDurPerImage;
%     patchResidencePerFile{i} = patchResidencePerImage;
%     dursPerFile{i} = mean(dursPerImage); %this is new; before, was simply = dursPerImage
%     sizePerFile{i} = sizePerImage;
%     nFixPerFile{i} = mean(nFixPerImage); %this is new; before, was simply = nFixPerImage
%     firstLookPerFile{i} = firstLookPerImage;    
    
end

%%% new outputs

pupilSizePerImagePerFile = concatenateData(pupilSizePerImagePerFile);

[nFixationsPerImagePerFile,fixEventDursPerImagePerFile,durPerImagePerFile] = ...
    concatenateData(nFixationsPerImagePerFile,fixEventDursPerImagePerFile,durPerImagePerFile);

[meanDurFixEventPerImagePerFile,semDurFixEventPerImagePerFile] = ...
    concatenateData(meanDurFixEventPerImagePerFile,semDurFixEventPerImagePerFile);

pupilPerImagePerFile = concatenateData(pupilPerImagePerFile);
pupilSizePerFixEventPerFile = concatenateData(pupilSizePerFixEventPerFile);

% data.pupilSize = pupilPerImagePerFile;
data.nImages = length(durPerImagePerFile);
data.forProportion = nFixationsPerImagePerFile;
if ~isempty(nFixationsPerImagePerFile);
    data.nFixationsPerImage = nFixationsPerImagePerFile(~isnan(nFixationsPerImagePerFile(:,1)),:);
else
    data.nFixationsPerImage = [];
end
data.meanLookingDuration = [mean(durPerImagePerFile) SEM(durPerImagePerFile) (std(durPerImagePerFile)).^2 ...
    length(durPerImagePerFile)];
data.meanDurationFixEvent = [mean(fixEventDursPerImagePerFile) SEM(fixEventDursPerImagePerFile) (std(fixEventDursPerImagePerFile)).^2 ...
    length(fixEventDursPerImagePerFile)];
data.meanDurationFixEventPerImage = [meanDurFixEventPerImagePerFile semDurFixEventPerImagePerFile];

data.lookingDuration = durPerImagePerFile;
data.fixEventDuration = fixEventDursPerImagePerFile;

% for n = 1:length(unique(durPerImagePerFile(:,2)));
%     nImagesPerSession(n,:) = [length(durPerImagePerFile(durPerImagePerFile(:,2) == n,:)) n];
% end
nImagesPerSession = NaN;

data.nImagesPerSession = nImagesPerSession;
data.pupilSize = pupilSizePerImagePerFile;
data.pupilSizePerFixEvent = pupilSizePerFixEventPerFile;

storePupilTimeCourse = [storePupilTimeCourse ones(size(storePupilTimeCourse,1),1)];
storePupilTimeCourse(isnan(storePupilTimeCourse(:,1)),:) = [];
% data.pupilTimeCourse = [storePupilTimeCourse ones(size(storePupilTimeCourse,1),1)];
data.pupilTimeCourse = storePupilTimeCourse;

end %end monkey number loop
