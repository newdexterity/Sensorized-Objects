%           Authors: Geng Gao, Gal Gorjup
%           Date  : Nov-17-19
%           The University of Auckland
%      This is a script to visualise and calculate the average drift in
%      translation and rotation of a given object. This script has been
%      made for the T42 manipulating a rigid cube. 
%% File Setup
clc;
clear all;
close all;
%% File name setup
hand = 'T42';
object = 'cube';
motion = {'roll_1', 'x_1', 'z_1'};
%% importing and windowing data 
%setting up the start and end points to be used inorder to remove outliers
minDist = [400,800,300];%distance between the peaks 
bestAxis = [3,1,1]; %the best axis to use from the data to find endpoints
startCycle = [1,1,1]; %starting cycles
endCycle = [1,0,0]; %cycle points to remove from the end

%cycling through each motion file
for i = 1:length(motion)
    % creating file name to be called
    file = string(strcat(hand, '_', object, '_', motion(i), '.csv'));
    % importing data
    data = csvread(fullfile('..','..','Data','T42',file), 1, 1);
    
    %setting up start and end points for clipping data
    if (string(motion(i)) == "x_1")
        start = 4000;
        len = size(data, 1);
    else
        start = 800;
        len = size(data, 1) - 800;
    end
    
    %extractig values and converting to metric
    x = 25.4*data(start:len, 2);
    y = 25.4*data(start:len, 3);
    z = 25.4*data(start:len, 4);
    %extractig values
    rz = data(start:len, 7);   %rz
    ry = data(start:len, 6); %ry
    rx = data(start:len, 5);  %rx
    
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
        q1 = quaternion(eul2quat(rotVal(j,1:3), 'XYZ'));
        q1_inv = conj(q1);
        q2 = quaternion(eul2quat(rotVal(j+1,1:3), 'XYZ'));
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