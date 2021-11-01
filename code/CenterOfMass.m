clear all;
clc

%% USER PARAMETERS
warning('error', 'MATLAB:deblank:NonStringInput');
inputPath = strcat(uigetdir('', 'Select Input Directory'), '\');

%% LOAD DATA
[initInfo, NumFrames, NumMarkers, m_cols] = loadDataFromTRC(inputPath);

%% MASSES
mass_WB = 20; %Whole body mass

mass_P = 3.16042292829541; %pelvis

mass_Fm_R = 2.49608200944611; %femur
mass_Tb_R = 0.99492808072134; %tibia
mass_Ft_R = 0.4204; %talus+calcn+toes

mass_Fm_L = 2.49608200944611;
mass_Tb_L = 0.99492808072134;
mass_Ft_L = 0.4204;

mass_T = 9.0167453842851; %torso

%% MARKER DATA

%legs
LLFE = m_cols(:,30:32);
RLFE = m_cols(:,21:23);

LMFE = m_cols(:,27:29);
RMFE = m_cols(:,18:20);

LKJC = 0.5*(LLFE + LMFE); %Left Knee Joint Center
RKJC = 0.5*(RLFE + RMFE); %Right Knee Joint Center

LLM = m_cols(:,45:47);
RLM = m_cols(:,36:38);

LSPH = m_cols(:,48:50);
RSPH = m_cols(:,39:41);

LAJC = 0.5*(LLM + LSPH); %Left Ankle Joint Center
RAJC = 0.5*(RLM + RSPH); %Right Ankle Joint Center

Tibia_Lx = mean(LKJC(:,1) - LAJC(:,1)); 
Tibia_Ly = mean(LKJC(:,2) - LAJC(:,2)); 
Tibia_Lz = mean(LKJC(:,3) - LAJC(:,3)); 

Tibia_L = sqrt(Tibia_Lx^2 + Tibia_Ly^2 + Tibia_Lz^2); %Scaling Length Left Tibia

Tibia_Rx = mean(RKJC(:,1) - RAJC(:,1)); 
Tibia_Ry = mean(RKJC(:,2) - RAJC(:,2)); 
Tibia_Rz = mean(RKJC(:,3) - RAJC(:,3)); 

Tibia_R = sqrt(Tibia_Rx^2 + Tibia_Ry^2 + Tibia_Rz^2); %Scaling Length Right Tibia

%pelvis 
RASIS = m_cols(:,6:8);
LASIS = m_cols(:,3:5);

midASIS = 0.5*(RASIS + LASIS);

%Pelvis Width = RASIS - LASIS
PW_x = mean(m_cols(:,6)- m_cols(:,3)); 
PW_y = mean(m_cols(:,7)- m_cols(:,4)); 
PW_z = mean(m_cols(:,8)- m_cols(:,5)); 

PW = sqrt(PW_x^2 + PW_y^2 + PW_z^2);
Mid_PW = 0.5*(PW); %Midlength between RASIS to LASIS

%Thigh
LHJC_x = midASIS(:,1)*PW*(0.197);
LHJC_y = midASIS(:,2)*PW*(-0.372);
LHJC_z = midASIS(:,3)*PW*(-0.27);
LHJC = [LHJC_x, LHJC_y, LHJC_z];

RHJC_x = midASIS(:,1)*PW*(0.197);
RHJC_y = midASIS(:,2)*PW*(-0.372);
RHJC_z = midASIS(:,3)*PW*(0.27);
RHJC = [RHJC_x, RHJC_y, RHJC_z];

Femur_Lx = mean(LHJC(:,1) - LKJC(:,1)); 
Femur_Ly = mean(LHJC(:,2) - LKJC(:,2)); 
Femur_Lz = mean(LHJC(:,3) - LKJC(:,3)); 

Femur_L = sqrt(Femur_Lx^2 + Femur_Ly^2 + Femur_Lz^2); %Scaling Length Left Femur

Femur_Rx = mean(RHJC(:,1) - RKJC(:,1)); 
Femur_Ry = mean(RHJC(:,2) - RKJC(:,2)); 
Femur_Rz = mean(RHJC(:,3) - RKJC(:,3)); 

Femur_R = sqrt(Femur_Rx^2 + Femur_Ry^2 + Femur_Rz^2); %Scaling Length Right Femur

%torso
C7 = m_cols(:,90:92);
SUP = m_cols(:,87:89);

Torso_x = mean(C7(:,1) - SUP(:,1)); 
Torso_y = mean(C7(:,2) - SUP(:,2)); 
Torso_z = mean(C7(:,3) - SUP(:,3)); 

Torso = sqrt(Torso_x^2 + Torso_y^2 + Torso_z^2); %Scaling Length Torso

%feet
RCAL = m_cols(:,51:53);
LCAL = m_cols(:,63:65);

RTT2 = m_cols(:,54:56);
LTT2 = m_cols(:,66:68);

Foot_Lx = mean(LCAL(:,1) - LTT2(:,1)); 
Foot_Ly = mean(LCAL(:,2) - LTT2(:,2)); 
Foot_Lz = mean(LCAL(:,3) - LTT2(:,3)); 

Foot_L = sqrt(Foot_Lx^2 + Foot_Ly^2 + Foot_Lz^2); %Scaling Length Left Foot

Foot_Rx = mean(RCAL(:,1) - RTT2(:,1)); 
Foot_Ry = mean(RCAL(:,2) - RTT2(:,2)); 
Foot_Rz = mean(RCAL(:,3) - RTT2(:,3)); 

Foot_R = sqrt(Foot_Rx^2 + Foot_Ry^2 + Foot_Rz^2); %Scaling Length Right Foot


%% CoM FOOT L
CoM_Ft_Lx = ((0.443) * Foot_L) + LCAL(:,1);
CoM_Ft_Ly = ((0.044) * Foot_L) + LCAL(:,2);
CoM_Ft_Lz =((-0.025) * Foot_L) + LCAL(:,3);

%% CoM FOOT R
CoM_Ft_Rx = ((0.443) * Foot_R) + RCAL(:,1);
CoM_Ft_Ry = ((0.044) * Foot_R) + RCAL(:,2);
CoM_Ft_Rz =((-0.025) * Foot_R) + RCAL(:,3);

%% CoM TORSO 
CoM_T_x = ((-0.411) * Torso) + SUP(:,1);
CoM_T_y = ((-1.173) * Torso) + SUP(:,2);
CoM_T_z = ((-0.019) * Torso) + SUP(:,3);

%% CoM PELVIS
CoM_P_x = ((-0.371) * Mid_PW) + midASIS(:,1);
CoM_P_y = ((-0.05) * Mid_PW) + midASIS(:,2);
CoM_P_z = ((0.001) * Mid_PW) + midASIS(:,3); 

%% CoM TIBIA L
CoM_Tb_Lx = ((-0.049) * Tibia_L) + LKJC(:,1);
CoM_Tb_Ly = ((-0.404) * Tibia_L) + LKJC(:,2);
CoM_Tb_Lz = ((0.031) * Tibia_L) + LKJC(:,3);

%% CoM TIBIA R
CoM_Tb_Rx = ((-0.049) * Tibia_R) + RKJC(:,1);
CoM_Tb_Ry = ((-0.404) * Tibia_R) + RKJC(:,2);
CoM_Tb_Rz = ((0.031) * Tibia_R) + RKJC(:,3);

%% CoM FEMUR L
CoM_Fm_Lx = ((-0.077) * Femur_L) + LHJC(:,1);
CoM_Fm_Ly = ((-0.377) * Femur_L) + LHJC(:,2);
CoM_Fm_Lz = ((0.09) * Femur_L) + LHJC(:,3);

%% CoM FEMUR R
CoM_Fm_Rx = ((-0.077) * Femur_R) + RHJC(:,1);
CoM_Fm_Ry = ((-0.377) * Femur_R) + RHJC(:,2);
CoM_Fm_Rz = ((0.09) * Femur_R) + RHJC(:,3);

%% CoM Whole Body
Torso;
Tibia_R;
Femur_R;

CoM_T_x;
CoM_Tb_Rx;
CoM_Fm_Rx;

CoM_x = ((CoM_Ft_Lx * mass_Ft_L)+(CoM_Ft_Rx * mass_Ft_R)+(CoM_T_x * mass_T)+(CoM_P_x * mass_P)+(CoM_Tb_Lx * mass_Tb_L)+(CoM_Tb_Rx * mass_Tb_R)+(CoM_Fm_Lx * mass_Fm_L)+(CoM_Fm_Rx * mass_Fm_R))/mass_WB;
CoM_y = ((CoM_Ft_Ly * mass_Ft_L)+(CoM_Ft_Ry * mass_Ft_R)+(CoM_T_y * mass_T)+(CoM_P_y * mass_P)+(CoM_Tb_Ly * mass_Tb_L)+(CoM_Tb_Ry * mass_Tb_R)+(CoM_Fm_Ly * mass_Fm_L)+(CoM_Fm_Ry * mass_Fm_R))/mass_WB;
CoM_z = ((CoM_Ft_Lz * mass_Ft_L)+(CoM_Ft_Rz * mass_Ft_R)+(CoM_T_z * mass_T)+(CoM_P_z * mass_P)+(CoM_Tb_Lz * mass_Tb_L)+(CoM_Tb_Rz * mass_Tb_R)+(CoM_Fm_Lz * mass_Fm_L)+(CoM_Fm_Rz * mass_Fm_R))/mass_WB;

CoM = [CoM_x CoM_y CoM_z]

