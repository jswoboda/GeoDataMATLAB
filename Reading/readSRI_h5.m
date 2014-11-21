function [ varargout ] = readSRI_h5( varargin )
%% Description: read_SRI
% By Andrew Lee
% This function will read the SRI format data into the Geodata format structure.

%% Variable Arguments Out
varnames = {'data','coordnames','dataloc','sensorloc','times'};
varargout = cell(1,length(varnames));
%% Variable Arguements In
filename = varargin{1};
parameter = varargin{2};
timebound = varargin{3};

%% Load SRI H5 file

datadict = {'Ne', 'dNe', 'Vi', 'dVi', 'Ti', 'dTi', 'Te', 'dTe';
    '/FittedParams/Ne', '/FittedParams/dNe', '/FittedParams/Fits', '/FittedParams/Errors', '/FittedParams/Fits',...
    '/FittedParams/Errors', '/FittedParams/Fits', '/FittedParams/Errors'};

% Define coordinate type
coordnames = 'Spherical';
varargout{2} = coordnames;

%% Load times
loadtimes = hdf5read(filename,'/Time/UnixTime');

%Time Conversion from Unix to MATLAB time
l=size(loadtimes);
mtime = zeros(l(1),l(2));
for i1 = 1:l(1),
    for i2 = 1:l(2),
    mtime(i1,i2) = datenum([1970 1 1 0 0 double(loadtimes(i1,i2))]);
    end
end

if timebound ~= 0
    T1 = find(mtime(1,:) >= timebound(1), 1, 'first');
    T2 = find(mtime(2,:) >= timebound(2), 1, 'first');
end

% Select and load desired times
times = mtime(:,T1:T2);
varargout{5} = times;

%% Load sensor locations
lat = hdf5read(filename,'/Site/Latitude');
lon = hdf5read(filename,'/Site/Longitude');
alt = hdf5read(filename,'/Site/Altitude');
sensorloc = [lat lon alt];
varargout{4} = sensorloc;
%% Load Data Locations
range = hdf5read(filename,'/FittedParams/Range')/1000; %in km
angles = hdf5read(filename,'BeamCodes');
angles = angles(2:3,:);
nrange = length(range(:,1));
repangles = repmat(angles,1,nrange);
allaz = repangles(1:2:end);
allel = repangles(2:2:end);
tempdataloc = [reshape(range.',1,[]);allaz;allel];
dataloc = tempdataloc.';
varargout{3} = dataloc;

%% Load Data
paramindex = find(strcmp(datadict(1,:),parameter)==1);
if paramindex == 0
     error('provide correct parameter (e.g. ''Ne'')')
else
    tempData = hdf5read(filename,char(datadict(2,paramindex)));
end

if (paramindex == 3 || paramindex == 4) %For Vi or dVi
    tempData = tempData(4,1,:,:,:);
elseif (paramindex == 5 || paramindex == 6) %For Ti or dTi
    tempData = tempData(2,1,:,:,:);
elseif (paramindex == 7 || paramindex == 8) %For Te or dTe
    tempData = tempData(2,end,:,:,:);
end

data = reshape(permute(tempData,[2 1 3]),length(varargout{3}),length(tempData(1,1,:)));
varargout{1} = data;