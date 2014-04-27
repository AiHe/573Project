function qqq = pre_save_low_frames()
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here


%open data folder
files = dir('Feature_map/');
files = files(3:end);

if strcmp(files(1).name,'.DS_Store')
    files = files(2:end);
end


for i = 1:length(files)
    i
    folder_name = ['Feature_map/',files(i).name];
    
    load([folder_name,'/featC.mat']);
    C = reshape(feats',[h w size(feats,1)]);
    
    load([folder_name,'/featF.mat']);
    F = reshape(feats',[h w size(feats,1)]);
    
    load([folder_name,'/featI.mat']);
    I = reshape(feats',[h w size(feats,1)]);
    
    load([folder_name,'/featM.mat']);
    M = reshape(feats',[h w size(feats,1)]);
    
    load([folder_name,'/featO.mat']);
    O = reshape(feats',[h w size(feats,1)]);
    
    for frame_num = 1:size(C,3)
        
        frame_name = ['saved_low_frames/',files(i).name,'/frame_',...
            num2str(frame_num-1),'.mat'];
    
        low_frame(:,:,1) = C(:,:,frame_num);
        low_frame(:,:,2) = F(:,:,frame_num);
        low_frame(:,:,3) = I(:,:,frame_num);
        low_frame(:,:,4) = M(:,:,frame_num);
        low_frame(:,:,5) = O(:,:,frame_num);
        
        save(frame_name,'low_frame');
        
        clear low_frame
    end
    
    
    
end



    
    
qqq=0;
    
end

