function [phi_emp_sum, phi_theo_sum, derivation, sum_Hessian, num_points] = get_normalized_scanpath_saliency(...
    subject_type,subject_num,object_theta,attribute_theta,low_theta)
%UNTITLED34 Summary of this function goes here
%   Detailed explanation goes here

%set height and width to fixed frame parameters
height = 1024;
width = 1280;
D = 114;

%make sure low and attribute theta are the right shape, Assert not really
%necessary anymore
attribute_theta = reshape(attribute_theta,[1 1 9]);
assert(isequal(size(attribute_theta),[1 1 9]));
low_theta = reshape(low_theta,[1 1 5]);
assert(isequal(size(low_theta),[1 1 5]));
%assert(isequal(size(low_theta),[1 1 5]));

%open data folder
folders = dir('DATA');
folders = folders(4:end);

%open specified subject type folder
type_folder = folders(subject_type).name;

%open the set of all subject/clip folders
second_folders = dir(['Data/',type_folder]);
second_folders = second_folders(3:end);
if strcmp(second_folders(1).name,'.DS_Store')
    second_folders = second_folders(2:end);
end

%load subject/clip data
load(['DATA/',type_folder,'/',second_folders(subject_num).name,'/sampled_5.mat']);
gaze = sampled; clear sampled;
[~, gaze, frame_nums, max_gaze_num] = get_starts_targets(gaze);
num_points = size(gaze,1);

%load the appropriate clip folders
start_index = findstr('mtv3clip',second_folders(subject_num).name);
end_index = start_index + 9;
clip_string = second_folders(subject_num).name(start_index:end_index);
clip_folders = dir(['annotations/',clip_string,'*']);

%figure out how the frames are divided among the folders
frame_endpoints = zeros(1,length(clip_folders));
for i = 1:length(clip_folders)
    frame_endpoints(i) = str2num(clip_folders(i).name(12:17));
end
max_frame = str2num(clip_folders(end).name(19:24));

%convert from index in gaze to frame number; also figure out which folder
%each gaze point will need to come from;
frame_nums = frame_nums/(max_gaze_num - 1) * (max_frame);
folder_nums = sum(bsxfun(@minus,frame_nums,frame_endpoints)>=0,2);
frame_nums = floor(frame_nums);


%Initialize NSS Score array
NSS_scores = zeros(size(gaze_nums,1),1);


%These set the previous objects to unlabeled and the gaze to 1,1. Not super
%clean - just a start
previous_objects = 10*ones(height,width);
previous_gaze = [1 1];
for gaze_num = 1:size(gaze,1)
    
    gaze_loc = round(gaze(gaze_num,1:2));
    
    current_folder = folder_nums(gaze_num);
    frame = frame_nums(gaze_num) - frame_endpoints(current_folder);
    
    
    %LOAD SEMANTIC FRAMES INSTEAD OF COMPUTING THEM
    semantic_frame_name = ['annotations/',clip_folders(current_folder).name,...
        '/saved_semantic_frames/frame_',num2str(frame),'.mat'];
    load(semantic_frame_name);
    semantic_frame = frame_info.semantic_frame;
    
    %LOAD LOW LEVEL FEATURES
    low_frame_name = ['saved_low_frames/',clip_string,'/frame_'...
        num2str(frame_nums(gaze_num)),'.mat'];
    load(low_frame_name);
    low_frame = imresize(low_frame,height/size(low_frame,1));
    
    %get the probability distribution over the frame
    current_frame_p = p_frame(previous_gaze,previous_objects,semantic_frame,...
        low_frame,object_theta,attribute_theta,low_theta);
    
    %COMPUTE Z SCORES OF THE PROBABILITY OVER THE IMAGE
    frame_p_z_score = (current_frame_p - mean(current_frame_p(:)))/...
        std(current_frame_p(:));
    
    %STORE THE CURRENT GAZE LOCATION'S Z SCORE
    NSS_scores(gaze_num) = frame_p_z_score(gaze_loc(2),gaze_loc(1));
    
    
    %% update so the next frame can use transitions from this one
    previous_objects = semantic_frame(:,:,1);
    previous_gaze = gaze_loc;
    
    
end



end
