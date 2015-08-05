clear 
clc

%% plot range vs time
%% Create Figure directory
% figdir = 'figures';
% if ~exist(figdir,'dir')
%     mkdir(figdir);
% end

%% Read data and time register
sonName = '~/data/son130104.001.hdf5';
key = 'nel';
sonGD = GeoData(@readMadhdf5,sonName,{key});
sonGD.timereduce(1:100);
%% Plotting
el = 70.02;
[im cb data t rang] = RangevTime(sonGD,'key','nel','desiredel',el,'timeunit','minute');

