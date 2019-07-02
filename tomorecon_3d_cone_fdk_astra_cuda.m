function [ reconstruction ] = tomorecon_3d_cone_fdk_astra_cuda( ctData, xDim, yDim, zDim )
%TOMORECON_3D_CONE_FDK_ASTRA_CUDA Compute analytical 3D reconstruction.
%   reconstruction = tomorecon_3d_cone_fdk_astra_cuda(ctData, xDim, yDim, 
%   zDim) computes the approximate analytical 3D reconstruction of the
%   cone-beam CT data in ctData, using the FDK algorithm. The x-, y-, and
%   z-dimensions of the reconstruction are given by xDim, yDim, and zDim,
%   respectively. It is assumed that a flat panel detector has been used 
%   for the X-ray projection measurements.
%
%   Use of this function requires that the ASTRA Tomography Toolbox has
%   been added to the MATLAB path, and that the computer is equipped with a
%   CUDA-enabled GPU.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            30.1.2019
%   Last edited:        1.7.2019


% Validate CT data type
if ~strcmp(ctData.type, '3D')
    error('ctData must be of type ''3D''.');
end

% Create shorthands for needed variables
DSD             = ctData.parameters.distanceSourceDetector;
DSO             = ctData.parameters.distanceSourceOrigin;
M               = ctData.parameters.geometricMagnification;
angles          = ctData.parameters.angles;
rows            = ctData.parameters.projectionRows;
cols            = ctData.parameters.projectionCols;
pixelSize       = ctData.parameters.pixelSize;
effPixel        = ctData.parameters.effectivePixelSize;

% Distance from origin to detector
DOD             = DSD - DSO;

% Distance from source to origin specified in terms of effective pixel size
DSO             = DSO / effPixel;

% Distance from origin to detector specified in terms of effective pixel size
DOD             = DOD /effPixel;

% ASTRA uses angles in radians
anglesRad       = deg2rad(angles);

% ASTRA code begins here
fprintf('Creating geometries and data objects in ASTRA... ');

% Create volume geometry, i.e. reconstruction geometry
volumeGeometry = astra_create_vol_geom(xDim, yDim, zDim);

% Create projection geometry
projectionGeometry = astra_create_proj_geom('cone', M, M, ...
                                            rows, cols, ...
                                            anglesRad, DSO, DOD);

% Create 3D data object for reconstruction
reconstructionObject = astra_mex_data3d('create', '-vol', volumeGeometry, 0);

% Create 3D data object for sinogram
projectionsObject       = astra_mex_data3d('create', '-proj3d', projectionGeometry, ctData.sinogram);

fprintf('done.\n');

% Create and initialize reconstruction algorithm
fprintf('Creating reconstruction algorithm in ASTRA... ');
cfg                         = astra_struct('FDK_CUDA');
cfg.ReconstructionDataId    = reconstructionObject;
cfg.ProjectionDataId        = projectionsObject;
reconstructionAlgorithm     = astra_mex_algorithm('create', cfg);
fprintf('done.\n');

% Run reconstruction algorithm
fprintf('Running reconstruction algorithm in ASTRA... ');
astra_mex_algorithm('run', reconstructionAlgorithm);
fprintf('done.\n');

% Get reconstruction as a matrix
reconstruction = astra_mex_data3d('get', reconstructionObject);

% Memory cleanup
astra_mex_data3d('delete', volumeGeometry);
astra_mex_data3d('delete', projectionGeometry);
astra_mex_data3d('delete', reconstructionObject);
astra_mex_data3d('delete', projectionsObject);
astra_mex_algorithm('delete', reconstructionAlgorithm);
astra_clear;
clearvars -except reconstruction

end

