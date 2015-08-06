clear 
clc

%% plot range vs time

%% Read data and time register
sonName = '~/data/son130104.001.hdf5';
key = 'nel';
sonGD = GeoData(@readMadhdf5,sonName,{key});
sonGD.timereduce(1:50);
%% Plotting
el = 70.03;
[im cb data t rang] = RangevTime(sonGD,'key','nel','desiredel',el,'timeunit','minute');

