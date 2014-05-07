function N = n( mat)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



N = (mat - min(mat(:)))/(max(mat(:)) - min(mat(:)));


end

