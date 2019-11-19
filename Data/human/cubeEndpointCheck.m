%           Author: Geng Gao
%           Date  : June-19-19
%           The University of Auckland
%      This is a script to Visualize the Trajectories of inhand
%      manipulation 
%% File Setup
clc;
clear all;
close all;
%%
hand = 'human';
surface = 'rigid';
object = 'cube';
motion = {'rotx_1','roty_1','rotz_1', 'x_1', 'y_1', 'z_1', 'grpower_1', 'grprecision_1', 'grasptransition_1'};
%%
aperture = 150;
minDist = [350,600, 280, 240, 250, 220, 1000, 900, 400];
bestAxis = [5,4,6,1,2,3,3,3,3]; %the best axis to use from the data to find endpoints
startClipping = [200, 200, 1, 200, 280, 180, 1, 1, 1];%array for removing front endpoints of each motion of its best axis 
endClipping = [300, 600, 600, 1, 400, 180, 1000, 1000, 600];% array for removing endpoints for this point for each motion of its best axis 
startCycle = [1,1,1,1,1,1,1,1,1,1]; %starting cycles
endCycle = [0,0,0,0,0,0,0,0,0,0]; %cycle points to remove from the end

i = 9;
file = string(strcat(hand,'_', surface, '_', object, '_', motion(i), '.csv'));

data = csvread(file);
start = startClipping(i);
len = size(data, 1) - endClipping(i);


%extractig values
x = 25.4* data(start:len, 2);
y = 25.4* data(start:len, 3);
z = 25.4* data(start:len, 4);

%     yaw = rad2deg(data(start:len, 7));   %rz
%     pitch = rad2deg(data(start:len, 6)); %ry
%     roll = rad2deg(data(start:len, 5));  %rx
rz = data(start:len, 5);   %rz
ry = data(start:len, 6); %ry
rx = data(start:len, 7);  %rx

% %translations
% x = x - min(x);
% y = y - min(y);
% z = z - min(z);
% % Xmid = (max(x) - min(x))/2;
% % Ymid = (max(y) - min(y))/2;
% % x = x - Xmid;
% % y = y - Ymid;
% %angle
% roll = roll - min(roll);
% pitch = pitch - min(pitch);
% yaw = yaw - min(yaw);
% rollMid = (max(roll) - min(roll))/2;
% pitchMid = (max(pitch) - min(pitch))/2;
% yawMid = (max(yaw) - min(yaw))/2;
% roll = roll - rollMid;
% pitch = pitch - pitchMid;
% yaw = yaw - yawMid;
% rz = yaw;
% ry = pitch;
% rx = roll;

%%
% finding peaks
    if((motion(i) == "grpower_1")||(motion(i) == "grprecision_1"))
        mul = 1;
    else
        mul = -1;
    end
    data = [x,y,z,rx,ry,rz];
    [val,num] = findpeaks(mul*data(:,bestAxis(i)),'MinPeakDistance',minDist(i));

    figure,
    plot(data(:,bestAxis(i)))
    hold on 
    plot(num,mul*val,'x')
    
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
    plot3(transVal(start:bot,1),transVal(start:bot,2),transVal(start:bot,3),'x')
    grid on
    
    %rotational data
    figure, 
    plot3(rx,ry,rz)
    hold on 
    plot3(rotVal(start:bot,1),rotVal(start:bot,2),rotVal(start:bot,3),'x')
%     upperLimit = max([max(rx),max(ry),max(rz)]);
%     lowerLimit = min([min(rx),min(ry),min(rz)]);
%     axis([lowerLimit upperLimit lowerLimit upperLimit lowerLimit upperLimit])
    xlabel('Rx [rad]')
    ylabel('Ry [rad]')
    zlabel('Rz [rad]')
    grid on
    
%     figure,
%     plot(data(:,bestAxis(i)))
%     hold on 
%     plot(num(start:bot),val(start:bot),'x')
    