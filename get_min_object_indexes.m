function min_object_indexes = get_min_object_indexes(properties)
%UNTITLED24 Summary of this function goes here
%   Detailed explanation goes here

possible_objects = {'Mouth','Eyes','Nose','Face','Body','Person','Animal','Object','outside','unlabeled'};


min_object_indexes = zeros(length(properties),1);
for line = 1:length(properties(:))
    present = zeros(1,10);
    
    for prop_num = 1:length(properties{line})
        present = present | strcmp(properties{line}{prop_num},possible_objects);
    end
    try
        min_object_indexes(line) = find(present,1,'first');
    catch
        d = 0;
    end
    
end

%objects = possible_objects(min_object_indexes)';


end
