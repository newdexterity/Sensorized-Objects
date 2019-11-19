%           Authors: Geng Gao, Gal Gorjup
%           Date  : Nov-17-19
%           The University of Auckland
%      This is a script to visualise and calculate the average drift in
%      translation and rotation of a given object. This script has been
%      made for the NDX-A* manipulating a rigid sphere.
%% File Setup
clc
clear all;
close all;
%% File name setup
hand = 'human';
surface = 'rigid';
object = 'sphere';
motion = {'rotx_1','roty_1','rotz_1', 'x_1', 'y_1', 'z_1'};
%% importing and windowing data 
%setting up the start and end points to be used inorder to remove outliers
minDist = [280,300, 280, 240, 250, 220, 250];
bestAxis = [5,4,6,1,2,3]; %the best axis to use from the data to find endpoints
startClipping = [280, 600, 150, 100, 340, 400, 1];%array for removing front endpoints of each motion of its best axis 
endClipping = [2000, 800, 1200, 1000, 700, 1500, 1];% array for removing endpoints for this point for each motion of its best axis 
startCycle = [1,1,1,1,1,1,1]; %starting cycles
endCycle = [0,0,0,0,0,0,0]; %cycle points to remove from the end

%cycling through each motion file
for i = 1:length(motion)
    %file name being made and read
    file = string(strcat(hand,'_', surface, '_', object, '_', motion(i), '.csv'));
    % importing data
    data = csvread(fullfile('..','..','Data','human',file));
    
    %settig start of window of the data
    start = startClipping(i);
    %setting end of window
    len = size(data, 1) - endClipping(i);
    
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
    [val,num] = findpeaks(-1*data(:,bestAxis(i)),'MinPeakDistance',minDist(i));
    for j = 1:(length(num))
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
    M = Q * Q';
    [V,D] = eigs(M);
    q_avg = quaternion(V(:,1)');
    rotDrift(i) = dist(quaternion(1,0,0,0), q_avg);
end 

%printing out the data values
disp('mean translational drift (mm)')
disp(transDrift)
disp('mean rotational drift (deg)')
disp(rad2deg(rotDrift))