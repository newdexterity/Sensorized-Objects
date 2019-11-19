%           Authors: Geng Gao, Gal Gorjup
%           Date  : Nov-17-19
%           The University of Auckland
%      This is a script to visualise and calculate the average repeatability in
%      translation and rotation of a given object manipulation motion. This script has been
%      made for the NDX-A* manipulating a rigid cube.
%% File Setup
clc;
clear all;
close all;
%% File name setup
hand = 'human';
surface = 'rigid';
object = 'cube';
motion = {'rotx_1','roty_1','rotz_1', 'x_1', 'y_1', 'z_1', 'grpower_1', 'grprecision_1', 'grasptransition_1'};
%% importing and windowing data 
%setting up the start and end points to be used inorder to remove outliers
minDist = [350,600, 280, 240, 250, 220, 1000, 900, 400];
bestAxis = [5,4,6,1,2,3,3,3,3]; %the best axis to use from the data to find endpoints
startClipping = [200, 200, 1, 200, 280, 180, 1, 1, 1];%array for removing front endpoints of each motion of its best axis 
endClipping = [300, 600, 600, 1, 400, 180, 1000, 1000, 600];% array for removing endpoints for this point for each motion of its best axis 
startCycle = [1,1,1,1,1,1,1,1,1,1]; %starting cycles
endCycle = [0,0,0,0,0,0,0,0,0,0]; %cycle points to remove from the end

%cycling through each motion file
for i = 1:length(motion)
    %file name being made and read
    file = string(strcat(hand,'_',surface, '_', object, '_', motion(i), '.csv'));
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
    if((motion(i) == "grpower_1")||(motion(i) == "grprecision_1"))
        mul = 1;
    else
        mul = -1;
    end
    data = [x,y,z,rx,ry,rz];
    [val,num] = findpeaks(mul*data(:,bestAxis(i)),'MinPeakDistance',minDist(i));
    transVal = zeros((length(num)-endCycle(i)),3);
    rotVal = zeros((length(num)-endCycle(i)),3);
    for j = 1:(length(num)-endCycle(i))
        for k = 1:3
            transVal(j,k) = data(num(j),k);
            rotVal(j,k) = data(num(j),k+3);
        end
    end
    
    % translation repeatability
    
    % average drift vector
    start = startCycle(i);
    bot = length(num)-endCycle(i);
    transDriftVector = zeros(length(start:bot-1),3);
    for j = start:(bot-1)
        for k = 1:3
            transDriftVector(j-start+1,k) = transVal(j+1,k) - transVal(j,k);
        end
    end
    meanTransDrift = mean(transDriftVector);
    
    % removing drift from points
    transNoDriftVal = zeros(length(start:bot),3);
    for j = start:(bot)
        for k = 1:3
            transNoDriftVal(j-start+1,k) = transVal(j,k)- meanTransDrift(k) * (j-start);
        end
    end
    
    %plotting end point distribution with object trajectory
    figure,
    plot3(x,y,z)
    hold on 
    len = start:bot;
    plot3(transVal(len,1), transVal(len,2), transVal(len,3),'.', 'markersize', 20)
    
    %covariance calculation for repeatability 
    transSD(i) = (max(eig(cov(transNoDriftVal))))^0.5
    
    
    % rotation repeatability
    
    % average drift quaternion
    for j = start:(bot-1)
        q1 = quaternion(eul2quat(rotVal(j,1:3), 'ZYX'));
        q1_inv = conj(q1);
        q2 = quaternion(eul2quat(rotVal(j+1,1:3), 'ZYX'));
        Q(1:4, j) = compact(q2 * q1_inv);
    end
    M = Q * Q';
    [V,D] = eigs(M);
    q_avg = quaternion(V(:,1)');
    
    % uncorrected orientations for reference
    q_raw = zeros(length(start:bot), 4);
    for j = 1:length(start:bot)
        q_raw(j,:) = eul2quat(rotVal(j,1:3), 'ZYX');
    end
    
    % remove angular drift from points
    q_corrected = zeros(length(start:bot), 4);
    q_corrected(1,:) = eul2quat(rotVal(start,1:3), 'ZYX');
    for j = 2:length(start:bot)
        q_prev = quaternion(q_corrected(j-1,:));
        q_curr = quaternion(eul2quat(rotVal(j,1:3), 'ZYX'));
        q = (conj(q_avg) * (q_curr * conj(q_prev))) * q_prev;
        q_corrected(j,:) = compact(q);
    end
    
    % compute mean orientation from the corrected angles
    q_corrected  = quaternion(q_corrected);
    %q_corrected_mean = meanrot(q_corrected);
    Q = compact(q_corrected)';
    M = Q * Q';
    cov(Q');
    [V,D] = eigs(M);
    q_corrected_mean = quaternion(V(:,1)');
    
    % compute sample variance
    sig2 = 0;
    for j = 1:length(start:bot)
        sig2 = sig2 + dist(q_corrected(j), q_corrected_mean)^2;
    end
    sig2 = sig2 / (length(start:bot) - 1);
    
    % compute standard deviation
    sig = sqrt(sig2);
    rotSD(i) = rad2deg(sig)
    
end 