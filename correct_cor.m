function [ corrected ] = correct_cor( ctData, n )
%CORRECT_COR Correct misplaced center of rotation in CT data.
%   corrected = correct_cor(ctData, n) returns a copy of the computed 
%   tomography dataset ctData where the center of rotation has been shifted
%   by n pixels, using circular boundary conditions. The argument n must an
%   integer. A positive value shifts the projections right and a negative 
%   value shifts the projections left. This function works for both 2D and 
%   3D datasets.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            1.7.2019
%   Last edited:        1.7.2019

% Check n
if ~isscalar(n) || floor(n) ~= n
    error('Parameter ''n'' must be an integer.');
end

% Create a new ct project for corrected data
corrected       = struct;
corrected.type  = ctData.type;

% Copy existing parameters into a new struct
parameters      = ctData.parameters;

% Create new, empty sinogram
if strcmp(ctData.type, '3D')
    sinogram    = zeros(size(ctData.sinogram), 'single');
else
    sinogram    = zeros(size(ctData.sinogram));
end

% Create shifted sinogram
if strcmp(ctData.type, '2D')
    sinogram    = circshift(ctData.sinogram, n, 2);
elseif strcmp(ctData.type, '3D')
    % Loop through images, shift individually and place into new sinogram
    for iii = 1 : parameters.numberImages
        I = squeeze(ctData.sinogram(:, iii, :));
        I = circshift(I, n);
        sinogram(:, iii, :) = I;
    end
else
    error('Invalid CT data type found, must be of type ''2D'' or ''3D''.');
end    
    
% Attach new scan parameters and sinogram to the new ct project
corrected.parameters    = parameters;
corrected.sinogram      = sinogram;

end
