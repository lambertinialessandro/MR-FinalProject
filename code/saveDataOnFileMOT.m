function saveDataOnFileMOT(outputPath, initParams, MFM, outputFile)
% Save the data inside the file following the MOT format.

    arguments
        % Directory in which we are going to save the data as MOT file format
        outputPath string {mustBeFolder}
        % initParams, cell contening the first k lines of the file
        initParams cell
        % Matrix containig the data over the time
        MFM (:, :)
        % (OPTIONAL) Name of the file in which we want to write
        outputFile% string {mustBeText} = ""
    end
    
    switch nargin
        case 3
            % if we haven't the file's name, we ask to the user to insert it
            outputFile = input("File Name: ", 's');
        case 4
            % we have all the parameters, fine
        otherwise
            % we don't have enought parameters
            error('Wrong number of parameters!');
    end
    
    % open the file
    fileID = fopen(outputPath+outputFile+'.mot', 'w');
    % write the first k lines for the heater
    for i=1:size(initParams, 2)
        fprintf(fileID,'%s\n', string(initParams{i}));
    end

    ss = size(MFM);
    reverseStr = '';
    for i=1:ss(1)
        % write the line
        fprintf(fileID,'\t%f',MFM(i, :));
        fprintf(fileID,'\n');
        
        % information print on the stdOut
        msg = sprintf('Percent done: %3.1f', 100 * i / ss(1));
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end

    % close the file
    fclose(fileID);
    disp(" ");
end