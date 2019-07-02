function [ binned ] = bin_sinogram_3d( ctData, n )
%BIN_SINOGRAM_3D Perform binning operation on an entire 3D sinogram
%   binned = bin_sinogram_3d(ctData, n) returns a copy of the computed 
%   tomography dataset ctData where the projections have been binned by a 
%   factor of n. Binning increases signal-to-noise ratio but reduces 
%   spatial resolution.The argument n must be a member of the set {1, 2, 4,
%   8, 16, 32}. For an i x j image, the binning operation returns an i/n
%   * j/n image, where each pixel has been summed from an n * n area of the
%   original image. The dataset must be the original dataset, i.e., you
%   cannot bin a sinogram that has already been binned once in
%   post-processing.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            30.1.2019
%   Last edited:        30.1.2019

rows    = ctData.parameters.projectionRows;
cols    = ctData.parameters.projectionCols;

% Check if downbinning is possible and allowed

if ~isscalar(n) || ~ismember(n, [1 2 4 8 16 32])
    error('Binning factor n must be a member of the set {1, 2, 4, 8, 16, 32}.');
end

if rem(rows, n) ~= 0 || rem(cols, n) ~= 0
    error('Downbinning factor leads to non-integer image size.');
end

if ctData.parameters.binningPost ~= 1
    error('Binning has already been performed in post-processing for this dataset. Use original dataset for binning.');
end

% Create a new ct project for the corrected data
binned          = struct;
binned.type     = '3D';

% Copy existing parameters into a new struct and modify needed values
parameters                      = ctData.parameters;
parameters.binningPost          = n;
parameters.projectionRows       = parameters.projectionRows / n;
parameters.projectionCols       = parameters.projectionCols / n;
parameters.pixelSize            = parameters.pixelSize * n;
parameters.effectivePixelSize   = parameters.effectivePixelSize * n;

% Create new, empty sinogram
sinogram    = zeros(parameters.projectionCols, ...
                    parameters.numberImages, ...
                    parameters.projectionRows);

% Loop through images, bin individually and place into new sinogram
for iii = 1 : parameters.numberImages
    I = squeeze(ctData.sinogram(:, iii, :));
    I = bin_projection(I, n);
    sinogram(:, iii, :) = I;
end

% Attach new scan parameters and sinogram to the new ct project
binned.parameters   = parameters;
binned.sinogram     = sinogram;


end

