%%%%%Plotting Things - Looking Time Per Image

lookimage = [slookimage;llookimage;hlookimage]';
lookimagesem = [slookimagesem,llookimagesem,hlookimagesem]';

figure
hold on

bar(.3:1:17.3,slookimage,.15,'b')
bar(.6:1:17.6,llookimage,.15,'g')
bar(.9:1:17.9,hlookimage,.15,'r')
errorbar(.3:1:17.3,slookimage,slookimagesem,'b.')
errorbar(.6:1:17.6,llookimage,llookimagesem,'g.')
errorbar(.9:1:17.9,hlookimage,hlookimagesem,'r.')

trialindex = {'UBDT', 'UBDS', 'UBDN', 'UBDL', 'UBIT', 'UBIS', 'UBIN', 'UBIL', 'UGDT', 'UGDS', 'UGDN', 'UGDL', 'UGIT', 'UGIS', 'UGIN', 'UGIL', 'Scr', 'Out'}; 

axis([0,18.3,0,2000])
set(gca,'XTick',[.6:1:17.6])
set(gca,'XTickLabel',trialindex)

ylabel('Total Looking Time Per Image in ms')
xlabel('Image Category')

title('Total Looking Time Per Image')

legend('Saline','Low','High')

%% Female Only
%%%%%Plotting Things - Looking Time Per Image

Fslookimage = slookimage(9:16);
Fllookimage = llookimage(9:16);
Fhlookimage = hlookimage(9:16);

Fslookimagesem = slookimagesem(9:16);
Fllookimagesem = llookimagesem(9:16);
Fhlookimagesem = hlookimagesem(9:16);

figure
hold on

bar(.3:1:7.3,Fslookimage,.15,'b')
bar(.6:1:7.6,Fllookimage,.15,'g')
bar(.9:1:7.9,Fhlookimage,.15,'r')
errorbar(.3:1:7.3,Fslookimage,Fslookimagesem,'b.')
errorbar(.6:1:7.6,Fllookimage,Fllookimagesem,'g.')
errorbar(.9:1:7.9,Fhlookimage,Fhlookimagesem,'r.')

Ftrialindex = {'UGDT', 'UGDS', 'UGDN', 'UGDL', 'UGIT', 'UGIS', 'UGIN', 'UGIL'}; 

axis([0,8.3,0,2000])
set(gca,'XTick',[.6:1:7.6])
set(gca,'XTickLabel',Ftrialindex)

ylabel('Total Looking Time Per Image in ms')
xlabel('Image Category')

title('Total Looking Time Per Images of Females')

legend('Saline','Low','High')

%% Male Only
%%%%%Plotting Things - Looking Time Per Image

Mslookimage = slookimage(1:8);
Mllookimage = llookimage(1:8);
Mhlookimage = hlookimage(1:8);

Mslookimagesem = slookimagesem(1:8);
Mllookimagesem = llookimagesem(1:8);
Mhlookimagesem = hlookimagesem(1:8);

figure
hold on

bar(.3:1:7.3,Mslookimage,.15,'b')
bar(.6:1:7.6,Mllookimage,.15,'g')
bar(.9:1:7.9,Mhlookimage,.15,'r')
errorbar(.3:1:7.3,Mslookimage,Mslookimagesem,'b.')
errorbar(.6:1:7.6,Mllookimage,Mllookimagesem,'g.')
errorbar(.9:1:7.9,Mhlookimage,Mhlookimagesem,'r.')

Mtrialindex = {'UBDT', 'UBDS', 'UBDN', 'UBDL', 'UBIT', 'UBIS', 'UBIN', 'UBIL'}; 

axis([0,8.3,0,2000])
set(gca,'XTick',[.6:1:7.6])
set(gca,'XTickLabel',Mtrialindex)

ylabel('Total Looking Time Per Image in ms')
xlabel('Image Category')

title('Total Looking Time Per Images of Males')

legend('Saline','Low','High')


%% Gender
%%%%%Plotting Things - Looking Time Per Image

male_saline_lookimage = sum(slookimage(1:8))/8;
male_low_lookimage = sum(llookimage(1:8))/8;
male_high_lookimage = sum(hlookimage(1:8))/8;

female_saline_lookimage = sum(slookimage(9:16))/8;
female_low_lookimage = sum(llookimage(9:16))/8;
female_high_lookimage = sum(hlookimage(9:16))/8;

male_saline_lookimagesem = sum(slookimagesem(1:8))/8;
male_low_lookimagesem = sum(llookimagesem(1:8))/8;
male_high_lookimagesem = sum(hlookimagesem(1:8))/8;

female_saline_lookimagesem = sum(slookimagesem(9:16))/8;
female_low_lookimagesem = sum(llookimagesem(9:16))/8;
female_high_lookimagesem = sum(hlookimagesem(9:16))/8;

MFslookimage = [male_saline_lookimage,female_saline_lookimage];
MFllookimage = [male_low_lookimage,female_low_lookimage];
MFhlookimage = [male_high_lookimage,female_high_lookimage];

MFslookimagesem = [male_saline_lookimagesem,female_saline_lookimagesem];
MFllookimagesem = [male_low_lookimagesem,female_low_lookimagesem];
MFhlookimagesem = [male_high_lookimagesem,female_high_lookimagesem];

figure
hold on

bar(.3:1:1.3,MFslookimage,.15,'b')
bar(.6:1:1.6,MFllookimage,.15,'g')
bar(.9:1:1.9,MFhlookimage,.15,'r')
errorbar(.3:1:1.3,MFslookimage,MFslookimagesem,'b.')
errorbar(.6:1:1.6,MFllookimage,MFllookimagesem,'g.')
errorbar(.9:1:1.9,MFhlookimage,MFhlookimagesem,'r.')

MFtrialindex = {'Male','Female'}; 

axis([0,2.3,0,2000])
set(gca,'XTick',[.6:1:1.6])
set(gca,'XTickLabel',MFtrialindex)

ylabel('Total Looking Time Per Image in ms')
xlabel('Image Category')

title('Total Looking Time Per Images of Males vs Females')

legend('Saline','Low','High')

%% Expression
%%%%%Plotting Things - Looking Time Per Image

threat_saline_lookimage = sum([slookimage(1),slookimage(5),slookimage(9),slookimage(13)])/4;
threat_low_lookimage = sum([llookimage(1),llookimage(5),llookimage(9),llookimage(13)])/4;
threat_high_lookimage = sum([hlookimage(1),hlookimage(5),hlookimage(9),hlookimage(13)])/4;

sub_saline_lookimage = sum([slookimage(2),slookimage(6),slookimage(10),slookimage(14)])/4;
sub_low_lookimage = sum([llookimage(2),llookimage(6),llookimage(10),llookimage(14)])/4;
sub_high_lookimage = sum([hlookimage(2),hlookimage(6),hlookimage(10),hlookimage(14)])/4;

neutral_saline_lookimage = sum([slookimage(3),slookimage(7),slookimage(11),slookimage(15)])/4;
neutral_low_lookimage = sum([llookimage(3),llookimage(7),llookimage(11),llookimage(15)])/4;
neutral_high_lookimage = sum([hlookimage(3),hlookimage(7),hlookimage(11),hlookimage(15)])/4;

ls_saline_lookimage = sum([slookimage(4),slookimage(8),slookimage(12),slookimage(16)])/4;
ls_low_lookimage = sum([llookimage(4),llookimage(8),llookimage(12),llookimage(16)])/4;
ls_high_lookimage = sum([hlookimage(4),hlookimage(8),hlookimage(12),hlookimage(16)])/4;

threat_saline_lookimagesem = sum([slookimagesem(1),slookimagesem(5),slookimagesem(9),slookimagesem(13)])/4;
threat_low_lookimagesem = sum([llookimagesem(1),llookimagesem(5),llookimagesem(9),llookimagesem(13)])/4;
threat_high_lookimagesem = sum([hlookimagesem(1),hlookimagesem(5),hlookimagesem(9),hlookimagesem(13)])/4;

sub_saline_lookimagesem = sum([slookimagesem(2),slookimagesem(6),slookimagesem(10),slookimagesem(14)])/4;
sub_low_lookimagesem = sum([llookimagesem(2),llookimagesem(6),llookimagesem(10),llookimagesem(14)])/4;
sub_high_lookimagesem = sum([hlookimagesem(2),hlookimagesem(6),hlookimagesem(10),hlookimagesem(14)])/4;

neutral_saline_lookimagesem = sum([slookimagesem(3),slookimagesem(7),slookimagesem(11),slookimagesem(15)])/4;
neutral_low_lookimagesem = sum([llookimagesem(3),llookimagesem(7),llookimagesem(11),llookimagesem(15)])/4;
neutral_high_lookimagesem = sum([hlookimagesem(3),hlookimagesem(7),hlookimagesem(11),hlookimagesem(15)])/4;

ls_saline_lookimagesem = sum([slookimagesem(4),slookimagesem(8),slookimagesem(12),slookimagesem(16)])/4;
ls_low_lookimagesem = sum([llookimagesem(4),llookimagesem(8),llookimagesem(12),llookimagesem(16)])/4;
ls_high_lookimagesem = sum([hlookimagesem(4),hlookimagesem(8),hlookimagesem(12),hlookimagesem(16)])/4;

Eslookimage = [threat_saline_lookimage,sub_saline_lookimage,neutral_saline_lookimage,ls_saline_lookimage];
Ellookimage = [threat_low_lookimage,sub_low_lookimage,neutral_low_lookimage,ls_low_lookimage];
Ehlookimage = [threat_high_lookimage,sub_high_lookimage,neutral_high_lookimage,ls_high_lookimage];

Eslookimagesem = [threat_saline_lookimagesem,sub_saline_lookimagesem,neutral_saline_lookimagesem,ls_saline_lookimagesem];
Ellookimagesem = [threat_low_lookimagesem,sub_low_lookimagesem,neutral_low_lookimagesem,ls_low_lookimagesem];
Ehlookimagesem = [threat_high_lookimagesem,sub_high_lookimagesem,neutral_high_lookimagesem,ls_high_lookimagesem];

figure
hold on

bar(.3:1:3.3,Eslookimage,.15,'b')
bar(.6:1:3.6,Ellookimage,.15,'g')
bar(.9:1:3.9,Ehlookimage,.15,'r')
errorbar(.3:1:3.3,Eslookimage,Eslookimagesem,'b.')
errorbar(.6:1:3.6,Ellookimage,Ellookimagesem,'g.')
errorbar(.9:1:3.9,Ehlookimage,Ehlookimagesem,'r.')

Etrialindex = {'Threat','Fear Grimace','Neutral','Lip Smack'}; 

axis([0,4.3,0,2000])
set(gca,'XTick',[.6:1:3.6])
set(gca,'XTickLabel',Etrialindex)

ylabel('Total Looking Time Per Image in ms')
xlabel('Image Category')

title('Total Looking Time Per Images by Expression')

legend('Saline','Low','High')

%% Gaze Direction
%%%%%Plotting Things - Looking Time Per Image

directed_saline_lookimage = sum([slookimage(1:4),slookimage(9:12)])/8;
directed_low_lookimage = sum([llookimage(1:4),llookimage(9:12)])/8;
directed_high_lookimage = sum([hlookimage(1:4),hlookimage(9:12)])/8;

averted_saline_lookimage = sum([slookimage(5:8),slookimage(13:16)])/8;
averted_low_lookimage = sum([llookimage(5:8),llookimage(13:16)])/8;
averted_high_lookimage = sum([hlookimage(5:8),hlookimage(13:16)])/8;

directed_saline_lookimagesem = sum([slookimagesem(1:4),slookimagesem(9:12)])/8;
directed_low_lookimagesem = sum([llookimagesem(1:4),llookimagesem(9:12)])/8;
directed_high_lookimagesem = sum([hlookimagesem(1:4),hlookimagesem(9:12)])/8;

averted_saline_lookimagesem = sum([slookimagesem(5:8),slookimagesem(13:16)])/8;
averted_low_lookimagesem = sum([llookimagesem(5:8),llookimagesem(13:16)])/8;
averted_high_lookimagesem = sum([hlookimagesem(5:8),hlookimagesem(13:16)])/8;

DAslookimage = [directed_saline_lookimage,averted_saline_lookimage];
DAllookimage = [directed_low_lookimage,averted_low_lookimage];
DAhlookimage = [directed_high_lookimage,averted_high_lookimage];

DAslookimagesem = [directed_saline_lookimagesem,averted_saline_lookimagesem];
DAllookimagesem = [directed_low_lookimagesem,averted_low_lookimagesem];
DAhlookimagesem = [directed_high_lookimagesem,averted_high_lookimagesem];

figure
hold on

bar(.3:1:1.3,DAslookimage,.15,'b')
bar(.6:1:1.6,DAllookimage,.15,'g')
bar(.9:1:1.9,DAhlookimage,.15,'r')
errorbar(.3:1:1.3,DAslookimage,DAslookimagesem,'b.')
errorbar(.6:1:1.6,DAllookimage,DAllookimagesem,'g.')
errorbar(.9:1:1.9,DAhlookimage,DAhlookimagesem,'r.')

DAtrialindex = {'Directed','Averted'}; 

axis([0,2.3,0,2000])
set(gca,'XTick',[.6:1:1.6])
set(gca,'XTickLabel',DAtrialindex)

ylabel('Total Looking Time Per Image in ms')
xlabel('Image Category')

title('Total Looking Time Per Images by Gaze Direction')

legend('Saline','Low','High')

%% Expression with Gaze
%%%%%Plotting Things - Looking Time Per Image

direct_threat_saline_lookimage = sum([slookimage(1),slookimage(9)])/2;
direct_threat_low_lookimage = sum([llookimage(1),llookimage(9)])/2;
direct_threat_high_lookimage = sum([hlookimage(1),hlookimage(9)])/2;

direct_sub_saline_lookimage = sum([slookimage(2),slookimage(10)])/2;
direct_sub_low_lookimage = sum([llookimage(2),llookimage(10)])/2;
direct_sub_high_lookimage = sum([hlookimage(2),hlookimage(10)])/2;

direct_neutral_saline_lookimage = sum([slookimage(3),slookimage(11)])/2;
direct_neutral_low_lookimage = sum([llookimage(3),llookimage(11)])/2;
direct_neutral_high_lookimage = sum([hlookimage(3),hlookimage(11)])/2;

direct_ls_saline_lookimage = sum([slookimage(4),slookimage(12),])/2;
direct_ls_low_lookimage = sum([llookimage(4),llookimage(12)])/2;
direct_ls_high_lookimage = sum([hlookimage(4),hlookimage(12)])/2;

averted_threat_saline_lookimage = sum([slookimage(5),slookimage(13)])/2;
averted_threat_low_lookimage = sum([llookimage(5),llookimage(13)])/2;
averted_threat_high_lookimage = sum([hlookimage(5),hlookimage(13)])/2;

averted_sub_saline_lookimage = sum([slookimage(6),slookimage(14)])/2;
averted_sub_low_lookimage = sum([llookimage(6),llookimage(14)])/2;
averted_sub_high_lookimage = sum([hlookimage(6),hlookimage(14)])/2;

averted_neutral_saline_lookimage = sum([slookimage(7),slookimage(15)])/2;
averted_neutral_low_lookimage = sum([llookimage(7),llookimage(15)])/2;
averted_neutral_high_lookimage = sum([hlookimage(7),hlookimage(15)])/2;

averted_ls_saline_lookimage = sum([slookimage(8),slookimage(16)])/2;
averted_ls_low_lookimage = sum([llookimage(8),llookimage(16)])/2;
averted_ls_high_lookimage = sum([hlookimage(8),hlookimage(16)])/2;

Eslookimage = [direct_threat_saline_lookimage, averted_threat_saline_lookimage, direct_sub_saline_lookimage, averted_sub_saline_lookimage,direct_neutral_saline_lookimage, averted_neutral_saline_lookimage, direct_ls_saline_lookimage, averted_ls_saline_lookimage];
Ellookimage = [direct_threat_low_lookimage, averted_threat_low_lookimage, direct_sub_low_lookimage, averted_sub_low_lookimage,direct_neutral_low_lookimage, averted_neutral_low_lookimage, direct_ls_low_lookimage, averted_ls_low_lookimage];
Ehlookimage = [direct_threat_high_lookimage, averted_threat_high_lookimage, direct_sub_high_lookimage, averted_sub_high_lookimage,direct_neutral_high_lookimage, averted_neutral_high_lookimage, direct_ls_high_lookimage, averted_ls_high_lookimage];

figure
hold on

bar(.3:1:7.3,Eslookimage,.15,'b')
bar(.6:1:7.6,Ellookimage,.15,'g')
bar(.9:1:7.9,Ehlookimage,.15,'r')

Etrialindex = {'Direct Threat', 'Averted Threat', 'Direct Fear Grimace', 'Averted Fear Grimace','Direct Neutral', 'Averted Neutral','Direct Lip Smack', 'Direct Lip Smack'}; 

axis([0,8.3,0,2000])
set(gca,'XTick',[.6:1:7.6])
set(gca,'XTickLabel',Etrialindex)

ylabel('Total Looking Time Per Image in ms')
xlabel('Image Category')

title('Total Looking Time Per Images by Expression')

legend('Saline','Low','High')


