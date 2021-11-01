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

color_l = [1 0 0];
color_r = [0 0 1];
color_t = [0 1 0];
color_p = [0 1 0];

[body, idxMkrs] = findMarkersAndGenerateBody(ii4, nameMarkers, bodyParts);
disp("Done")

%% NEW KINEMATIC MODEL
disp("KINEMATIC MODEL")
syms q1_1 q1_2 q1_3 q2_1 q2_2 q2_3 q3 real
syms d1 d1_2 a2 a3 real

Q = [q1_1 q1_2 q1_3 q2_1 q2_2 q2_3 q3];
prms = [d1 d1_2 a2 a3];
% number of joints
N=8;

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

DH_Base = [-pi/2     0      0      q1_1;
           -pi/2     0      0      q1_2-pi/2;
           0        d1      0      q1_3];
           % R
DH_rLeg = [-pi/2	d1_2	0       -pi/2;

           -pi/2	0       0       q2_1-pi/2;
           -pi/2	0       0       q2_2-pi/2;
           pi/2     a2      0       q2_3;
           
           -pi/2    a3      0       q3];

DH_lLeg = [-pi/2	-d1_2	0       -pi/2;
    
           -pi/2	0       0       q2_1-pi/2;
           -pi/2	0       0       q2_2-pi/2;
           pi/2     a2      0       q2_3;
           
           -pi/2    a3      0       q3];

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

roTn_s = subs(roTn, prms, [d1_s, d1_2r_s, a2r_s, a3r_s]);
loTn_s = subs(loTn, prms, [d1_s, d1_2l_s, a2l_s, a3l_s]);
disp("Done")

%% NEW DYNAMIC MODEL
disp("DYNAMIC MODEL")
syms q1_1 q1_2 q1_3 q2_1 q2_2 q2_3 q3 real
syms dq1_1 dq1_2 dq1_3 dq2_1 dq2_2 dq2_3 dq3 real

Qq = [q1_1 q1_2 q1_3 q2_1 q2_2 q2_3 q3];
dQq = [dq1_1 dq1_2 dq1_3 dq2_1 dq2_2 dq2_3 dq3];

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

r00 = zeros(3, 1);
I00 = zeros(3, 3);

tic
[M_r, cqdq_r, gq_r] = computeDynamicModel7R(roTn_s, rA, ...
    [0 0 m1 0 0 m2_r m3_r],...
    [r00 r00 r1_1c1 r00 r00 r2_2c2_r r3_3c3_r],...
    [I00 I00 I1c1 I00 I00 I2c2_r I3c3_r],...
    Qq, dQq, [q1_1 q1_2 q1_3 q2_1 q2_2 q2_3 q3]);
toc
tic
[M_l, cqdq_l, gq_l] = computeDynamicModel7R(loTn_s, lA, ...
    [0 0 m1 0 0 m2_l m3_l],...
    [r00 r00 r1_1c1 r00 r00 r2_2c2_l r3_3c3_l],...
    [I00 I00 I1c1 I00 I00 I2c2_l I3c3_l],...
    Qq, dQq, [q1_1 q1_2 q1_3 q2_1 q2_2 q2_3 q3]);
toc

disp("done!")

%%

function [M, cqdq, gq] = computeDynamicModel7R(oTn, A, m, r, I, Q, dQ, Q_s)
    % 0 = revolute, 1 = prismatic
    sigma = [0, 0, 0, 0, 0, 0, 0];
    N = 7;

    R01 = oTn(1:3, 1:3, 1);
    R12 = oTn(1:3, 1:3, 2);
    R23 = oTn(1:3, 1:3, 4);
    R34 = oTn(1:3, 1:3, 5);
    R45 = oTn(1:3, 1:3, 6);
    R56 = oTn(1:3, 1:3, 7);
    R67 = oTn(1:3, 1:3, 8);

    r0_01 = oTn(1:3, 4, 1);
    r1_12 = oTn(1:3, 4, 2);
    r2_23 = oTn(1:3, 4, 4);
    r3_34 = oTn(1:3, 4, 5);
    r4_45 = oTn(1:3, 4, 6);
    r5_56 = oTn(1:3, 4, 7);
    r6_67 = oTn(1:3, 4, 8);
    
    m1 = m(1);
    r1_1c1 = r(:, 1);
    I1c1 = I(:, 1:3);
    
    m2 = m(2);
    r2_2c2 = r(:, 2);
    I2c2 = I(:, 4:6);
    
    m3 = m(3);
    r3_3c3 = r(:, 3);
    I3c3 = I(:, 7:9);
    
    m4 = m(4);
    r4_4c4 = r(:, 4);
    I4c4 = I(:, 10:12);
    
    m5 = m(5);
    r5_5c5 = r(:, 5);
    I5c5 = I(:, 13:15);
    
    m6 = m(6);
    r6_6c6 = r(:, 6);
    I6c6 = I(:, 16:18);
    
    m7 = m(7);
    r7_7c7 = r(:, 7);
    I7c7 = I(:, 19:21);
    
    W00 = [0; 0; 0];
    V00 = [0; 0; 0];
    Z00 = [0; 0; 1];

    W11 = (R01'*(W00+(1-sigma(1))*dQ(1)*Z00));
    V11 = (R01'*V00+sigma(1)*dQ(1)*Z00+cross(W11, R01'*r0_01));
    V1c1 = (V11+cross(W11, r1_1c1));
    T1 = simplify(1/2*m1*norm(V1c1)^2+1/2*W11'*I1c1*W11);

    W22 = (R12'*(W11+(1-sigma(2))*dQ(2)*Z00));
    V22 = (R12'*V11+sigma(2)*dQ(2)*Z00+cross(W22, R12'*r1_12));
    V2c2 = (V22+cross(W22, r2_2c2));
    T2 = simplify(1/2*m2*norm(V2c2)^2+1/2*W22'*I2c2*W22);

    W33 = (R23'*(W22+(1-sigma(3))*dQ(3)*Z00));
    V33 = (R23'*V22+sigma(3)*dQ(3)*Z00+cross(W33, R23'*r2_23));
    V3c3 = (V33+cross(W33, r3_3c3));
    T3 = simplify(1/2*m3*norm(V3c3)^2+1/2*W33'*I3c3*W33);
    
    W44 = (R34'*(W33+(1-sigma(4))*dQ(4)*Z00));
    V44 = (R34'*V33+sigma(4)*dQ(4)*Z00+cross(W44, R34'*r3_34));
    V4c4 = (V44+cross(W44, r4_4c4));
    T4 = simplify(1/2*m4*norm(V4c4)^2+1/2*W44'*I4c4*W44);
    
    W55 = (R45'*(W44+(1-sigma(5))*dQ(5)*Z00));
    V55 = (R45'*V44+sigma(5)*dQ(5)*Z00+cross(W55, R45'*r4_45));
    V5c5 = (V55+cross(W55, r5_5c5));
    T5 = simplify(1/2*m5*norm(V5c5)^2+1/2*W55'*I5c5*W55);

    W66 = (R56'*(W55+(1-sigma(6))*dQ(6)*Z00));
    V66 = (R56'*V55+sigma(6)*dQ(6)*Z00+cross(W66, R56'*r5_56));
    V6c6 = (V66+cross(W66, r6_6c6));
    T6 = simplify(1/2*m6*norm(V6c6)^2+1/2*W66'*I6c6*W66);
    
    W77 = (R67'*(W66+(1-sigma(7))*dQ(7)*Z00));
    V77 = (R67'*V66+sigma(7)*dQ(7)*Z00+cross(W77, R67'*r6_67));
    V7c7 = (V77+cross(W77, r7_7c7));
    T7 = simplify(1/2*m7*norm(V7c7)^2+1/2*W77'*I7c7*W77);
    
    T = T1 + T2 + T3 + T4 + T5 + T6 + T7;
    
    m11 = simplify(diff(T, 2, dQ(1)));
    m22 = simplify(diff(T, 2, dQ(2)));
    m33 = simplify(diff(T, 2, dQ(3)));
    m44 = simplify(diff(T, 2, dQ(4)));
    m55 = simplify(diff(T, 2, dQ(5)));
    m66 = simplify(diff(T, 2, dQ(6)));
    m77 = simplify(diff(T, 2, dQ(7)));

    m12 = simplify(diff(diff(T,dQ(1)),dQ(2)));
    m13 = simplify(diff(diff(T,dQ(1)),dQ(3)));
    m14 = simplify(diff(diff(T,dQ(1)),dQ(4)));
    m15 = simplify(diff(diff(T,dQ(1)),dQ(5)));
    m16 = simplify(diff(diff(T,dQ(1)),dQ(6)));
    m17 = simplify(diff(diff(T,dQ(1)),dQ(7)));
    
    m23 = simplify(diff(diff(T,dQ(2)),dQ(3)));
    m24 = simplify(diff(diff(T,dQ(2)),dQ(4)));
    m25 = simplify(diff(diff(T,dQ(2)),dQ(5)));
    m26 = simplify(diff(diff(T,dQ(2)),dQ(6)));
    m27 = simplify(diff(diff(T,dQ(2)),dQ(7)));
    
    m34 = simplify(diff(diff(T,dQ(3)),dQ(4)));
    m35 = simplify(diff(diff(T,dQ(3)),dQ(5)));
    m36 = simplify(diff(diff(T,dQ(3)),dQ(6)));
    m37 = simplify(diff(diff(T,dQ(3)),dQ(7)));
    
    m45 = simplify(diff(diff(T,dQ(4)),dQ(5)));
    m46 = simplify(diff(diff(T,dQ(4)),dQ(6)));
    m47 = simplify(diff(diff(T,dQ(4)),dQ(7)));
    
    m56 = simplify(diff(diff(T,dQ(5)),dQ(6)));
    m57 = simplify(diff(diff(T,dQ(5)),dQ(7)));
    
    m67 = simplify(diff(diff(T,dQ(6)),dQ(7)));

    M = [m11 m12 m13 m14 m15 m16 m17;
         m12 m22 m23 m24 m25 m26 m27;
         m13 m23 m33 m34 m35 m36 m37;
         m14 m24 m34 m44 m45 m46 m47;
         m15 m25 m35 m45 m55 m56 m57;
         m16 m26 m36 m46 m56 m66 m67;
         m17 m27 m37 m47 m57 m67 m77];

     % C(q, dq)
    M1 = M(:, 1);
    M2 = M(:, 2);
    M3 = M(:, 3);
    M4 = M(:, 4);
    M5 = M(:, 5);
    M6 = M(:, 6);
    M7 = M(:, 7);

    j1 = jacobian(M1, Q);
    C1q = 1/2*(j1+j1'-diff(M, Q(1)));
    j2 = jacobian(M2, Q);
    C2q = 1/2*(j2+j2'-diff(M, Q(2)));
    j3 = jacobian(M3, Q);
    C3q = 1/2*(j3+j3'-diff(M, Q(3)));
    j4 = jacobian(M4, Q);
    C4q = 1/2*(j4+j4'-diff(M, Q(4)));
    j5 = jacobian(M5, Q);
    C5q = 1/2*(j5+j5'-diff(M, Q(5)));
    j6 = jacobian(M6, Q);
    C6q = 1/2*(j6+j6'-diff(M, Q(6)));
    j7 = jacobian(M7, Q);
    C7q = 1/2*(j7+j7'-diff(M, Q(7)));
    
    dQ_T = dQ';
    c1qdq = simplify(dQ_T'*C1q*dQ_T);
    c2qdq = simplify(dQ_T'*C2q*dQ_T);
    c3qdq = simplify(dQ_T'*C3q*dQ_T);
    c4qdq = simplify(dQ_T'*C4q*dQ_T);
    c5qdq = simplify(dQ_T'*C5q*dQ_T);
    c6qdq = simplify(dQ_T'*C6q*dQ_T);
    c7qdq = simplify(dQ_T'*C7q*dQ_T);

    cqdq = [c1qdq;
            c2qdq;
            c3qdq;
            c4qdq;
            c5qdq;
            c6qdq;
            c7qdq];
    offset = sym(zeros(3, N));

    % COM offsets
    offset(:, 1) = r1_1c1;
    offset(:, 2) = r2_2c2;
    offset(:, 3) = r3_3c3;
    offset(:, 4) = r4_4c4;
    offset(:, 5) = r5_5c5;
    offset(:, 6) = r6_6c6;
    offset(:, 7) = r7_7c7;
    
    % Compute roc
    roc = sym(zeros(3, N));
    for i=1:N-1
        roc(:, i) = compute_roc(oTn, A, offset, i);
    end

    % Compute Gravity Term
    g = [0; 0; -9.81];
    gq = simplify(compute_gravity(Q_s, m, roc, g));
end





