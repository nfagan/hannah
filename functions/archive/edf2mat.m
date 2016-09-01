%% Example 1 for how to use the Edf Converter
cd('/Users/hannahweinberg-wolf/Documents/5HTP_FV_Analysis_Code');
%% Converting the EDF File and saving it as a Matlab File
clear all;

% saveDirectory = '/Users/hannahweinberg-wolf/Documents/5HTP_FV_Analysis_Code/codes_for_hannah/new_test_data';

saveDirectory = '/Volumes/My Passport/NICK/Chang Lab 2016/hannah/check_for_dups';

% edit name
f_name = 'ep052402.edf';
edf0 = Edf2Mat(f_name);

% edit name
Efix = horzcat(edf0.Events.Efix.start',edf0.Events.Efix.end',edf0.Events.Efix.duration',edf0.Events.Efix.posX',edf0.Events.Efix.posY',edf0.Events.Efix.pupilSize');
e_name = 'Efix ep052402.xls';
cd(saveDirectory);
xlswrite(e_name, Efix);

% edit name
time = num2cell(edf0.Events.Messages.time);
Info = horzcat(edf0.Events.Messages.info',time');
% t_name = 'Info NeC0306.xls';
% t_name = 'Info test.xls';
% xlswrite(t_name, Info);

actual_time = [];

%%

% add categories here for each image type flag
for i=1:length(edf0.Events.Messages.info)
    if edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'B' && ...
            edf0.Events.Messages.info{i}(3) == 'D' && edf0.Events.Messages.info{i}(4) == 'T' %UBDT 
        actual_time = [actual_time; 1, time(i)];
    elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'B' && ...
            edf0.Events.Messages.info{i}(3) == 'D' && edf0.Events.Messages.info{i}(4) == 'S' %UBDS 
        actual_time = [actual_time; 2, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'B' && ...
            edf0.Events.Messages.info{i}(3) == 'D' && edf0.Events.Messages.info{i}(4) == 'N' %UBDN 
        actual_time = [actual_time; 3, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'B' && ...
            edf0.Events.Messages.info{i}(3) == 'D' && edf0.Events.Messages.info{i}(4) == 'L' %UBDL 
        actual_time = [actual_time; 4, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'B' && ...
            edf0.Events.Messages.info{i}(3) == 'I' && edf0.Events.Messages.info{i}(4) == 'T' %UBIT 
        actual_time = [actual_time; 5, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'B' && ...
            edf0.Events.Messages.info{i}(3) == 'I' && edf0.Events.Messages.info{i}(4) == 'S' %UBIS 
        actual_time = [actual_time; 6, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'B' && ...
            edf0.Events.Messages.info{i}(3) == 'I' && edf0.Events.Messages.info{i}(4) == 'N' %UBIN 
        actual_time = [actual_time; 7, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'B' && ...
            edf0.Events.Messages.info{i}(3) == 'I' && edf0.Events.Messages.info{i}(4) == 'L' %UBIL 
        actual_time = [actual_time; 8, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'G' && ...
            edf0.Events.Messages.info{i}(3) == 'D' && edf0.Events.Messages.info{i}(4) == 'T' %UGDT 
        actual_time = [actual_time; 9, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'G' && ...
            edf0.Events.Messages.info{i}(3) == 'D' && edf0.Events.Messages.info{i}(4) == 'N' %UGDN 
        actual_time = [actual_time; 10, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'G' && ...
            edf0.Events.Messages.info{i}(3) == 'D' && edf0.Events.Messages.info{i}(4) == 'S' %UGDS 
        actual_time = [actual_time; 11, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'G' && ...
            edf0.Events.Messages.info{i}(3) == 'D' && edf0.Events.Messages.info{i}(4) == 'L' %UGDL 
        actual_time = [actual_time; 12, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'G' && ...
            edf0.Events.Messages.info{i}(3) == 'I' && edf0.Events.Messages.info{i}(4) == 'T' %UGIT 
        actual_time = [actual_time; 13, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'G' && ...
            edf0.Events.Messages.info{i}(3) == 'I' && edf0.Events.Messages.info{i}(4) == 'S' %UGIS 
        actual_time = [actual_time; 14, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'G' && ...
            edf0.Events.Messages.info{i}(3) == 'I' && edf0.Events.Messages.info{i}(4) == 'N' %UGIN 
        actual_time = [actual_time; 15, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'U' && edf0.Events.Messages.info{i}(2) == 'G' && ...
            edf0.Events.Messages.info{i}(3) == 'I' && edf0.Events.Messages.info{i}(4) == 'L' %UGIL 
        actual_time = [actual_time; 16, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'S' && edf0.Events.Messages.info{i}(2) == 'c' && ...
            edf0.Events.Messages.info{i}(3) == 'r' && edf0.Events.Messages.info{i}(4) == 'a' %scrambled 
        actual_time = [actual_time; 17, time(i)];
        elseif edf0.Events.Messages.info{i}(1) == 'O' && edf0.Events.Messages.info{i}(2) == 'u' && ...
            edf0.Events.Messages.info{i}(3) == 't' && edf0.Events.Messages.info{i}(4) == 'd' %outdoors 
        actual_time = [actual_time; 18, time(i)];
    end
end

% edit name
cd(saveDirectory);
at_name = 'Time ep052402.xls';
xlswrite(at_name, actual_time);

%% The edf Variable now holds all information
% lets display it:

%disp(edf0);

% %% And how about just plot it?
% plot(edf0);
% 
% %% Of course you can also plot in your own style:
% figure();
% plot(edf0.Samples.posX(end - 2000:end), edf0.Samples.posY(end - 2000:end), 'o');

