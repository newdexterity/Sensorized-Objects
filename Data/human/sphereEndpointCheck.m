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
object = 'sphere';
%motion = {'rotx_1','roty_1','rotz_1', 'x_1', 'y_1', 'z_1', 'grpower_1', 'grprecision_1', 'grasptransition_1'};
motion = {'rotx_1','roty_1','rotz_1', 'x_1', 'y_1', 'z_1'};
%%
aperture = 150;
minDist = [280,300, 280, 240, 250, 220, 250];
bestAxis = [5,4,6,1,2,3]; %the best axis to use from the data to find endpoints
startClipping = [280, 600, 150, 100, 340, 400, 1];%array for removing front endpoints of each motion of its best axis 
endClipping = [2000, 800, 1200, 1000, 700, 1500, 1];% array for removing endpoints for this point for each motion of its best axis 
startCycle = [1,1,1,1,1,1,1]; %starting cycles
endCycle = [0,0,0,0,0,0,0]; %cycle points to remove from the end

i = 6;
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
    data = [x,y,z,rx,ry,rz];
    [val,num] = findpeaks(-1*data(:,bestAxis(i)),'MinPeakDistance',minDist(i));

    figure,
    plot(data(:,bestAxis(i)))
    hold on 
    plot(num,-1*val,'.', 'markersize', 20)
    
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
    grid on
    
    %rotational data
    figure, 
    plot3(rx,ry,rz)
    hold on 
    plot3(rotVal(start:bot,1),rotVal(start:bot,2),rotVal(start:bot,3),'.', 'markersize', 20)
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
    