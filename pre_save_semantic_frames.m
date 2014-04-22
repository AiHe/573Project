function qqq = pre_save_semantic_frames()
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here


%open data folder
folders = dir('DATA');
folders = folders(4:end);

for subject_type = 1:4
    subject_type;

    %open specified subject type folder
    type_folder = folders(subject_type).name;

    %open the set of all subject/clip folders
    second_folders = dir(['Data/',type_folder]);
    second_folders = second_folders(3:end);
    if strcmp(second_folders(1).name,'.DS_Store')
        second_folders = second_folders(2:end);
    end
    
    for subject_num = 1:length(second_folders)

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

        for gaze_num = 1:size(gaze,1)

            current_folder = folder_nums(gaze_num);
            annotation_file = ['annotations/',clip_folders(current_folder).name,'/annot.txt'];
            frame = frame_nums(gaze_num) - frame_endpoints(current_folder);

            semantic_frame_name = ['annotations/',clip_folders(current_folder).name,...
                '/saved_semantic_frames/frame_',num2str(frame),'.mat'];

            try 
                load(semantic_frame_name);
                continue
            catch
                [semantic_frame, unique_object_inds] = ...
                    get_full_frame_semantics(annotation_file,frame);

                frame_info.semantic_frame = semantic_frame;
                frame_info.unique_object_inds = unique_object_inds;

                save(semantic_frame_name,'frame_info');

            end

        end
    end
    
    
    
    
end






    
    
    
    
qqq=0;
    
end

