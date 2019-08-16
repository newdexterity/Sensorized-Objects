%           Author: Geng Gao
%           Date  : June-19-19
%           The University of Auckland
%      This is a script to visualise and calculate the average repeatability in
%      grasping and releaseing of a given object with power and precision grasping. This script has been
%      made for the NDX-T42* manipulating a rigid cube.
%% File Setup
clc;
clear all;
close all;
%% File name setup
hand = 'T42';
surface = 'rigid';
object = 'cube';
motion = {'power_GR_1', 'precision_GR_1'};
%% importing and windowing data 
%setting up the start and end points to be used inorder to remove outliers
minDist = [1000,1000];%distance between the peaks 
bestAxis = [3,3]; %the best axis to use from the data to find endpoints
startCycle = [3,1]; %starting cycle
endCycle = [0,0]; %cycle points to remove from the end

%cycling through power and precision grasp 
for i = 1:length(motion)
    %file name being made and read
    file = string(strcat(hand,'_',surface, '_', object, '_', motion(i), '.csv'));
    data = csvread(fullfile('..','..','Data','T42',file));
    %settig start of window of the data
    %setting end of window
    start = 4000;
    len = size(data, 1)-4000;
    %extractig values
    x = 25.4*data(start:len, 2);
    y = 25.4*data(start:len, 4);
    z = -25.4*data(start:len, 3);

    yaw = data(start:len, 7);   %rz
    pitch = data(start:len, 5); %ry
    roll = data(start:len, 6);  %rx

    % removing angle offset for range of motion
    %centering coordinate frame of the data 
    %finding minimum and offsetting the data
    %translations
    x = x - min(x);
    y = y - min(y);
    z = z - min(z);

    %angle
    roll = roll - min(roll);
    pitch = pitch - min(pitch);
    yaw = yaw - min(yaw);
    rollMid = (max(roll) - min(roll))/2;
    pitchMid = (max(pitch) - min(pitch))/2;
    yawMid = (max(yaw) - min(yaw))/2;
    roll = roll - rollMid;
    pitch = pitch - pitchMid;
    yaw = yaw - yawMid;
    rz = yaw;
    ry = pitch;
    rx = roll;
    
    % finding peaks
    data = [x,y,z,rx,ry,rz];
    [val,num] = findpeaks(-1*data(:,bestAxis(i)),'MinPeakDistance',minDist(i));
    val = -1*val;
    transVal = zeros((length(num)-endCycle(i)),3);
    rotVal = zeros((length(num)-endCycle(i)),3);
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
    xlabel('x [mm]')
    ylabel('y [mm]')
    zlabel('z [mm]')
    hold on 
    plot3(transVal(start:bot,1),transVal(start:bot,2),transVal(start:bot,3),'.', 'markersize', 20)
    upperLimit = max([max(x),max(y),max(z)]);
    lowerLimit = min([min(x),min(y),min(z)]);
    lower = lowerLimit - 0.5*upperLimit;
    upper = lowerLimit + 0.5*upperLimit;
    axis([lower upper lower upper lowerLimit upperLimit])
    grid on
    
    %rotational data
    figure, 
    plot3(rx,ry,rz)
    hold on 
    plot3(rotVal(start:bot,1),rotVal(start:bot,2),rotVal(start:bot,3),'.', 'markersize', 20)
    upperLimit = max([max(rx),max(ry),max(rz)]);
    lowerLimit = min([min(rx),min(ry),min(rz)]);
    axis([lowerLimit upperLimit lowerLimit upperLimit lowerLimit upperLimit])
    xlabel('Rx [rad]')
    ylabel('Ry [rad]')
    zlabel('Rz [rad]')
    grid on
    
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
    
    %covariance 
    transSD(i) = (max(eig(cov(transNoDriftVal))))^0.5
    rotSD(i) = (max(eig(cov(rotNoDriftVal))))^0.5
end 