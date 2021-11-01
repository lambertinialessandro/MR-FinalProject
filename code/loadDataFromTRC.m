function [initInfo, NumFrames, NumMarkers, m_cols] = loadDataFromTRC(inputPath, inputFile)
% Load the data from the file following the TRC format.
%
% OUTPUT
%
% initInfo: Cell contening the first k lines of the file
% NumFrames: Number of the frames inside the file
% NumMarkers: Number of the markers inside the file
% m_cols: Matrix containig the data of the markers over the time

    arguments
        % Directory in which we are going to load the data as TRC file format
        inputPath string {mustBeFolder}
        % (OPTIONAL) Name of the file in which we want to write
        inputFile string {mustBeText} = ""
    end

    switch nargin
        case 0
            % if we haven't the file's name, we ask to the user to select it
            [inputFile, inputPath] = uigetfile("*.trc")
        case 1
            % if we haven't the file's name, we ask to the user to select it
            [inputFile, inputPath] = uigetfile(strcat(inputPath, "*.trc"));
        case 2
            % we have all the parameters, fine
        otherwise
            % we have too many parameters
            error('Wrong number of parameters!');
    end
    
    % open the file
    fid = fopen(strcat(inputPath, inputFile));
    % write the first k lines from the header of the file
    initInfo = cell(1,5);
    for i=1:size(initInfo, 2)
        initInfo{i} = split(fgetl(fid));
    end
    fgetl(fid); % skip one empty line

    ii3 = split(initInfo{3});
    NumFrames = str2double(ii3(3));
    NumMarkers = str2double(ii3(4))*3+2;

    % preallocating memory for faster execution
    m_cols = zeros(NumFrames, NumMarkers);
    reverseStr = '';
    for i=1:NumFrames
        try
            app = fscanf(fid, '%f', NumMarkers);
            m_cols(i, :) = app;

            % information print on the stdOut
            msg = sprintf('Percent done: %3.1f', 100 * i / NumFrames);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        catch ME
            rethrow(ME)
        end
    end
    % close the file
    fclose(fid);
    disp(" ");
end