function [log_likelihood, derivative] = get_subject_clip_training_info_4opt_no_semantic(...
    full_theta, subject_type,subject_num,visualize)
%UNTITLED34 Summary of this function goes here
%   Detailed explanation goes here

%set height and width to fixed frame parameters
height = 1024;
width = 1280;
D = 114;

lambda = 1;

low_theta = full_theta;

%make sure low and attribute theta are the right shape, Assert not really
%necessary anymore

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

%initialize phi theo and emp sums to zero
phi_theo_sum = zeros(length(low_theta(:)),1);
phi_emp_sum = zeros(length(low_theta(:)),1);

log_likelihood = 0;
% full_theta = [object_theta(:); attribute_theta(:); low_theta(:)];

semantic_frame = zeros(height,width,10);
semantic_frame(:,:,1) = 10;

for gaze_num = 1:size(gaze,1)

    gaze_loc = round(gaze(gaze_num,1:2));

    %LOAD LOW LEVEL FEATURES
    low_frame_name = ['saved_low_frames/',clip_string,'/frame_'...
        num2str(frame_nums(gaze_num)),'.mat'];
    load(low_frame_name);
    
    %COMMENTED OUT FOR SPEED
    %low_frame = imresize(low_frame,height/size(low_frame,1));

    
    %get the probability distribution over the frame
%     current_frame_p = p_frame(previous_gaze,previous_objects,semantic_frame,...
%         low_frame,object_theta,attribute_theta,low_theta);
    exps = sum(bsxfun(@times,low_frame,low_theta),3);
    exps = exps - max(exps(:));

    current_frame_p = exp(exps) + realmin;

    
    
    % normalization
    current_frame_p = (current_frame_p) / sum(sum(current_frame_p));
    
    % visualize how the distribution looks like
    if exist('visualize','var') && ~isempty(visualize) && visualize
        figure(1);
        hold on;
        image(current_frame_p * 10000);
        drawnow;
    end


    %Get the low phi theoretical p-sum for this frame
%     phi_theo_low_contribution = ...
%         sum(sum(bsxfun(@times,low_frame,low_theta),1),2);
    phi_theo_low_contribution = ...
        sum(sum(bsxfun(@times,low_frame,current_frame_p),1),2);
    
    current_frame_p = imresize(current_frame_p,height/size(current_frame_p,1));
    
    %DONT UPSAMPLE FOR SPEED
    %low_frame = imresize(low_frame,height/size(low_frame,1));
    
    %DOWNSAMPLE GAZE
    down_gaze = round(gaze_loc * size(low_frame,1)/height);

    
    %Assemble the full phi theoretical p-sum for this frame
    full_phi_theo_contribution = ...
        [phi_theo_low_contribution(:)];

    %DIVIDE BY SUM P TO GET THE THEORETICAL EXPECTATION OF PHI FOR THIS
    %FRAME
%     full_phi_theo_contribution = full_phi_theo_contribution/sum(sum(current_frame_p));

    %ADD THE CONTRIBUTION TO THE FULL SUM TO EVENTUALLY GET MEAN
    %THEORETICAL PHI OVER ALL FRAME LOCATIONS AND ALL FRAMES
    phi_theo_sum = phi_theo_sum + full_phi_theo_contribution;


    % Get empirical phi from this frame

    %THIS NEEDS TO CHANGE IF THE COORDINATE SYSTEM IS DIFFERENT THAN I
    %THOUGHT IT WAS
    %phi_emp_low_contribution = low_frame(gaze_loc(2),gaze_loc(1),:);
    try
        phi_emp_low_contribution = low_frame(down_gaze(2),down_gaze(1),:);
    catch
        ['DATA/',type_folder,'/',second_folders(subject_num).name,'/sampled_5.mat']
        continue
    end

    full_phi_emp_contribution = ...
        [phi_emp_low_contribution(:)];

    %add contribution to phi_emp_sum
    phi_emp_sum = phi_emp_sum + full_phi_emp_contribution;
    
    log_likelihood = log_likelihood + log(current_frame_p(gaze_loc(2),gaze_loc(1)));
end

% derivation = phi_emp_sum - phi_theo_sum;
%log_likelihood = log_likelihood - phi_emp_sum * full_theta;

log_likelihood = -log_likelihood;
derivative = phi_theo_sum - phi_emp_sum;% + lambda*squeeze(low_theta);



end
