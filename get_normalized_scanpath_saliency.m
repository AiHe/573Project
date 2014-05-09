function [NSS_scores, AUC1_scores, AUC3_scores] = get_normalized_scanpath_saliency(...
    object_theta,attribute_theta,low_theta)
%UNTITLED34 Summary of this function goes here
%   Detailed explanation goes here

train = 0;

%Load the appropriate clip IDS
if train
    load('train_IDS');
else
    load('test_IDS');
end

%Initialize NSS Score array
NSS_scores = [];
AUC1_scores = [];
AUC3_scores = [];

for row = 1:size(IDS,1)
    fprintf('row: %i\n', row);  
    
    subject_type = IDS(row,1);
    subject_num = IDS(row,2);
    
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
        if isequal(zeros(10),object_theta) && isequal(zeros(9,1),attribute_theta(:))
            add = sum(bsxfun(@times,low_frame,low_theta),3);
            add = add - max(add(:));
            current_frame_p = exp(add) + realmin;
        else
            current_frame_p = p_frame(previous_gaze,previous_objects,semantic_frame,...
                low_frame,object_theta,attribute_theta,low_theta);
        end
        
        %% AUC
%         current_frame_p, gaze_loc(2),gaze_loc(1),
        eyeMap = zeros(size(current_frame_p));
        eyeMap(gaze_loc(2),gaze_loc(1)) = 1;
        shufMap = zeros(size(current_frame_p));
        for gaze_num_local = 1:size(gaze,1)
            if(gaze_num_local == gaze_num); continue;end
            gaze_loc_local = round(gaze(gaze_num_local,1:2));
%             if(gaze_loc_local(2)) > 1024; gaze_loc_local(2) = 1024;end
%             if(gaze_loc_local(1)) > 1280; gaze_loc_local(1) = 1280;end
            shufMap(gaze_loc_local(2), gaze_loc_local(1)) = 1;
        end
        try 
            AUC3_scores(end+1) = calc_AUC_score( current_frame_p, eyeMap, shufMap);
        catch
            ['DATA/',type_folder,'/',second_folders(subject_num).name,'/sampled_5.mat']
            continue
        end
        
        eyeMap = zeros(size(current_frame_p));
        eyeMap(gaze_loc(2),gaze_loc(1)) = 1;
        try
            AUC1_scores(end+1) = calc_AUC_score( current_frame_p, eyeMap);
        catch
            ['DATA/',type_folder,'/',second_folders(subject_num).name,'/sampled_5.mat']
            continue
        end
%         
%         current_frame_p = current_frame_p/ sum(current_frame_p(:));
        
        %% NNS
        %COMPUTE Z SCORES OF THE PROBABILITY OVER THE IMAGE
        frame_p_z_score = (current_frame_p - mean(current_frame_p(:)))/...
            std(current_frame_p(:));
        
%             imshow(frame_p_z_score);
%             uiwait();
        
        %STORE THE CURRENT GAZE LOCATION'S Z SCORE
        try
            NSS_scores(end+1) = frame_p_z_score(gaze_loc(2),gaze_loc(1));
        catch
            ['DATA/',type_folder,'/',second_folders(subject_num).name,'/sampled_5.mat']
            continue
        end
        
        
        %% update so the next frame can use transitions from this one
        previous_objects = semantic_frame(:,:,1);
        previous_gaze = gaze_loc;
        
        
    end
    
    fprintf('mean AUC1: %f\n', mean(AUC1_scores));  
    fprintf('mean AUC3: %f\n', mean(AUC3_scores));  
    
end



end
