clear all;
clc

%% LOAD DATA
warning('error', 'MATLAB:deblank:NonStringInput');
inputPath = strcat(uigetdir('', 'Select Input Directory'), '\');

% Sirine | inputFile = 'FILTERED_statique.trc'
% Lina   | inputFile = 'FILTERED_marche 2.trc'

disp("READING DATA FROM FILE")
[initInfo, NumFrames, NumMarkers, m_cols] = loadDataFromTRC(inputPath);
disp("Done")

disp("CREATING BODY")
ii4 = string(initInfo{4});
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

color_l = [1 0 0];
color_r = [0 0 1];
color_t = [0 1 0];
color_p = [0 1 0];

[body, idxMkrs] = findMarkersAndGenerateBody(ii4, nameMarkers, bodyParts);
disp("Done")

%%
i = 1;

% MID
rPSIS = getMarkerValsI(m_cols, idxMkrs.RPSIS, i);
lPSIS = getMarkerValsI(m_cols, idxMkrs.LPSIS, i);
midPSIS = (rPSIS+lPSIS)/2;

rASIS = getMarkerValsI(m_cols, idxMkrs.RASIS, i);
lASIS = getMarkerValsI(m_cols, idxMkrs.LASIS, i);
midASIS = (rASIS+lASIS)/2;

rGT = getMarkerValsI(m_cols, idxMkrs.RGT, i);
lGT = getMarkerValsI(m_cols, idxMkrs.LGT, i);
midGT = (rGT+lGT)/2;

% R
rLFE = getMarkerValsI(m_cols, idxMkrs.RLFE, i);
rMFE = getMarkerValsI(m_cols, idxMkrs.RMFE, i);
rKJC = (rLFE+rMFE)/2;

rLM = getMarkerValsI(m_cols, idxMkrs.RLM, i);
rSPH = getMarkerValsI(m_cols, idxMkrs.RSPH, i);
rAJC = (rLM+rSPH)/2;

rTT2 = getMarkerValsI(m_cols, idxMkrs.RTT2, i);

% L
lLFE = getMarkerValsI(m_cols, idxMkrs.LLFE, i);
lMFE = getMarkerValsI(m_cols, idxMkrs.LMFE, i);
lKJC = (lLFE+lMFE)/2;

lLM = getMarkerValsI(m_cols, idxMkrs.LLM, i);
lSPH = getMarkerValsI(m_cols, idxMkrs.LSPH, i);
lAJC = (lLM+lSPH)/2;

lTT2 = getMarkerValsI(m_cols, idxMkrs.LTT2, i);
mp = (midPSIS+midASIS)/2;

% Sirine | inputFile = 'FILTERED_statique.trc'
% Lina   | inputFile = 'FILTERED_marche 2.trc'

                                      % Siline   | Lina
d1_s = abs(mp(2)-midGT(2)) %            100.6042 | 110.8154 ;

d1_2r_s = abs(midASIS(1) - rKJC(1)) %   101.7985 | 86.4980 ;

a2r_s = norm(rGT - rKJC) %              303.2734 | 286.0500 ;
a3r_s = norm(rKJC - rAJC) %             324.8977 | 289.4691 ;

d1_2l_s = abs(midASIS(1) - lKJC(1)) %   99.6884  | 68.3947 ;
a2l_s = norm(lGT - lKJC) %              307.4519 | 280.2513 ;
a3l_s = norm(lKJC - lAJC) %             326.4379 | 281.9904 ;


