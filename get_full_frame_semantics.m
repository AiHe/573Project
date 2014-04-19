function [semantic_frame, unique_object_inds] = get_full_frame_semantics(file,frame_num)
%UNTITLED28 Summary of this function goes here
%   Detailed explanation goes here

width = 1280;
height = 1024;


possible_objects = {'Animal';'Body';'Eyes';'Face';'Mouth';'Nose';'Object';'Person';'unlabeled';'outside'};
possible_attributes  = {'attentive','central','goal',...
    'marginal','moving','nongoal','nonsocial','social','static'};

annotation_string = fileread(file);

if isempty(annotation_string)
    semantic_frame = zeros(height,width,10);
    semantic_frame(:,:,1) = 9*ones(height,width);
    unique_object_inds = [];
else
    semantic_frame = zeros(height,width,10);
    semantic_frame(:,:,1) = 10*ones(height,width);
    
    annotation_string = strsplit(annotation_string,'\n');
    annotation_string = annotation_string(1:end-1);
    
    
    %get the frame number and box points at each line of the file
    frame_at_line = zeros(length(annotation_string),1);
    min_points = zeros(length(annotation_string),2);
    max_points = zeros(length(annotation_string),2);
    for line = 1:length(annotation_string)
        annotation_string{line} = strsplit(annotation_string{line});
        frame_at_line(line) = str2double(annotation_string{line}{6});
        min_points(line,:) = [str2double(annotation_string{line}{2}) ...
            str2double(annotation_string{line}{3})];
        max_points(line,:) = [str2double(annotation_string{line}{4}) ...
            str2double(annotation_string{line}{5})];
    end
    scale =  1028/480;
    min_points = round(min_points*scale);
    max_points = round(max_points*scale);
    
    min_points(min_points(:, 1) > width, 1) = width;
    max_points(max_points(:, 1) > width, 1) = width;
    min_points(min_points(:, 2) > height, 2) = height;
    max_points(max_points(:, 2) > height, 2) = height;
    
    min_points(min_points(:, 1) < 1, 1) = 1;
    max_points(max_points(:, 1) < 1, 1) = 1;
    min_points(min_points(:, 2) < 1, 2) = 1;
    max_points(max_points(:, 2) < 1, 2) = 1;
    
    use_lines = find(frame_at_line == frame_num);
    
    object_inds = 10*ones(height,width,length(use_lines));
    unique_object_inds = [];
    for box = 1:length(use_lines)
        
        c_line = use_lines(box);
        line_props = annotation_string{c_line}(10:end);
        
        for word = 1:length(line_props)
            line_props{word} = strrep(line_props{word},'"','');
        end
        %[min_points(c_line,2),max_points(c_line,2),min_points(c_line,1),max_points(c_line,1)]
        
        %semantic_frame(min_points(c_line,2):max_points(c_line,2),min_points(c_line,1):max_points(c_line,1),1) = get_min_object_indexes({line_props});
        
        min_object_ind = get_min_object_indexes({line_props});
        object_inds(min_points(c_line,2):max_points(c_line,2),min_points(c_line,1):max_points(c_line,1), ...
            box) = min_object_ind;
        
        unique_object_inds(end+1) = min_object_ind;
        
        semantic_attributes = semantic_attribute_feature_func({line_props});
        semantic_frame(min_points(c_line,2):max_points(c_line,2),...
            min_points(c_line,1):max_points(c_line,1),2:end) =...
            bsxfun(@or,semantic_frame(min_points(c_line,2):max_points(c_line,2),...
            min_points(c_line,1):max_points(c_line,1),2:end),semantic_attributes);
        
        
    end
    
    semantic_frame(:,:,1) = min(object_inds,[],3);
    
    
end


unique_object_inds = unique_object_inds(:);


end

