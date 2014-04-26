function [train_IDS, test_IDS] = divide_data(autistic)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

rng(0);

test_clips = randsample(1:20,6,'false')

numstr = cell(20,1);
for i = 1:9
    numstr{i} = ['0',num2str(i)];
end
for i = 10:20
    numstr{i} = num2str(i);
end

%open data folder
folders = dir('DATA');
folders = folders(4:end);

%get matrices ready to store train/test IDS
train_IDS = zeros(1,2);
test_IDS = zeros(1,2);

%Only go through the subject type folders specified by autistic input
for subfolder = ([1,2] + (~autistic)*2)
    
    %Open specified subfolder
    subfolder_name = ['DATA/',folders(subfolder).name];
    
    subfolder_contents = dir(subfolder_name);
    subfolder_contents = subfolder_contents(3:end);
    if strcmp(subfolder_contents(1).name,'.DS_Store')
        subfolder_contents = subfolder_contents(2:end);
    end
    
    
    %Go to each clip folder, assign its index to the test or train mat
    for clip_num = 1:length(subfolder_contents)
        
        %Check to see if the clip is a test clip by looking for any test
        %clip's string num in the name of the clip folder
        clip_name = subfolder_contents(clip_num).name;
        is_test_clip = 0;
        for test_num = test_clips
            if ~isempty(findstr(clip_name,['mtv3clip',numstr{test_num}]))
                is_test_clip = 1;
                break;
            end
        end
        
        %Assign test clips to test mat, train clips to train mat
        if is_test_clip
            test_IDS(end+1,:) = [subfolder clip_num];
        else
            train_IDS(end+1,:) = [subfolder clip_num];
        end
        
    end
    
end
        

    
train_IDS = train_IDS(2:end,:);
test_IDS = test_IDS(2:end,:);
IDS = train_IDS;
save('train_IDS','IDS');

IDS = test_IDS;
save('test_IDS','IDS');
    
    
    
    
end















