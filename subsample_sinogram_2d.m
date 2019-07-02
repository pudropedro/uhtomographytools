function [ subsampled ] = subsample_sinogram_2d( ctData, anglesReduced )
%SUBSAMPLE_SINOGRAM_2D Subsample angular range of 2D sinogram.
%   subsampled = subsampled_sinogram_2d(ctData, anglesReduced) returns a 
%   copy of the computed tomography dataset ctData in which the sinogram 
%   contains only the projections from the angles given in anglesReduced. 
%   The argument anglesReduced must be a vector containing the desired 
%   angles in degrees.
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

% Create a new ct project for the subsampled data
subsampled      = struct;
subsampled.type = '2D';

% Create sub-sampled sinogram
ind             = ismember(ctData.parameters.angles, anglesReduced);
sinogram        = ctData.sinogram(ind, :);

% Copy existing parameters into a new struct and change angle data
parameters              = ctData.parameters;
parameters.numberImages = numel(anglesReduced);
parameters.angles       = anglesReduced;

% Attach new scan parameters and sinogram to the new ct project
subsampled.parameters   = parameters;
subsampled.sinogram     = sinogram;

end

