function [starts, targets, target_frame_nums, max_gaze_num] = get_starts_targets(gaze)
%UNTITLED22 Summary of this function goes here
%   Detailed explanation goes here



starts = gaze(1,1:2);

indexes = (1:size(gaze,1))';

saccade_lines = (gaze(:,4)==1)&(gaze(:,5)~=0)&(gaze(:,6)~=0);
lines = gaze(saccade_lines,:);


targets = lines(:,5:6);
starts = [starts;lines(:,1:2)];
target_frame_nums = indexes(saccade_lines);
max_gaze_num = size(gaze,1);




end

