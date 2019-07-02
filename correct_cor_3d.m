function [ corrected ] = correct_cor_3d( ctData, n )
%CORRECT_COR_3D Correct misplaced center of rotation in 3D CT data.
%   corrected = correct_cor_3d(ctData, n) returns a copy of the computed 
%   tomography dataset ctData where the center of rotation has been shifted
%   by n pixels, using circular boundary conditions. The argument n must an
%   integer. A positive value shifts the projections right and a negative 
%   value shifts the projections left.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            29.1.2019
%   Last edited:        1.7.2019

% Validate CT data type
if ~strcmp(ctData.type, '3D')
    error('ctData must be of type ''3D''.');
end

% Check n
if ~isscalar(n) || floor(n) ~= n
    error('Parameter ''n'' must be an integer.');
end

% Create a new ct project for corrected data
corrected           = struct;
corrected.type      = '3D';

% Copy existing parameters into a new struct
parameters          = ctData.parameters;
%parameters.corFix   = [parameters.corFix; n parameters.binning];

% Create new, empty sinogram
sinogram            = zeros(size(ctData.sinogram), 'single');

% Loop through images, shift individually and place into new sinogram
for iii = 1 : parameters.numberImages
    I = squeeze(ctData.sinogram(:, iii, :));
    I = circshift(I, n);
    sinogram(:, iii, :) = I;
end

% Attach new scan parameters and sinogram to the new ct project
corrected.parameters   = parameters;
corrected.sinogram     = sinogram;

end
