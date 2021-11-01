clear all;
clc

%% USER PARAMETERS
warning('error', 'MATLAB:deblank:NonStringInput');
inputPath = strcat(uigetdir('', 'Select Input Directory'), '\');
[initInfo, NumFrames, NumMarkers, m_cols] = loadDataFromTRC(inputPath);

%% PLOTTING
pltMarkers = input("Plot all Markers: [0=No/1=Yes] ");
pltTrail = input("Plot trail: [0=No/1=Yes] ");
pltVideo = input("Plot video: [0=No/1=Yes] ");

color_l = [1 0 0];
color_r = [0 0 1];
color_t = [0 1 0];
color_p = [0 1 0];

ii4 = string(initInfo{4});

%LJAC and RJAC substituted with LLM and RLM
nameMarkers = ["C7", "T10", "SUP", "STR", "LASIS", "LPSIS", "RPSIS", "RASIS",...
    "LLFE", "LATT", "LMFE", "LGT", "LSPH", "LLM", "LCAL", "LMFH5", "LTT2", "LMFH1",...
    "RLFE", "RATT", "RMFE", "RGT", "RSPH", "RLM", "RCAL", "RMFH5", "RTT2", "RMFH1"];
bodyParts = [
    struct('name', 'torso', 'mks', ["C7", "T10", "SUP", "STR"]),...
    struct('name', 'pelvis', 'mks', ["LASIS", "LPSIS", "RPSIS", "RASIS"]),...
    ...
    struct('name', 'l_knee', 'mks', ["LLFE", "LATT", "LMFE"]),...
    struct('name', 'l_calf', 'mks', ["LLM", "LMFE", "LLFE"]),...
    struct('name', 'l_quad', 'mks', ["LGT", "LASIS", "LATT"]),...
    struct('name', 'l_amstring', 'mks', ["LMFE", "LASIS", "LPSIS"]),...
    ...
    struct('name', 'r_knee', 'mks', ["RLFE", "RATT", "RMFE"]),...
    struct('name', 'r_calf', 'mks', ["RLM", "RMFE", "RLFE"]),...
    struct('name', 'r_quad', 'mks', ["RGT", "RASIS", "RATT"]),...
    struct('name', 'r_amstring', 'mks', ["RMFE", "RASIS", "RPSIS"]),...
    ...
    struct('name', 'l_foot_P', 'mks', ["LSPH", "LLM", "LCAL"]),...
    struct('name', 'l_foot_A', 'mks', ["LMFH5", "LTT2", "LMFH1"]),...
    struct('name', 'l_foot_c1', 'mks', ["LMFH5", "LSPH"]),...
    struct('name', 'l_foot_c2', 'mks', ["LMFH1", "LLM"]),...
    ...
    struct('name', 'r_foot_P', 'mks', ["RSPH", "RLM", "RCAL"]),...
    struct('name', 'r_foot_A', 'mks', ["RMFH5", "RTT2", "RMFH1"]),...
    struct('name', 'r_foot_c1', 'mks', ["RMFH5", "RSPH"]),...
    struct('name', 'r_foot_c2', 'mks', ["RMFH1", "RLM"]),...
    ];

[body, idxMkrs] = findMarkersAndGenerateBody(ii4, nameMarkers, bodyParts);
indeceds = struct2array(idxMkrs);

pX = zeros(NumMarkers, length(indeceds));
pY = zeros(NumMarkers, length(indeceds));
pZ = zeros(NumMarkers, length(indeceds));

framesPerSecond = 120;
r = rateControl(framesPerSecond);
if (pltVideo == true)
    start = 1;
    finish = NumFrames;
else
    frame = input("Insert the frame that you want to plot ( from 1 to " +...
        num2str(NumFrames) +"):");
    start = frame;
    finish = frame;
end

disp("Generating Display")
figure
for i = start:finish
    waitfor(r);
    clf;

    hold on;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    daspect([1 1 1]);
    grid on;
    set(gcf, 'Position', get(0, 'Screensize'));

    set(gca, 'CameraPosition', [10000 10000 0]);
    camroll(90);
    
    drawBody(m_cols(i, :), body, [color_t; color_p; color_l; color_r], 1);

    % full markers plotting
    if (pltMarkers == true)
        for c = 3:3:NumMarkers-2
            X = m_cols(i,c);
            Y = m_cols(i,c+1);
            Z = m_cols(i,c+2);

            plot3(X',Y',Z','o');
        end
    end

    if (pltTrail == true)
        for c = 1:length(indeceds)
            pos = indeceds(c);

            pX(i, c) = m_cols(i, pos);
            pY(i, c) = m_cols(i, pos+1);
            pZ(i, c) = m_cols(i, pos+2);
        end

        plot3(pX',pY',pZ','.', 'color', [0.8 0.75 0.07]);
    end
end


