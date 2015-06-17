clear 
clc

%% plot range vs time
%% Create Figure directory
% figdir = 'figures';
% if ~exist(figdir,'dir')
%     mkdir(figdir);
% end

%% Read data and time register
risrName = 'ran120219.004.hdf5';
key = 'nel';
risrGD = GeoData(@readMadhdf5,risrName,{key});

%% Plotting
beamnumber = 1;
[im cb] = RangevTime(risrGD,'key','nel','beam',beamnumber,'timeunit','hour');

