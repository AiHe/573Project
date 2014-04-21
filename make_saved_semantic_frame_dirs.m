function S = make_saved_semantic_frame_dirs()
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

files = dir('annotations');
files = files(3:end);

if strcmp(files(1).name,'.DS_Store')
    files = files(2:end);
end
if strcmp(files(1).name,'ColumnInfo.txt')
    files = files(2:end);
end


for i = 1:length(files)
    
    name = ['annotations/',files(i).name,'/saved_semantic_frames'];
    mkdir(name);
    
end








S = 0;
end

