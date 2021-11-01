clear all;
clc

%% PROCESSING
warning('error', 'MATLAB:deblank:NonStringInput');
inputPath = strcat(uigetdir('', 'Select Input Directory'), '\');
outputPath = strcat(uigetdir(inputPath, 'Select Output Directory'), '\');

isReadAllFiles = input('Process all the files in the directory? [0=No/1=Yes] ');
isAlreadyConverted = input('Are all the files already converted in .trc/.mot? [0=No/1=Yes] ');
disp(" ");

% COLLECTING FILES
if (isReadAllFiles == true)
    inputFiles = [dir(strcat(inputPath, '\*.c3d')).name];
else
    [inputFiles, inputPath] = uigetfile(strcat(inputPath, "\*.c3d"), 'MultiSelect', 'on');
end
inputFiles = string(split(inputFiles, '.c3d'));
inputFiles(cellfun('isempty',inputFiles)) = [];

disp("Choose:"+newline+"0) process TRC and MOT"+newline+"1) process only TRC"+newline+"2) process only MOT")
operationCase = input("");

%% PROCESS

% FILTERING PARAMETERS
grade = 4; % grade
fc = 10; % cutoff frequency
% TRC
trc_fsm = 200; % sampling frequency
[trc_b, trc_a] = butter(grade, fc/(trc_fsm/2));
% MOT
mot_fsm = 2000; % sampling frequency
[mot_b, mot_a] = butter(grade, fc/(mot_fsm/2));
% END


dim = length(inputFiles);
for i = 1:dim
    disp("<= Working on file: ["+inputFiles(i)+"] "+num2str(i)+"/"+dim+" =>"+newline);
    
    % CONVERTING FILE IN .trc AND .mot
    if (isAlreadyConverted == false)
        disp('    ### CONVERTING FILE IN .trc AND .mot');
        tic;
        c3dExport(inputPath, inputFiles(i)+'.c3d');
        disp('terminated in: '+string(toc)+' s'+newline);
    end
    
    switch operationCase
        case 1
            % WORK ON TRC
            processTRC(inputPath, outputPath, inputFiles, i, trc_b, trc_a);
        case 2
            % WORK ON MOT
            processMOT(inputPath, outputPath, inputFiles, i, mot_b, mot_a);
        otherwise
            % WORK ON TRC AND MOT
            processTRC(inputPath, outputPath, inputFiles, i, trc_b, trc_a);
            processMOT(inputPath, outputPath, inputFiles, i, mot_b, mot_a);
    end
end
disp("All done!");

%% FUNCTION

function processTRC(inputPath, outputPath, inputFiles, i, trc_b, trc_a)
    % READ DATA
    disp('    ### READING DATA FROM FILE .trc');
    tic;
    [initInfo, NumFrames, NumMarkers, m_cols] = loadDataFromTRC(inputPath, inputFiles(i)+'.trc');
    MC = m_cols;
    disp('terminated in: '+string(toc)+' s'+newline);

    % GAP FILLING
    disp('    ### FILLING GAPS');
    tic;
    gf = GapFiller(str2num(cell2mat(initInfo{3}(3))), false);
    MC = gf.fill(MC);
    disp('terminated in: '+string(toc)+' s'+newline);

    % SAVE FILLED DATA ON FILE
    disp('    ### SAVING DATA IN FILE FILLED_'+inputFiles(i)+'.trc');
    tic;
    saveDataOnFileTRC(outputPath, initInfo, MC, 'FILLED_'+inputFiles(i));
    disp('terminated in: '+string(toc)+' s'+newline);

    % FILTERING
    disp('    ### FILTERING');
    tic;
    
    for j=3:NumMarkers-1
        MC(:, j) = filtfilt(trc_b, trc_a, MC(:, j));
    end
    disp('terminated in: '+string(toc)+' s'+newline);

    % SAVE FINAL DATA ON FILE
    disp('    ### SAVING DATA IN FILE FILTERED_'+inputFiles(i)+'.trc');
    tic;
    saveDataOnFileTRC(outputPath, initInfo, MC, 'FILTERED_'+inputFiles(i));
    disp('terminated in: '+string(toc)+' s'+newline);
end

function processMOT(inputPath, outputPath, inputFiles, i, mot_b, mot_a)
    % READ DATA
    disp('    ### READING DATA FROM FILE .mot');
    tic;
    [initParams, NumRows, NumCols, m_fm] = loadDataFromMOT(inputPath, inputFiles(i)+'.mot');
    MFM = m_fm;
    disp('terminated in: '+string(toc)+' s'+newline);

    % GAP FILLING
    disp('    ### FILLING GAPS');
    tic;
    MFM(isnan(MFM))=0;
    disp('terminated in: '+string(toc)+' s'+newline);

    % SAVE FILLED DATA ON FILE
    disp('    ### SAVING DATA IN FILE FILLED_'+inputFiles(i)+'.mot');
    tic;
    saveDataOnFileMOT(outputPath, initParams, MFM, 'FILLED_'+inputFiles(i));
    disp('terminated in: '+string(toc)+' s'+newline);

    % FILTERING
    disp('    ### FILTERING');
    tic;
    for j=3:NumCols-1
        MFM(:, j) = filtfilt(mot_b, mot_a, MFM(:, j));
    end
    disp('terminated in: '+string(toc)+' s'+newline);

    % SAVE FINAL DATA ON FILE
    disp('    ### SAVING DATA IN FILE FILTERED_'+inputFiles(i)+'.mot');
    tic;
    saveDataOnFileMOT(outputPath, initParams, MFM, 'FILTERED_'+inputFiles(i));
    disp('terminated in: '+string(toc)+' s'+newline);
end


