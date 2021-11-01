function [initParams, NumRows, NumCols, m_fm] = loadDataFromMOT(inputPath, inputFile)
% Load the data from the file following the MOT format.
%
% OUTPUT
%
% initParams: Cell contening the first k lines of the file
% NumRows: Number of the rows inside the body of the file
% NumCols: Number of the columns inside the body of the file
% m_fm: Matrix containig the data of the markers over the time

    arguments
        % Directory in which we are going to load the data as MOT file format
        inputPath string {mustBeFolder}
        % (OPTIONAL) Name of the file in which we want to write
        inputFile string {mustBeText} = ""
    end

    switch nargin
        case 0
            % if we haven't the file's name, we ask to the user to select it
            [inputFile, inputPath] = uigetfile("*.mot")
        case 1
            % if we haven't the file's name, we ask to the user to select it
            [inputFile, inputPath] = uigetfile(strcat(inputPath, "*.mot"));
        case 2
            % we have all the parameters, fine
        otherwise
            % we have too many parameters
            error('Wrong number of parameters!');
    end
    
    % open the file
    fid = fopen(strcat(inputPath, inputFile));
    % write the first k lines from the header of the file
    initParams = cell(1,7);
    for i=1:size(initParams, 2)
        initParams{i} = fgetl(fid);
    end
    
    NumCols = split(initParams{1}, "=");
    NumCols = str2double(NumCols(2));
    NumRows = split(initParams{2}, "=");
    NumRows = str2double(NumRows(2));
    
    % preallocating memory for faster execution
    m_fm = zeros(NumRows, NumCols);
    reverseStr = '';
    for i=1:NumRows
        m_fm(i, :) = fscanf(fid, '%f', NumCols);
        
        % information print on the stdOut
        msg = sprintf('Percent done: %3.1f', 100 * i / NumRows);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    % close the file
    fclose(fid);
    disp(" ");
end