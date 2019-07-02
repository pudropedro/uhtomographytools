function [ corrected ] = correct_cor_2d( ctData, n )
%CORRECT_COR_2D Correct misplaced center of rotation in sinogram.
%   corrected = correct_cor_2d(ctData, n) returns a copy of the computed 
%   tomography dataset ctData where the center of rotation has been shifted
%   by n pixels, using circular boundary conditions. The argument n must an
%   integer. A positive value shifts the sinogram right and a negative 
%   value shifts the sinogram left.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            1.7.2019
%   Last edited:        1.7.2019

% Validate CT data type
if ~strcmp(ctData.type, '2D')
    error('ctData must be of type ''2D''.');
end

% Check n
if ~isscalar(n) || floor(n) ~= n
    error('Parameter ''n'' must be an integer.');
end

% Create a new ct project for corrected data
corrected           = struct;
corrected.type      = '2D';

% Copy existing parameters into a new struct
parameters          = ctData.parameters;

% Create shifted sinogram
sinogram            = circshift(ctData.sinogram, n, 2);

% Attach new scan parameters and sinogram to the new ct project
corrected.parameters   = parameters;
corrected.sinogram     = sinogram;

end
