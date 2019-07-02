function [ B ] = normalize_image_nneg(A)
%NORMALIZE_IMAGE_NNEG Normalize image values, non-negativity constraints.
%   B = NORMALIZE_IMAGE_NNEG(A) converts the (image) matrix A to data type 
%   double and normalizes it so that the minimum value is 0 and the
%   maximum value is 1. Before this normalization process is computed, all
%   negative values of A are set to zero.
%
%   Alexander Meaney, University of Helsinki
%   Created:        28.6.2018
%   Last edited:    28.6.2019

B = double(A);
B = B - min(B(:));
B = B ./ max(B(:));


end

