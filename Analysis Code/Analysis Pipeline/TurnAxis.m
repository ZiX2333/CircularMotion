function [TLoc2X, TLoc2Y] =  TurnAxis(theta, CLoc, TLoc1)
% this code is used to turn the cartesian axis by certain angle
% and find the point x y location after turning
% maybe useful in circular motion
% idea coming from https://zhuanlan.zhihu.com/p/58517426; 
% https://github.com/AnChangNice/MTALAB_EX-rotation_2D/blob/master/LocationTranslation.m

% input: 
% theta: turning angle
% center point: CLoc = x and y
% turning point: TLoc1 = x and y


T = [cos(theta), -sin(theta);...
    sin(theta), cos(theta)];

TLoc2 = (T * ([TLoc1(1);TLoc1(2)] - [CLoc(1); CLoc(2)]) + [CLoc(1); CLoc(2)])';

TLoc2X = TLoc2(1);
TLoc2Y = TLoc2(2);
