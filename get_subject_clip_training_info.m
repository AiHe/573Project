function [phi_emp_sum, phi_theo_sum, derivation, Hessian, num_points] = get_subject_clip_training_info(...
    subject_type,subject_num,object_theta,attribute_theta,low_theta)
%UNTITLED34 Summary of this function goes here
%   Detailed explanation goes here

%set height and width to fixed frame parameters
height = 1024;
width = 1280;
D = 100;

%make sure low and attribute theta are the right shape
assert(isequal(size(attribute_theta),[1 1 9]));
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
phi_theo_sum = zeros(length(object_theta(:))+length(attribute_theta(:)) + ...
    length(low_theta(:)),1);
phi_emp_sum = zeros(length(object_theta(:))+length(attribute_theta(:)) + ...
    length(low_theta(:)),1);
Hessian = zeros(D, D);

%These set the previous objects to unlabeled and the gaze to 1,1. Not super
%clean - just a start
previous_objects = 10*ones(height,width);
previous_gaze = [1 1];
for gaze_num = 1:size(gaze,1)

    gaze_loc = round(gaze(gaze_num,1:2));

    current_folder = folder_nums(gaze_num);
    annotation_file = ['annotations/',clip_folders(current_folder).name,'/annot.txt'];
    frame = frame_nums(gaze_num) - frame_endpoints(current_folder);

    [semantic_frame, unique_object_inds] = get_full_frame_semantics(annotation_file,frame);
    current_objects = semantic_frame(:,:,1);
    %CHANGE THIS ONCE WE GET LOW LEVEL FEATURES
    low_frame = ones(height, width, 5);

    %get the probability distribution over the frame
    current_frame_p = p_frame(previous_gaze,previous_objects,semantic_frame,...
        low_frame,object_theta,attribute_theta,low_theta);


    %% Get the object phi theoretical p-sum

    %get the object feature_func inds
    func_inds = sub2ind(size(object_theta),...
        previous_objects(previous_gaze(2),previous_gaze(1))*...
        ones(size(semantic_frame(:,:,1))),semantic_frame(:,:,1));

    %previous_object_vec = previous_objects(previous_gaze(2),previous_gaze(1))*...
        %ones(size(current_objects(:)));
    previous_object_num = previous_objects(previous_gaze(2),previous_gaze(1));
    %unique_combos = unique([previous_object_vec current_objects(:)],'rows');
    unique_combos = [previous_object_num*ones(size(unique_object_inds)) unique_object_inds];
    unique_inds = sub2ind(size(object_theta),unique_combos(:,1),unique_combos(:,2));

    phi_theo_object_contribution = zeros(100,1);
    for transition = 1:size(unique_combos,1)
        phi_theo_object_contribution(unique_inds(transition)) = ...
            sum(sum(current_frame_p(func_inds==unique_inds(transition)),1),2);
    end

    %Get the attribute phi theoretical p-sum
%     phi_theo_attribute_contribution = ...
%         sum(sum(bsxfun(@times,semantic_frame(:,:,2:end),attribute_theta),1),2);
    phi_theo_attribute_contribution = ...
        sum(sum(bsxfun(@times,semantic_frame(:,:,2:end),current_frame_p),1),2);


    %Get the low phi theoretical p-sum
%     phi_theo_low_contribution = ...
%         sum(sum(bsxfun(@times,low_frame,low_theta),1),2);
    phi_theo_low_contribution = ...
        sum(sum(bsxfun(@times,low_frame,current_frame_p),1),2);

    full_phi_theo_contribution = ...
        [phi_theo_object_contribution(:); ...
        phi_theo_attribute_contribution(:);phi_theo_low_contribution(:)];

    %DIVIDE BY SUM P
    full_phi_theo_contribution = full_phi_theo_contribution/sum(sum(current_frame_p));

    %add contribution into phi_theo_sum
    phi_theo_sum = phi_theo_sum + full_phi_theo_contribution;


%     phi_object = zeres(100, 1);
%     low_frame = rand();
    %% Get Hessian given from this frame at time t
%     for i_height = 1 : height
%         for i_width = 1 : width
%             full_phi = [phi_theo_object(i_height, i_width)...
%                     semantic_frame(i_height,i_width,2:end)];
%             diff_mat = (full_phi' * full_phi) * current_frame_p(i_height, i_width);
%             Hessian = Hessian - diff_mat;
%             full_phi_exp = full_phi * current_frame_p(i_height, i_width);
%             Hessian = Hessian + full_phi_exp' * full_phi_exp;
%         end
%     end

    %% Get empirical phi from this frame

    %THIS NEEDS TO CHANGE IF THE COORDINATE SYSTEM IS DIFFERENT THAN I
    %THOUGHT IT WAS
    phi_emp_object_contribution = zeros(10);
    phi_emp_object_contribution(func_inds(gaze_loc(2),gaze_loc(1))) = 1;

    phi_emp_attribute_contribution = semantic_frame(gaze_loc(2),gaze_loc(1),2:end);

    phi_emp_low_contribution = low_frame(gaze_loc(2),gaze_loc(1),:);

    full_phi_emp_contribution = ...
        [phi_emp_object_contribution(:); ...
        phi_emp_attribute_contribution(:); phi_emp_low_contribution(:)];

    %add contribution to phi_emp_sum
    phi_emp_sum = phi_emp_sum + full_phi_emp_contribution;

    %% update so the next frame can use transitions from this one
    previous_objects = semantic_frame(:,:,1);
    previous_gaze = gaze_loc;
end

derivation = phi_emp_sum - phi_theo_sum;





end