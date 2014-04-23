function S = make_saved_low_frame_dirs()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


files = dir('Feature_map/');
files = files(3:end);

if strcmp(files(1).name,'.DS_Store')
    files = files(2:end);
end



for i = 1:length(files)
    
    name = ['saved_low_frames/',files(i).name];
    mkdir(name);
    
end






S = 0;
end

