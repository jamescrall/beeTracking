%% Load metadata on tags
taglistDir = uigetdir(pwd, 'Choose directory for taglists');
cd(taglistDir);
list = dir('*Taglist.csv');
tags = struct();

%Loop across colonies
for i = 1:numel(list)
    %%
    name = list(i).name;
    colonyName = strsplit(name, 'Taglist.csv');
    colonyName = colonyName{1};
    colonyNum = str2num(colonyName(end));
    tagdata = csvread(name,1,0);
    tags(i).colonyName = colonyName;
    tags(i).colonyNum = colonyNum;
    tags(i).taglist = tagdata(:,1);
    tags(i).queen = tagdata(:,2);
    tags(i).callow = tagdata(:,3);

end


%% Get list of videos to track
parDir = uigetdir(pwd, 'Choose parent directory for videos');
cd(parDir)
nestVidList = dir(strcat(pwd, '/**/*NC.avi'))
close all

%%
for i = 1:nestVidList
   %%
   nestVid = VideoReader([nestVidList(i).folder '/' nestVidList(i).name]);
   backIm = 
end