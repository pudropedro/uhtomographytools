function [ subsampled ] = subsample_sinogram( ctData, anglesReduced )
%SUBSAMPLE_SINOGRAM Subsample angular range of sinogram.
%   subsampled = subsampled_sinogram(ctData, anglesReduced) returns a 
%   copy of the computed tomography dataset ctData in which the sinogram 
%   contains only the projections from the angles given in anglesReduced. 
%   The argument anglesReduced must be a vector containing the desired 
%   angles in degrees. This function works for both 2D and 3D datasets.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            1.7.2019
%   Last edited:        1.7.2019

% Create a new ct project for the subsampled data
subsampled      = struct;
subsampled.type = ctData.type;

% Create sparse angle indices
ind             = ismember(ctData.parameters.angles, anglesReduced);

% Create sub-sampled sinogram
if strcmp(ctData.type, '2D')
    sinogram        = ctData.sinogram(ind, :);
elseif strcmp(ctData.type, '3D')
    sinogram        = ctData.sinogram(:, ind, :);
else
    error('Invalid CT data type found, must be of type ''2D'' or ''3D''.');
end

% Copy existing parameters into a new struct and change angle data
parameters              = ctData.parameters;
parameters.numberImages = numel(anglesReduced);
parameters.angles       = anglesReduced;

% Attach new scan parameters and sinogram to the new ct project
subsampled.parameters   = parameters;
subsampled.sinogram     = sinogram;

end

