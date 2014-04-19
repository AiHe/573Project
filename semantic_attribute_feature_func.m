function all_atts = semantic_attribute_feature_func(properties)
%UNTITLED25 Summary of this function goes here
%   Detailed explanation goes here

possible_attributes  = {'attentive','central','goal',...
    'marginal','moving','nongoal','nonsocial','social','static'};

%all_phis = zeros(length(properties),9);

all_atts = zeros(size(properties,1),size(properties,2),9);

for place_1 = 1:size(properties,1)
    for place_2 = 1:size(properties,2)

        focus_properties = properties{place_1,place_2};



        for word = 1:length(focus_properties)

            for test_word = 1:length(possible_attributes)

                if strcmp(focus_properties{word},possible_attributes{test_word})
                    all_atts(place_1,place_2,test_word)=1;
                end
            end
        end
    end
    
    
end










end

