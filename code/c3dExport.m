function c3dExport(inputPath, inputFile, outputPath, outputFile)
% Convert a *.c3d file into *.trc and *.mot file.

    arguments
        % Directory in which we are going to load the data as c3d file format
        inputPath string {mustBeFolder}
        % (OPTIONAL) Name of the file we want to read from
        inputFile string {mustBeText} = ""
        % (OPTIONAL) Directory in which we are going to save the data as TRC and MOT files format
        outputPath string {mustBeFolder} = ".\"
        % (OPTIONAL) Name of the file in which we want to write
        outputFile string {mustBeText} = ""
    end

    switch nargin
        case 1
            % if we haven't the file's name, we ask to the user to select it
            [inputFile, inputPath] = uigetfile(strcat(inputPath, "*.c3d"));
            
            % we set the output path as the input path
            outputPath = inputPath;
            % we call the output file as the input file
            outputFile = split(inputFile, '.');
            outputFile = outputFile(1);
        
        case 2
            % we set the output path as the input path
            outputPath = inputPath;
            % we call the output file as the input file
            outputFile = split(inputFile, '.');
            outputFile = outputFile(1);
        case 3
            % we call the output file as the input file
            outputFile = split(inputFile, '.');
            outputFile = outputFile(1);
        case 4
            % we have all the parameters, fine
        otherwise
            % we don't have enought parameters
            error('Wrong number of parameters!');
    end
    
    % Load OpenSim libs
    import org.opensim.modeling.*

    disp('generating files from: ' + inputFile);
    % Construct an opensimC3D object with input c3d path
    c3d = osimC3D(strcat(inputPath, inputFile),1);

    % Rotate the data 
    c3d.rotateData('x',-90)

    % Convert COP (mm to m) and Moments (Nmm to Nm)
    c3d.convertMillimeters2Meters();

    % Write the marker and force data to file
    c3d.writeTRC(char(outputPath + outputFile + '.trc'));
    c3d.writeMOT(char(outputPath + outputFile + ".mot"));
    
    disp('saved: ' + outputFile + '.trc' + ' and ' + outputFile + ".mot");
end


