function [ B ] = normalize_image(A)
%NORMALIZE_IMAGE Normalize image values.
%   B = NORMALIZE_IMAGE(A) converts the (image) matrix A to data type 
%   double and normalizes it so that the minimum value is 0 and the
%   maximum value is 1.
%
%   Alexander Meaney, University of Helsinki
%   Created:        16.1.2018
%   Last edited:    28.6.2019

B = double(A);
B = B - min(B(:));
B = B ./ max(B(:));


end

