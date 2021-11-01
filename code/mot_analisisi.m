clear all;
clc

%% LOAD DATA
warning('error', 'MATLAB:deblank:NonStringInput');
inputPath = strcat(uigetdir('', 'Select Input Directory'), '\');

tic
[initParams, NumRows, NumCols, m_fm] = loadDataFromMOT(inputPath);
toc

%% TRASFORM DATA
disp("Trasforming data");
dim = (size(m_fm, 2)-1)/9;
steps = cell(dim);
time = m_fm(:, 1);
for i=1:dim
    displace = (i-1)*9;
    force = m_fm(:, (2+displace):(4+displace));
    point = m_fm(:, (5+displace):(7+displace));
    moment = m_fm(:, (8+displace):(10+displace));
    steps{i} = motData(time, force, point, moment);
end
disp("Work done");

% one step plotted
stp = input("Insert the step ( from 1 to " + num2str(dim)...
    + " ) that you want to plot: ");
steps{3}.pltAll()



