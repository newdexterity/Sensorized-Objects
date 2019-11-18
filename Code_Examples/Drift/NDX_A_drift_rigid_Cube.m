%           Authors: Geng Gao, Gal Gorjup
%           Date  : Nov-17-19
%           The University of Auckland
%      This is a script to visualise and calculate the average drift in
%      translation and rotation of a given object. This script has been
%      made for the NDX-A* manipulating a rigid cube.
%% File Setup
clc;
clear all;
close all;
%% File name setup
hand = 'NDX_A';
surface = 'rigid';
object = 'cube';
motion = {'pitch_1', 'roll_1', 'yaw_1', 'z_1'};
%% importing and windowing data 
%setting up the start and end points to be used inorder to remove outliers
minDist = [500,1000,500,2500];%distance between the peaks 
bestAxis = [1,4,1,3];%the best axis to use from the data to find endpoints
startCycle = [1,1,2,1]; %starting cycles
endCycle = [0,0,0,0]; % number of cycle points to remove from the end

%cycling through each motion file
for i = 1:length(motion)
    %file name being made and read
    file = string(strcat(hand,'_',surface, '_', object, '_', motion(i), '.csv'));
    % importing data
    data = csvread(fullfile('..','..','Data','NDX_A',file));
    
    %settig start of window of the data
    if (string(motion(i)) == "z_2")
        start = 2500;
    else
        start = 500;
    end
    %setting end of window
    len = size(data, 1) - 3500;
    
    %extractig values and converting to metric
    x = 25.4*data(start:len, 2);
    y = 25.4*data(start:len, 3);
    z = 25.4*data(start:len, 4);
    %extractig values and converting to radians
    rz = deg2rad(data(start:len, 5));   %rz
    ry = deg2rad(data(start:len, 6)); %ry
    rx = deg2rad(data(start:len, 7));  %rx
    
    % finding peaks
    data = [x,y,z,rx,ry,rz];
    [val,num] = findpeaks(data(:,bestAxis(i)),'MinPeakDistance',minDist(i));
    for j = 1:(length(num)-endCycle(i))
        for k = 1:3
            transVal(j,k) = data(num(j),k);
            rotVal(j,k) = data(num(j),k+3);
        end
    end
    %plotting data
    %translation/ positional data
    start = startCycle(i);
    bot = length(num)-endCycle(i);
    figure,
    plot3(x,y,z)
    hold on 
    plot3(transVal(start:bot,1),transVal(start:bot,2),transVal(start:bot,3),'.', 'markersize', 20)
    grid on
    %rotational data
    figure, 
    plot3(rx,ry,rz)
    hold on 
    plot3(rotVal(start:bot,1),rotVal(start:bot,2),rotVal(start:bot,3),'.', 'markersize', 20)
    grid on
    
    % translation drift vectors
    for j = start:(bot-1)
        for k = 1:3
            transDriftVector(j-start+1,k) = transVal(j+1,k) - transVal(j,k);
        end
    end
    
    %calculating the mean translation drift vector
    transDrift(i) = norm(mean(transDriftVector));
    
    %computing rotations between subsequent motions
    for j = start:(bot-1)
        q1 = quaternion(eul2quat(rotVal(j,1:3), 'ZYX'));
        q1_inv = conj(q1);
        q2 = quaternion(eul2quat(rotVal(j+1,1:3), 'ZYX'));
        Q(1:4, j) = compact(q2 * q1_inv);
    end
    
    %calculating the mean drift quaternion and angle
    M = Q * Q'
    cov(Q')
    [V,D] = eigs(M);
    q_avg = quaternion(V(:,1)');
    q_avg_check = meanrot(quaternion(Q'));
    rotDrift(i) = dist(quaternion(1,0,0,0), q_avg);
end 

%printing out the data values
disp('mean translational drift (mm)')
disp(transDrift)
disp('mean rotational drift (deg)')
disp(rad2deg(rotDrift))