clear all;
clc

%% LOAD DATA
warning('error', 'MATLAB:deblank:NonStringInput');
inputPath = strcat(uigetdir('', 'Select Input Directory'), '\');

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
disp("DISPLAY MODEL")
framesPerSecond = 240;
r = rateControl(framesPerSecond);

pltVideo = input("Plot video: [0=No/1=Yes] ");
if (pltVideo == true)
    frame = 0;
    start = 1;
    finish = NumFrames;
    pltF = true;
else
    frame = input("Insert the frame that you want to plot ( from 1 to " +...
        num2str(NumFrames) +"):");
    start = frame;
    finish = frame;
    pltF = false;
end

color_l = [1 0 0];
color_r = [0 0 1];
color_t = [0 1 0];
color_p = [0 1 0];

rPoss = zeros(4, N+1);
rPoss(:, 1) = [0 0 0 1];
lPoss = zeros(4, N+1);
lPoss(:, 1) = [0 0 0 1];

n_rcal_y = normalize(m_cols(:, idxMkrs.RCAL+1), 'norm', 1);
n_rcal_y = n_rcal_y - min(n_rcal_y);
n_rmfh1_y = normalize(m_cols(:, idxMkrs.RMFH1+1), 'norm', 1);
n_rmfh1_y = n_rmfh1_y - min(n_rmfh1_y);
n_rtt2_y = normalize(m_cols(:, idxMkrs.RTT2+1), 'norm', 1);
n_rtt2_y = n_rtt2_y - min(n_rtt2_y);
n_rmfh5_y = normalize(m_cols(:, idxMkrs.RMFH5+1), 'norm', 1);
n_rmfh5_y = n_rmfh5_y - min(n_rmfh5_y);

n_lcal_y = normalize(m_cols(:, idxMkrs.LCAL+1), 'norm', 1);
n_lcal_y = n_lcal_y - min(n_lcal_y);
n_lmfh1_y = normalize(m_cols(:, idxMkrs.LMFH1+1), 'norm', 1);
n_lmfh1_y = n_lmfh1_y - min(n_lmfh1_y);
n_ltt2_y = normalize(m_cols(:, idxMkrs.LTT2+1), 'norm', 1);
n_ltt2_y = n_ltt2_y - min(n_ltt2_y);
n_lmfh5_y = normalize(m_cols(:, idxMkrs.LMFH5+1), 'norm', 1);
n_lmfh5_y = n_lmfh5_y - min(n_lmfh5_y);

hr1 = mean([n_rcal_y', n_rmfh1_y', n_rtt2_y', n_rmfh5_y']);
hr2 = mean([max(n_rcal_y)/8, max(n_rmfh1_y)/8, max(n_rtt2_y)/8, max(n_rmfh5_y)/8]);
hr = (hr1+hr2)/2;

hl1 = mean([n_lcal_y', n_lmfh1_y', n_ltt2_y', n_lmfh5_y']);
hl2 = mean([max(n_lcal_y)/8, max(n_lmfh1_y)/8, max(n_ltt2_y)/8, max(n_lmfh5_y)/8]);
hl = (hl1+hl2)/2;

Qss = zeros(5, NumFrames);

figure
for i = 1:NumFrames
    if pltF || i == frame
        rPoss = zeros(4, N+1);
        rPoss(:, 1) = [0 0 0 1];
        lPoss = zeros(4, N+1);
        lPoss(:, 1) = [0 0 0 1];

        waitfor(r);
        clf

        hold on;
        xlabel('X'); ylabel('Y'); zlabel('Z');
        daspect([1 1 1]);
        grid on;
        set(gcf, 'Position', get(0, 'Screensize'));
        set(gca, 'CameraPosition', [10000 10000 0]);
        camroll(90);

        drawBody(m_cols(i, :), body, [color_t; color_p; color_l; color_r], 1);
    end

    %upadte markers values
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
    
    % Inverse kinematics
    mp = (midPSIS+midASIS)/2;
    T = [0	1   0   mp(1);
         0	0   -1   mp(2);
         1	0   0   mp(3);
         0	0	0	1];
    
    m = (lGT(3)-rGT(3))/(lGT(1)-rGT(1));
    q1_s = -atan(m);
    
    p3rh = T^-1*[rKJC'; 1];
    c2r = p3rh(1)/a2r_s;
    s2r = (p3rh(3) - d1_s)/a2r_s;
    q2r_s = atan2(s2r,c2r);

    p4rh = T^-1*[rAJC'; 1];
    c3r = (p4rh(1) - a2r_s*cos(q2r_s))/a3r_s;
    s3r = (p4rh(3) - d1_s - a2r_s*sin(q2r_s))/a3r_s;
    q3r_s = q2r_s - atan2(s3r,c3r);

    p3lh = T^-1*[lKJC'; 1];
    c2l = p3lh(1)/a2l_s;
    s2l = (p3lh(3) - d1_s)/a2l_s;
    q2l_s = atan2(s2l,c2l);

    p4lh = T^-1*[lAJC'; 1];
    c3l = (p4lh(1) - a2l_s*cos(q2l_s))/a3l_s;
    s3l = (p4lh(3) - d1_s - a2l_s*sin(q2l_s))/a3l_s;
    q3l_s = q2l_s - atan2(s3l,c3l);
    
    Qss(:, i) = [q1_s; q2r_s; q3r_s; q2l_s; q3l_s];

    if pltF || i == frame
        roTn_sQ = double(subs(roTn_s, Q, [q1_s q2r_s q2l_s q3r_s q3l_s]));
        loTn_sQ = double(subs(loTn_s, Q, [q1_s q2r_s q2l_s q3r_s q3l_s]));

        % positions joints
        assert (size(rPoss, 2) == size(lPoss, 2))
        for j=2:size(rPoss, 2)
            rPoss(:, j) = double(roTn_sQ(:, :, j-1)*rPoss(:, 1));
            lPoss(:, j) = double(loTn_sQ(:, :, j-1)*lPoss(:, 1));
        end
        for j=1:size(rPoss, 2)
            rPoss(:, j) = T*rPoss(:, j);
            lPoss(:, j) = T*lPoss(:, j);
        end

        % draw robot
        lineW = 2;
        plot3(rPoss(1, :), rPoss(2, :), rPoss(3, :), '-', 'color', [0 0 0],'LineWidth',lineW)
        plot3(rPoss(1, [1, 3:end]), rPoss(2, [1, 3:end]), rPoss(3, [1, 3:end]),...
            'o', 'color', [1 0 0],'LineWidth',lineW)

        plot3(lPoss(1, :), lPoss(2, :), lPoss(3, :), '-', 'color', [0 0 0],'LineWidth',lineW)
        plot3(lPoss(1, [1, 3:end]), lPoss(2, [1, 3:end]), lPoss(3, [1, 3:end]),...
            'o', 'color', [1 0 0],'LineWidth',lineW)

        % center of mass
        midPelvis = [lASIS + rASIS + lPSIS + rPSIS + lGT + rGT]/6;
        distCoM = [-0.0389535 0 0];
        Com = midPelvis + distCoM;
        plot3(Com(1), Com(2), Com(3), 'o', 'color', [0 1 0],'LineWidth',3)

        % points of contact
        rCAL = getMarkerValsI(m_cols, idxMkrs.RCAL, i) - [0 15 0];
        rMFH1 = getMarkerValsI(m_cols, idxMkrs.RMFH1, i);
        rMFH5 = getMarkerValsI(m_cols, idxMkrs.RMFH5, i);

        lCAL = getMarkerValsI(m_cols, idxMkrs.LCAL, i) - [0 18 0];
        lMFH1 = getMarkerValsI(m_cols, idxMkrs.LMFH1, i);
        lMFH5 = getMarkerValsI(m_cols, idxMkrs.LMFH5, i);

        app_pcR = [n_rcal_y(i); n_rmfh1_y(i); n_rtt2_y(i); n_rmfh5_y(i)]';
        app_point_pcR = [rCAL; rMFH1; rTT2; rMFH5]';
        app_pcL = [n_lcal_y(i); n_lmfh1_y(i); n_ltt2_y(i); n_lmfh5_y(i)]';
        app_point_pcL = [lCAL; lMFH1; lTT2; lMFH5]';

        assert (size(app_pcR, 2) == size(app_pcL, 2))
        pcR = zeros(3, size(app_pcR, 2)+1);
        pcL = zeros(3, size(app_pcL, 2)+1);

        k = 1; w = 1;
        for j=1:size(app_pcR, 2)
            if app_pcR(j) <= hr
                pcR(:, k) = app_point_pcR(:, j);
                k = k+1;
            end
            if app_pcL(j) <= hl
                pcL(:, w) = app_point_pcL(:, j);
                w = w+1;
            end
        end

        if k > 1
            pcR(:, k) = pcR(:, 1);
            fill3(pcR(1, 1:k), pcR(2, 1:k), pcR(3, 1:k), [1.0 1.0 0.4])
        end
        if w > 1
            pcL(:, w) = pcL(:, 1);
            fill3(pcL(1, 1:w), pcL(2, 1:w), pcL(3, 1:w), [1.0 1.0 0.4])
        end

        if (k > 1 && w  > 1)
            pcTot = [pcR(1, 1:k-1) pcL(1, 1:w-1);
                pcR(2, 1:k-1) pcL(2, 1:w-1);
                pcR(3, 1:k-1) pcL(3, 1:w-1)]';
            k = boundary(pcTot, 0.1);
            trisurf(k,pcTot(:,1),pcTot(:,2),pcTot(:,3),'Facecolor','red','FaceAlpha',0.1)
        end
    end
end
disp("done!")

%%
time = m_cols(:, 2);

% [q1_s; q2r_s; q3r_s; q2l_s; q3l_s]
Qss_deg = zeros(4, NumFrames);
Qss_deg(1, :) = rad2deg(Qss(1, :));
Qss_deg(2, :) = rad2deg(Qss(2, :));
Qss_deg(3, :) = rad2deg(Qss(3, :));
Qss_deg(4, :) = rad2deg(Qss(4, :));
Qss_deg(5, :) = rad2deg(Qss(5, :));

figure
subplot(2, 1, 1)
hold on
yline(hr,'--y','Threshold', 'color', [0.929 0.694 0.125]);
plot(time, n_rcal_y, 'color', [0 0 0])
plot(time, n_rmfh1_y, 'color', [1 0 0])
plot(time, n_rtt2_y, 'color', [0 1 0])
plot(time, n_rmfh5_y, 'color', [0 0 1])
legend('RCAL', 'RMFH1', 'RTT2', 'RMFH5')
xlabel('Time(s)');
ylabel('Markers(mm)');
hold off

subplot(2, 1, 2)
hold on
plot(time, Qss_deg(1, :), 'color', [1 0 0])
plot(time, Qss_deg(2, :), 'color', [0 1 0])
plot(time, Qss_deg(3, :), 'color', [0 0 1])
legend('q1', 'q2', 'q3')
xlabel('Time(s)');
ylabel('Q(degres)');
hold off

figure
subplot(2, 1, 1)
hold on
yline(hl,'--y','Threshold', 'color', [0.929 0.694 0.125]);
plot(time, n_lcal_y, 'color', [0 0 0])
plot(time, n_lmfh1_y, 'color', [1 0 0])
plot(time, n_ltt2_y, 'color', [0 1 0])
plot(time, n_lmfh5_y, 'color', [0 0 1])
legend('RCAL', 'RMFH1', 'RTT2', 'RMFH5')
xlabel('Time(s)');
ylabel('Markers(mm)');
hold off


subplot(2, 1, 2)
hold on
plot(time, Qss_deg(1, :), 'color', [1 0 0])
plot(time, Qss_deg(4, :), 'color', [0 1 0])
plot(time, Qss_deg(5, :), 'color', [0 0 1])
legend('q1', 'q2', 'q3')
xlabel('Time(s)');
ylabel('Q(degres)');
hold off

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


