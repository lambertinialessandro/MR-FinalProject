function [] = saveDataOnFileTRC(outputPath, initInfo, MC, outputFile)
% Save the data inside the file following the TRC format.
    arguments
            % Directory in which we are going to save the data as TRC file format
            outputPath string {mustBeFolder}
            % initInfo, cell contening the first k lines of the file
            initInfo cell
            % Matrix containig the data of the markers over the time
            MC (:, :)
            % (OPTIONAL) Name of the file in which we want to write
            outputFile string {mustBeText} = ""
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
    fileID = fopen(outputPath+outputFile+'.trc', 'W');
    % write the first line
    fprintf(fileID,'PathFileType\t4\t(X/Y/Z)\t%s\n', outputPath+outputFile+'.trc');
    % write the next lines for the heater
    for i=2:size(initInfo, 2)
        fprintf(fileID,'%s\t', string(initInfo{i}(:)));
        fprintf(fileID,'\n');
    end
    fprintf(fileID,'\n');
    
    ss = size(MC);
    reverseStr = '';
    for i=1:ss(1)
        % write the line
        fprintf(fileID,'%d',MC(i, 1));
        fprintf(fileID,'\t%f',MC(i, 2:end));
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