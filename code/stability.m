clear all;
clc

%% LOAD DATA
warning('error', 'MATLAB:deblank:NonStringInput');
inputPath = strcat(uigetdir('', 'Select Input Directory'), '\');
[inputFile, inputPath] = uigetfile(strcat(inputPath, "*.trc"));
inputFile = split(inputFile, '.');
inputFile = char(inputFile(1, :));

disp("READING DATA FROM FILE")
tic
[initInfo, NumFrames, NumMarkers, m_cols] = loadDataFromTRC(inputPath, inputFile+".trc");
toc

tic
[initParams, NumRows, NumCols, m_fm] = loadDataFromMOT(inputPath, inputFile+".mot");
toc
disp("Done")

% TRASFORM DATA
disp("Trasforming data");
dim = (size(m_fm, 2)-1)/9;
steps = cell(dim, 1);
time = m_fm(:, 1);
for j=1:dim
    displace = (j-1)*9;
    force = m_fm(:, (2+displace):(4+displace));
    point = m_fm(:, (5+displace):(7+displace));
    moment = m_fm(:, (8+displace):(10+displace));
    steps{j} = motData(time, force, point, moment);
end
disp("Work done");

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

[body, idxMkrs] = findMarkersAndGenerateBody(ii4, nameMarkers, bodyParts);
disp("Done")

%% BUILD ROBOT
disp("KINEMATIC MODEL")
syms q1 q2r q2l q3r q3l q4r q4l real
syms d1 d1_2 a2 a3 a4 real

Q = [q1 q2r q2l q3r q3l];
prms = [d1 d1_2 a2 a3];
% number of joints
N=4;

disp("Insert:"+newline+"0)Sirine model"+newline+"1)Lina model")
modelParmas = input("");

switch modelParmas
    case 0
        d1_s = 100.6042;

        d1_2r_s = 101.7985;
        a2r_s = 303.2734;
        a3r_s = 324.8977;

        d1_2l_s = 99.6884;
        a2l_s = 307.4519;
        a3l_s = 326.4379;
    case 1
        d1_s = 110.8154;

        d1_2r_s = 86.4980;
        a2r_s = 245.3837;
        a3r_s = 289.4691;

        d1_2l_s = 68.3947;
        a2l_s = 280.2513;
        a3l_s = 281.9904;
        
    otherwise
        error('Wrong input!');
end

% DH table of parameters
DH_Base = [pi/2     0   d1	q1];

DH_rLeg = [0        0	-d1_2  0;
           pi       a2	0	q2r;
           0        a3	0	q3r];

DH_lLeg = [0        0	d1_2	0;
           pi       a2	0	q2l;
           0        a3	0	q3l];

syms alpha a d theta real
% Build the general Denavit-Hartenberg trasformation matrix %
TDH = [ cos(theta) -sin(theta)*cos(alpha)  sin(theta)*sin(alpha) a*cos(theta);
        sin(theta)  cos(theta)*cos(alpha) -cos(theta)*sin(alpha) a*sin(theta);
          0             sin(alpha)             cos(alpha)            d;
          0               0                      0                   1];

% Build transformation matrices for each link %
rA = sym(zeros(4, 4, N));
lA = sym(zeros(4, 4, N));
for i = 1:size(DH_Base, 1)
    DHalpha = DH_Base(i,1);
    DHa = DH_Base(i,2);
    DHd = DH_Base(i,3);
    DHtheta = DH_Base(i,4);
    rA(:, :, i) = subs(TDH, [alpha a d theta], [DHalpha DHa DHd DHtheta]);
    lA(:, :, i) = subs(TDH, [alpha a d theta], [DHalpha DHa DHd DHtheta]);
end
for j = 1:size(DH_rLeg, 1)
    DHalpha = DH_rLeg(j,1);
    DHa = DH_rLeg(j,2);
    DHd = DH_rLeg(j,3);
    DHtheta = DH_rLeg(j,4);
    rA(:, :, i+j) = subs(TDH, [alpha a d theta], [DHalpha DHa DHd DHtheta]);
end
for j = 1:size(DH_lLeg, 1)
    DHalpha = DH_lLeg(j,1);
    DHa = DH_lLeg(j,2);
    DHd = DH_lLeg(j,3);
    DHtheta = DH_lLeg(j,4);
    lA(:, :, i+j) = subs(TDH, [alpha a d theta], [DHalpha DHa DHd DHtheta]);
end

roTn = sym(zeros(4, 4, N));
roTn(:, :, 1) = simplify(eye(4)*rA(:, :, 1));
loTn = sym(zeros(4, 4, N));
loTn(:, :, 1) = simplify(eye(4)*lA(:, :, 1));
for i=2:N
    roTn(:, :, i) = roTn(:, :, i-1)*rA(:, :, i);
    roTn(:, :, i) = simplify(roTn(:, :, i));
    loTn(:, :, i) = loTn(:, :, i-1)*lA(:, :, i);
    loTn(:, :, i) = simplify(loTn(:, :, i));
end

roTn_s = subs(roTn, prms, [d1_s, d1_2r_s, a2r_s, a3r_s]);%, a4r_s]);
loTn_s = subs(loTn, prms, [d1_s, d1_2l_s, a2l_s, a3l_s]);%, a4l_s]);
disp("Done")

%%
disp("DYNAMIC MODEL")
syms u1 u2 u3 u4 t real
syms q1 q2 q3 dq1 dq2 dq3 ddq1 ddq2 ddq3 real

Qq = [q1 q2 q3];
dQq = [dq1 dq2 dq3];

% Moving Frames Method
switch modelParmas
    case 0
        m1 = 3.16042292829541;
        r1_1c1 = [-38.9535 0 0]';
        I1c1 = [14216.9     0       0;
                0           14216.9	0;
                0           0       3892.67];
        
        m2_r = 2.49608200944611;
        r2_2c2_r = [0 -133.551 0]';
        I2c2_r = [22176.5	0       0;
                  0         5813.25	0;
                  0         0       23385.5];
        
        m3_r = 0.99492808072134;
        r3_3c3_r = [0 -151.816 0]';
        I3c3_r = [7347.6	0       0;
                  0         646.798	0;
                  0         0       7347.6];
              
        m2_l = 2.49608200944611;
        r2_2c2_l = [0 -135.109 0]';
        I2c2_l = [22696.7	0       0;
                  0         5949.63	0;
                  0         0       23934.1];
        
        m3_l = 0.99492808072134;
        r3_3c3_l = [0 -146.5 0]';
        I3c3_l = [6984.5	0       0;
                  0         699.851	0;
                  0         0       6984.59];
    case 1
        m1 = 2.781172176899961;
        r1_1c1 = [-37.4462 0 0]';
        I1c1 = [12510.9     0       0;
                0           12510.9	0;
                0           0       3425.55];
        
        m2_r = 2.1965521683125773;
        r2_2c2_r = [0 -126.695 0]';
        I2c2_r = [17563     0       0;
                  0         4603.9	0;
                  0         0       18520.6];
        
        m3_r = 0.8755367110347793;
        r3_3c3_r = [0 -132.354 0]';
        I3c3_r = [6465.89	0       0;
                  0         569.182	0;
                  0         0       6465.89];
        
        m2_l = 2.1965521683125773;
        r2_2c2_l = [0 -123.26 0]';
        I2c2_l = [16623.4	0       0;
                  0         4357.61	0;
                  0         0       17529.7];
        
        m3_l = 0.8755367110347793;
        r3_3c3_l = [0 -132.21 0]';
        I3c3_l = [6146.44	0       0;
                  0         615.869	0;
                  0         0       6146.44];
    otherwise
        error('Wrong input!');
end

tic
[M_r, cqdq_r, gq_r] = computeDynamicModel3R(roTn_s, rA, ...
    [m1, m2_r, m3_r], [r1_1c1, r2_2c2_r, r3_3c3_r], [I1c1, I2c2_r, I3c3_r],...
    Qq, dQq, [q1 q2r q3r]);
toc
tic
[M_l, cqdq_l, gq_l] = computeDynamicModel3R(loTn_s, lA, ...
    [m1, m2_l, m3_l], [r1_1c1, r2_2c2_l, r3_3c3_l], [I1c1, I2c2_l, I3c3_l],...
    Qq, dQq, [q1 q2l q3l]);
toc

disp("done!")

%% EVALUATING Dcom
Dcom = zeros(size(steps, 1), NumRows);

disp("EVALUATING Dcom")
for i=[1, 2, 3, 4, 5] % modify me
    F = steps{i}.getForce();
    P = steps{i}.getPointOfPressure();
    M = steps{i}.getMoment();
    
    assert (all(size(F) == size(M)) && all(size(M) == size(P)))
    for j=1:NumRows-1

        rPSIS = getMarkerValsI(m_cols, idxMkrs.RPSIS, floor(j/10)+1);
        lPSIS = getMarkerValsI(m_cols, idxMkrs.LPSIS, floor(j/10)+1);
        midPSIS = (rPSIS+lPSIS)/2;

        rASIS = getMarkerValsI(m_cols, idxMkrs.RASIS, floor(j/10)+1);
        lASIS = getMarkerValsI(m_cols, idxMkrs.LASIS, floor(j/10)+1);
        midASIS = (rASIS+lASIS)/2;
        
        rCAL = getMarkerValsI(m_cols, idxMkrs.RCAL, floor(j/10)+1);
        rMFH1 = getMarkerValsI(m_cols, idxMkrs.RMFH1, floor(j/10)+1);
        rMFH5 = getMarkerValsI(m_cols, idxMkrs.RMFH5, floor(j/10)+1);
        rTT2 = getMarkerValsI(m_cols, idxMkrs.RTT2, floor(j/10)+1);

        mp = (midPSIS+midASIS)/2;
        midPointP = (rCAL+rMFH1+rMFH5+rTT2)/4;

        Fj = F(j, :);
        Mj = M(j, :);
        Pj = P(j, :);
        Pj_com = mp-(midPointP+Pj);
        Mcom = Mj + cross(Fj, Pj_com);

        if norm(Fj)^2 == 0
            Dcom(i, j) = 0;
        else
            Dcom(i, j) = norm(cross(Fj, Mcom)) / norm(Fj)^2;
        end
    end
end
disp("Done")

%% FILTERING Dcom
disp("FILTERING Dcom")

% FILTERING PARAMETERS
grade = 4; % grade
fc = 1; % cutoff frequency
fsm = 200; % sampling frequency
[b,a] = butter(grade, fc/(fsm/2));
% END

fDcom = zeros(size(Dcom));

fDcom(1, :) = filtfilt(b, a, Dcom(1, :));
fDcom(2, :) = filtfilt(b, a, Dcom(2, :));
fDcom(3, :) = filtfilt(b, a, Dcom(3, :));
fDcom(4, :) = filtfilt(b, a, Dcom(4, :));
fDcom(5, :) = filtfilt(b, a, Dcom(5, :));
ffDcom = fDcom(1, :)+fDcom(2, :)+fDcom(3, :)+fDcom(4, :)+fDcom(5, :);

stepIdx = 5;
F = steps{stepIdx}.getForce();
disp("Done")

%% PLOT Dcom
disp("Plotting Dcom")
switch modelParmas
    case 0
        MPP = 40;
        minDist = 0.2;
    case 1
        MPP = 10;
        minDist = 0.2;
end

plotGaitCycle(idxMkrs, m_cols,...
    [m_cols(:, idxMkrs.RTT2+1), m_cols(:, idxMkrs.LTT2+1)]...
    , m_cols(:, 2), MPP, minDist)
plotGaitCycle(idxMkrs, m_cols, [ffDcom'], time, MPP, minDist)
disp("Done")




