function p = p_frame(past_loc,past_object_frame,semantic_frame,...
    low_frame,object_theta,attribute_theta,low_theta)
%UNTITLED33 Summary of this function goes here
%   Detailed explanation goes here

object_func_inds = sub2ind(size(object_theta),...
    past_object_frame(past_loc(2),past_loc(1))*...
    ones(size(semantic_frame(:,:,1))),semantic_frame(:,:,1));



object_contribution = object_theta(object_func_inds);

% imshow(n(object_contribution));
% uiwait();

assert(size(attribute_theta,1)==1);
assert(size(attribute_theta,2)==1);

attribute_contribution = sum(bsxfun(@times,semantic_frame(:,:,2:end),attribute_theta),3);
% imshow(n(attribute_contribution));
% uiwait();

assert(size(low_theta,1)==1);
assert(size(low_theta,2)==1);

low_contribution = sum(bsxfun(@times,low_frame,low_theta),3);

% imshow(n(low_contribution));
% uiwait();


p = exp(object_contribution + attribute_contribution + low_contribution);






end

