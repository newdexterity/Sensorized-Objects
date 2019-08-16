%           Author: Geng Gao
%           Date  : June-19-19
%           The University of Auckland
%      This is a script to visualise and calculate the average repeatability in
%      translation and rotation of a given object manipulation motion. This script has been
%      made for the NDX-A* manipulating a rigid cylinder.
%% File Setup
clc;
clear all;
close all;
%% File name setup
hand = 'NDX_A';
surface = 'rigid';
object = 'cylinder';
motion = {'fixed_pitch_1', 'roll_1', 'z_1'};%
%% importing and windowing data 
%setting up the start and end points to be used inorder to remove outliers
minDist = [1000,1600,3000];%distance between the peaks 
bestAxis = [1,2,2];%the best axis to use from the data to find endpoint
startCycle = [2,2,2];%starting cycles
endCycle = [0,0,0];% number of cycle points to remove from the end

%cycling through each motion file
for i = 1:length(motion)
    %file name being made and read
    file = string(strcat(hand,'_',surface, '_', object, '_', motion(i), '.csv'));
    % importing data
    data = csvread(fullfile('..','..','Data','NDX_A',file));
    %settig start of window of the data
    start = 500;
    %setting end of window
    len = size(data, 1) - 3500;
    
    %extractig values and converting to metric
    x = 25.4*data(start:len, 2);
    y = 25.4*data(start:len, 3);
    z = 25.4*data(start:len, 4);
    yaw = data(start:len, 5);   %rz
    pitch = data(start:len, 6); %ry
    roll = data(start:len, 7);  %rx
    
    % removing angle offset for range of motion
    %centering coordinate frame of the data 
    %finding minimum and offsetting the data
    roll = roll - min(roll);
    pitch = pitch - min(pitch);
    yaw = yaw - min(yaw);
    x = x - min(x);
    y = y - min(y);
    z = z - min(z);
    %centering the data
    rollMid = (max(roll) - min(roll))/2;
    pitchMid = (max(pitch) - min(pitch))/2;
    yawMid = (max(yaw) - min(yaw))/2;
    rx = roll - rollMid;
    ry = pitch - pitchMid;
    rz = yaw - yawMid;
    Xmid = (max(x) - min(x))/2;
    Ymid = (max(y) - min(y))/2;
    Zmid = (max(z) - min(z))/2;
    x = x - Xmid;
    y = y - Ymid;
    z = z - Zmid;
    
    % finding peaks
    data = [x,y,z,rx,ry,rz];
    [val,num] = findpeaks(data(:,bestAxis(i)),'MinPeakDistance',minDist(i));
    transVal = zeros((length(num)-endCycle(i)),3);
    rotVal = zeros((length(num)-endCycle(i)),3);
    for j = 1:(length(num)-endCycle(i))
        for k = 1:3
            transVal(j,k) = data(num(j),k);
            rotVal(j,k) = data(num(j),k+3);
        end
    end
    
    % getting mean drift vector 
    start = startCycle(i);
    bot = length(num)-endCycle(i);
    transDriftVector = zeros(length(start:bot-1),3);
    rotDriftVector = zeros(length(start:bot-1),3);
    for j = start:(bot-1)
        for k = 1:3
            transDriftVector(j-start+1,k) = transVal(j+1,k) - transVal(j,k);
            rotDriftVector(j-start+1,k) = rotVal(j+1,k) - rotVal(j,k);
        end
    end
    meanTransDrift = mean(transDriftVector);
    meanRotDrift = mean(rotDriftVector);
    
    %removing drift from points
    transNoDriftVal = zeros(length(start:bot),3);
    rotNoDriftVal = zeros(length(start:bot),3);
    for j = start:(bot)
        for k = 1:3
            transNoDriftVal(j-start+1,k) = transVal(j,k)- meanTransDrift(k) * (j-start);
            rotNoDriftVal(j-start+1,k) = rotVal(j,k)- meanRotDrift(k) * (j-start);
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
    rotSD(i) = (max(eig(cov(rotNoDriftVal))))^0.5
end 