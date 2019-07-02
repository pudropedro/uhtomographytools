function [ ctData ] = create_ct_project_2d( projectName, varargin )
%CREATE_CT_PROJECT_2D Prepare 2D tomography data for reconstruction.
%   ctData = create_ct_project_2d(projectName) creates a data structure 
%   which contains the 2D sinogram and imaging parameters of a CT scan. A
%   parameter file must exist for the project and it should be in the 
%   format specified by the file 'ct_scan_parameters_template.txt'. The
%   argument projectName should be the first part of the filename shared by
%   all the project files.
%
%   ctData = create_ct_project_2d(projectName, argumentName, argumentValue)
%   calls the function using the optional arguments specified by
%   argumentName and argumentValue. The following optional arguments exist:
%
%   'FreeRay'   This argument determines the area that is used to determine
%               the intensity of the X-ray when it passes unattenuated to
%               the detector. The format it [row1 row2 column2 column2].
%               The default values are [1 128 1 128].
%
%   'CorFix'    This argument corrects for a misplaced center of rotation. 
%               The value must an integer. Center of rotation correction 
%               shifts the projections by a number of pixels equal to the 
%               argument value, using circular boundary conditions. A 
%               positive value shifts the projections right and a negative
%               value shifts the projections left. The default value is 0 
%               (no correction). 
%
%   'Binning'   This argument specifies the binning factor for the
%               projection images. Binning increases signal-to-noise ratio
%               but reduces spatial resolution. The value must be a member 
%               of the set {1, 2, 4, 8, 16, 32}. The default value is 1 (no
%               binning).
%
%   'Save'      This argument specifies if the created data structure
%               is saved into a .mat file in the current folder. The 
%               possible values are 1 (yes) and 0 (no). The default value 
%               is 1.
%
%   'Filename'  This argument specifies the name of the .mat file the data
%               structure will be saved into. Specifying this parameter
%               will have no effect if the 'Save' parameter has the value
%               0. If this parameter is not specified, a filename will be
%               generate automatically.
%
%   NOTE: center of rotation correction is performed before binning.
%
%   NOTE: binning is performed before extracting the center row of the
%   projections for the 2D sinogram.
%
%   All measures of distance in the parameters are given in millimeters, 
%   and all angles are in degrees.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            28.6.2019
%   Last edited:        28.6.2019


% Deal with optional arguments --------------------------------------------

% Default values

freeRay         = [1 128 1 128];
corFix          = 0;
binning         = 1;
saveToDisk      = 1;
outputFilename  = '';   % The output filename will be automatically 
                        % generated later in the code if it is not 
                        % explicitly given by the user.

for iii = 1 : 2 : length(varargin)
    switch varargin{iii}
        case 'FreeRay'
            freeRay = varargin{iii + 1};
        case 'CorFix'
            corFix = varargin{iii + 1};
        case 'Binning'
            binning = varargin{iii + 1};
        case 'Save'
            saveToDisk = varargin{iii + 1};
        case 'Filename'
            outputFilename = varargin{iii + 1};
        otherwise
            error('Unknown parameter name: %s.', varargin{iii});
    end
end

% Validate parameters

if ~isnumeric(freeRay) || ~isequal(size(freeRay), [1 4]) || sum(freeRay > 0) ~= 4
    error('Parameter ''FreeRay'' must be a 1x4 matrix with positive integer elements.');
end

if freeRay(1) >= freeRay(2) || freeRay(3) >= freeRay(4)
    error('Parameter ''FreeRay'' must be of the form [row1 row2 column1 column2], where row1 < row2 and column1 < column2.'); 
end

if ~isscalar(corFix) || floor(corFix) ~= corFix 
    error('Parameter ''CorFix'' must be an integer.');
end

if ~isscalar(binning) || ~ismember(binning, [1 2 4 8 16 32])
    error('Parameter ''Binning'' must be a member of the set {1, 2, 4, 8, 16, 32}.');
end

if ((freeRay(2)-freeRay(1)+1)/binning) ~= floor((freeRay(2)-freeRay(1)+1)/binning) || ...
        ((freeRay(4)-freeRay(3)+1)/binning) ~= floor((freeRay(4)-freeRay(3)+1)/binning)
   error('Choose parameters FreeRay and Binning so that binning does not lead to a non-integer background image size.');
end

if ~ismember(saveToDisk, [0 1])
    error('Parameter ''Save'' must 1 (save to disk) or 0 (no save).');
end

% Create CT dataset -------------------------------------------------------

fprintf('Creating CT project ''%s''.\n', projectName);

% Create empty structure to which all data will be attached
ctData          = struct;
ctData.type     = '2D';

fprintf('Getting parameters and metadata... ');

% Read CT scan parameters and metadata
parameterFile   = strcat(projectName, '_scan_data.txt');
parameters      = read_ct_scan_parameters(parameterFile);

% Get image size from first projection and add to parameters
filename            = strcat(projectName, '_001.tif');
I                   = imread(filename);
[rowsRaw, colsRaw]  = size(I);

% Fill in parameters about number of rows and columns in raw projections
parameters.detectorRowsRaw  = rowsRaw;
parameters.detectorColsRaw  = colsRaw;

% Number of pixels in single 2D projection
numDetectors    = colsRaw / binning;

% Add new fields to parameter data
parameters.freeRay              = freeRay;
%parameters.corFix               = [corFix 1]; % Latter number denotes binning when correction is computed
parameters.binningPost          = binning;
parameters.numDetectors         = numDetectors;
parameters.pixelSize            = parameters.pixelSizeRaw * binning;
parameters.effectivePixelSize   = parameters.pixelSize / parameters.geometricMagnification;

fprintf('Done.\n');

% Initialize empty 2D sinogram using ASTRA geometry
% Data type 'single' is used due to memory considerations
sinogram = zeros(parameters.numberImages, numDetectors);

% Center row of projections
centerRow = (rowsRaw / binning) / 2;

% Read each image, compute log transform, and place into 2D sinogram
for iii = 1 : parameters.numberImages
    fprintf('Processing image %d/%d... ', iii, parameters.numberImages);

    % Load image
    filename        = strcat(projectName, '_', sprintf('%03d', iii), '.tif'); 
    I               = single(imread(filename));
    
    % Extract background intensity area
    background      = I(freeRay(1):freeRay(2), freeRay(3):freeRay(4));
    
    % Fix misplaced center of rotation, if this option has been used
    if corFix ~= 0
        I = circshift(I, corFix, 2);
    end
    
    % Execute image binning, if this option has been used
    if binning ~= 1
        I           = bin_projection(I, binning);
        background  = bin_projection(background, binning);
    end
    
    bkgdIntensity   = mean(background(:));    
    
    % Log-transform of projection
    I = -log( I ./ bkgdIntensity );
      
    % Center row of projection
    detectorData = I(centerRow, :);
    
    % Insert into sinogram
    sinogram(iii, :) = detectorData;
    
    fprintf('Done.\n');
end

% Attach scan parameters and sinogram to structure
ctData.parameters   = parameters;
ctData.sinogram     = sinogram;

% Save data structure in file
if saveToDisk == 1
    fprintf('Saving CT project... ');
    
    % Create a filename for the CT data if the user didn't give one
    if strcmp(outputFilename, '')
        if binning ~= 1
            binningString = strcat('_binning_', num2str(binning));
        else
            binningString = '';
        end

        outputFilename      = strcat(projectName, '_ct_project_2d', binningString);
    end
    
    save(outputFilename, 'ctData', '-v7.3');

    fprintf('CT project saved as %s.mat.\n', outputFilename);
end

fprintf('CT project creation completed.\n');

end


