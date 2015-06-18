clear;
clc;
%% Test maglines

% required IGRF toolbox
% http://www.mathworks.com/matlabcentral/fileexchange/34388-international-geomagnetic-reference-field--igrf--model
%% Read Data
risrName = 'ran120219.004.hdf5';
risrGD = GeoData(@readMadhdf5,risrName,{'nel'});

%% Do work
[lat, lon, alt] = findmagline(risrGD);
risrGD.data.maglines.lat = lat;
risrGD.data.maglines.lon = lon;
risrGD.data.maglines.alt = alt;
