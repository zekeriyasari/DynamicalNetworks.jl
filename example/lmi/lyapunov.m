% This file is an example of LMI solving in MATLAB 

clc
clear 
close all 

A = [0 1; -2 -3];

% Define unknown matrix 
setlmis([])
P = lmivar(1, [size(A, 1) 1]);

% Define LMI 
lmiterm([1 1 1 P], 1, A, 's');
lmiterm([1 1 2 0], 1); 
lmiterm([1 2 2 P], -1, 1);

sys = getlmis;

[tmin, Psol] = feasp(sys);
P = dec2mat(sys, Psol, P);
disp(P)

