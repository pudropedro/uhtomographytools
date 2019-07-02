function [ A ] = bin_projection(I, n)
%BIN_PROJECTION Perform binning operation on an image
%   A = bin_projection(I, n) computes a binned version of image I using a
%   binning factor of n.  Binning increases signal-to-noise ratio but 
%   reduces spatial resolution. The factor n must be an integer power of 2 
%   in the range 1 <= 32. For an i x j image, the binning operation returns
%   an i/n * j/n image, where each pixel has been summed from an n * n area
%   of the original image.
%
%   Alexander Meaney, University of Helsinki
%   Created:            28.8.2017
%   Last edited:        30.1.2019

[rows, cols] = size(I);

% Check if downbinning is possible

if ~isscalar(n) || ~ismember(n, [1 2 4 8 16 32])
    error('Binning factor n must be a member of the set {1, 2, 4, 8, 16, 32}.');
end

if rem(rows, n) ~= 0 || rem(cols, n) ~= 0
    error('Downbinning factor leads to non-integer image size.');
end

A = reshape(I, [n rows*cols/n]);
A = sum(A);
A = reshape(A, [rows/n cols]);

A = A.';
  
A = reshape(A, [n rows*cols/n^2]);
A = sum(A);
A = reshape(A, [cols/n rows/n]);

A = A.';

end

