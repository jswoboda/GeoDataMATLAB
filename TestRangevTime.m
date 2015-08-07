clear 
clc

%% plot range vs time

%% Read data and time register
sonName = '~/data/son130104.001.hdf5';
key = {'nel','dnel'};
sonGD = GeoData(@readMadhdf5,sonName,key);
sonGD.timereduce(1:20);
%% Plotting
el = 70.03;
[im, cb, data, t, rang] = RangevTime(sonGD,'key',key{1},'desiredel',el,'timeunit','minute');


[im2, cb2, data22, t, rang2] = RangevTime(sonGD,'key',key{2},'desiredel',el,'timeunit','minute');