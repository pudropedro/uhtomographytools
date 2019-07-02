function [ scanParameters ] = read_ct_scan_parameters( filename )
%READ_CT_SCAN_PARAMETERS Create structure containing CT scan parameters.
%   scanParameters = read_ct_scan_parameters(filename) creates a structure 
%   containing all the relevant parameters and metadata of a computed 
%   tomography scan, but no actual projection data. The parameters are 
%   found in the .txt file specified by filename, and file itself should be
%   in the format specified by the file 'ct_scan_parameters_template.txt'.
%
%   All measures of distance are given in millimeters, and all angles are
%   in degrees.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            28.1.2019
%   Last edited:        10.4.2019


% Verify that the filename given belongs to a .txt file
[~, ~, ext] = fileparts(filename);
if ~strcmp(ext, '.txt')
    error('Input must be a .txt file.')
end

% Read data from file
f           = fopen(filename, 'r');
rawData     = textscan(f, '%s %s', 'delimiter', '=');
fclose(f);

% Create Map from raw data
dataMap     = containers.Map(strtrim(rawData{1}), strtrim(rawData{2}));

% Remove unwanted elements from dataMap
remove(dataMap, '[GENERAL]');
remove(dataMap, '[GEOMETRY]');
remove(dataMap, '[ACQUISITION]');
remove(dataMap, '[DETECTOR]');
remove(dataMap, '[XRAY]');

% Compute new geometric variable from data
distanceSourceOffset    = str2double(dataMap('DistanceSourceOffset'));
distanceOffsetSample    = str2double(dataMap('DistanceOffsetSample'));
distanceSourceDetector  = str2double(dataMap('DistanceSourceDetector'));

distanceSourceOrigin    = distanceSourceOffset + distanceOffsetSample;
geometricMagnification  = distanceSourceDetector / distanceSourceOrigin;

angleFirst              = str2double(dataMap('AngleFirst'));
angleInterval           = str2double(dataMap('AngleInterval'));
angleLast               = str2double(dataMap('AngleLast'));

angles                  = angleFirst : angleInterval : angleLast;

% Create a struct containing the data converted into the correct data types
scanParameters                          = struct;
scanParameters.projectName              = dataMap('ProjectName');
scanParameters.scanner                  = dataMap('Scanner');
scanParameters.distanceSourceDetector   = distanceSourceDetector;
scanParameters.distanceSourceOrigin     = distanceSourceOrigin;
scanParameters.geometricMagnification   = geometricMagnification;
scanParameters.numberImages             = str2double(dataMap('NumberImages'));
scanParameters.angles                   = angles;
scanParameters.detector                 = dataMap('Detector');
scanParameters.pixelSizeRaw             = str2double(dataMap('PixelSize'));
scanParameters.binningRaw               = dataMap('Binning');
scanParameters.detectorRowsRaw          = '';
scanParameters.detectorColsRaw          = '';
scanParameters.exposureTime             = dataMap('ExposureTime');
scanParameters.target                   = dataMap('Target');
scanParameters.tube                     = dataMap('Tube');
scanParameters.voltage                  = dataMap('Voltage');
scanParameters.current                  = dataMap('Current');
scanParameters.xRayFilter               = dataMap('XRayFilter');
scanParameters.xRayFilterThickness      = dataMap('XRayFilterThickness');

end

