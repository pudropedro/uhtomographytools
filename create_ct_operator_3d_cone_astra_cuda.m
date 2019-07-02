function [ A ] = create_ct_operator_3d_cone_astra_cuda( ctData, xDim, yDim, zDim )
%CREATE_CT_OPERATOR_3D_CONE_ASTRA_CUDA Create CT forward model using GPU.
%   create_ct_operator_3d_cone_astra_cuda( ctData, xDim, yDim, zDim ) 
%   computes the forward model, i.e. X-ray projection operator, for the 3D 
%   cone-beam CT data given in ctData. The x-, y-, and z-dimensions of the 
%   CT volume are given by xDim, yDim, and zDim, respectively. The imaging 
%   geometry is created using the metadata in ctData. It is assumed that a 
%   flat panel detector has been used for the X-ray projection measurements.
%
%   The forward model is an operator that behaves like a matrix, for
%   example in operations like A*x and and A.'*x, but no explicit matrix is
%   actually created.
%
%   Use of this function requires that the ASTRA Tomography Toolbox and the
%   Spot Linear-Operator Toolbox have been added to the MATLAB path, and 
%   that the computer is equipped with a CUDA-enabled GPU.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            30.1.2019
%   Last edited:        1.7.2019

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

% Create the Spot operator for ASTRA using the GPU.
A = opTomo('cuda', projectionGeometry, volumeGeometry);
fprintf('done.\n');

% Memory cleanup
astra_mex_data3d('delete', volumeGeometry);
astra_mex_data3d('delete', projectionGeometry);
clearvars -except A


end

