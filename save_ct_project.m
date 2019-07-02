function save_ct_project(ctData, varargin)
%SAVE_CT_PROJECT Save X-ray tomography data in external .mat file.
%   save_ct_project(ctData) saves the data structure given in ctData, which
%   contains the sinogram and imaging parameters of a CT scan, into an
%   external .mat file. The output filename will be generated automatically
%   from the CT metadata.
%
%   save_ct_project(ctData, filename) saves the data structure given in
%   ctData into an external .mat file which will be named as the argument
%   filename.
%
%   This function was created primarily for use in the Industrial
%   Mathematics Computed Tomography Laboratory at the University of
%   Helsinki.
%
%   Alexander Meaney, University of Helsinki
%   Created:            28.6.2019
%   Last edited:        28.6.2019

% Validate input arguments

if length(varargin) > 1
    error('Too many input arguments.');
end

if length(varargin) == 1
    if ~ischar(varargin{1})
        error('Second input argument must be a character array.');
    end
    if length(varargin{1}) < 1
        error('Filename cannot be empty.');
    end
end

% Create output filename

if length(varargin) == 1
    outputFilename = varargin({1});
else
    if length(ctData.parameters.projectName) < 1
        firstPart = 'unknown';
    else
        firstPart = ctData.parameters.projectName;
    end
    
    if ctData.parameters.binningPost ~= 1
        binningString = strcat('_binning_', ...
                               num2str(ctData.parameters.binningPost));
    else
        binningString = '';
    end

    outputFilename = strcat(firstPart, '_ct_project_', ...
                            lower(ctData.type), ...
                            binningString);
end

% Write to disk

fprintf('Saving CT project... ');

save(outputFilename, 'ctData', '-v7.3');

fprintf('CT project saved as %s.mat.\n', outputFilename);

end

