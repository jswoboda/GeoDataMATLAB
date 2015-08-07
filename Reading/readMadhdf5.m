function [ varargout ]=readMadhdf5(filename, paramstr)
%% readMad_hdf5
% by John Swoboda and Anna Stuhlmacher
% madrigal h5 read in function for the python implementation of GeoData for Madrigal Sondrestrom data
% Input
% filename: path to hdf5 file
% paramstr: list of parameters to look at written as strings
% Returns:
% dictionary with keys are the Madrigal parameter string, the value is an array
% rows are unique data locations (data_loc) = (rng, azm, el1)
% columns are unique times
% 

if ~verLessThan('matlab','8.5')
   % use a more efficent, human-readable method
   varargout = readMadhdf5_table(filename,paramstr);
   return
end

%% load data
[all_data,sensorloc,coordnames,radarrng,sensor_data] = loadisrh5(filename);
%% get the data location (range, el1, azm)
rng = all_data.(radarrng);

try
    el = all_data.(angle1);
catch 
    el = NaN(size(rng));
end

try
    azm = all_data.('azm');
catch 
    azm = NaN(size(rng));
end
%% take out nans
notnan = isfinite(rng) & isfinite(el) & isfinite(azm);
[~,basename,ext] = fileparts(sensor_data(5,:));
ngood = sum(notnan);
disp([int2str(ngood), ' good rows found in ', basename,ext ])

all_loc = [rng(notnan), azm(notnan), el(notnan)];
%% create list of unique data location lists
[dataloc,~,icloc] = unique(all_loc,'rows');
times1 = all_data.('ut1_unix')(notnan);
times2 = all_data.('ut2_unix')(notnan);
all_times = [times1,times2];

[uniq_times,~,ictime] = unique(all_times,'rows');

%% initialize and fill data dictionary with parameter arrays
data = struct();
maxcols = size(uniq_times,1);
maxrows = size(dataloc,1);
if ~iscell(paramstr), paramstr={paramstr}; end 
for ip =1:length( paramstr)
    p=paramstr{ip};
    if ~strcmp(p, fieldnames(all_data))
        warning( [ p,  ' is not a valid parameter name.'])
        continue
    end
    tempdata = all_data.(p)(notnan); %list of parameter pulled from all_data
    temparray = zeros([maxrows,maxcols]); %converting the tempdata list into array form
    linind = sub2ind(size(temparray),icloc,ictime);
    temparray(linind)=double(tempdata);
    
    data.(p)=temparray;
end
%% assemble output
varargout = {data,coordnames,dataloc,sensorloc,double(uniq_times)};
end %function

function varargout = readMadhdf5_table(filename,paramstr)
%% using tables (like Pandas DataFrames)
% Michael Hirsch
% 

[all_data,sensorloc,coordnames,radarrng] = loadisrh5(filename);
T = struct2table(all_data);
%% filter out bad observations (missing data)
Tok = all(~ismissing(T(:,{radarrng,'azm','elm'})),2);
T = T(Tok,:);
%% find unique times and beam configurations
uniq_times = unique(T{:,'ut1_unix'},'rows');
% this uniquetol is set to ABSOLUTE not relative tolerance see 
% help uniquetol
dataloc = uniquetol(T{:,{radarrng,'azm','elm'}},1,'ByRows',true,'DataScale',[0.1,0.6,0.5]);

for p = paramstr 
    %note, as in GeoDataPython, we reshape Fortran-order
    data.(p) = reshape(T{:,p}, height(dataloc), length(uniq_times));
end %for
%% assemble output
varargout = {data,coordnames,dataloc,sensorloc,double(uniq_times)};
end %function

function [all_data,sensorloc,coordnames,radarrng,sensor_data] = loadisrh5(fn)
%% open hdf5 file
all_data = h5read(fn,'/Data/Table Layout');
sensor_struct = h5read(fn,'/Metadata/Experiment Parameters');
sensor_data = sensor_struct.value';

sensorname = sensor_data(1,:);

switch lower(sensorname(1:10))
    case 'sondrestro'
        radarrng = 'gdalt';
        disp('Sondrestrom data')
    case 'poker flat'
        radarrng = 'range';
        disp('PFISR data')
    case 'resolute b'
        radarrng = 'range';
        disp('RISR data')
    otherwise
        error('Sensor type not supported by program in this version')   
end
%% get the sensor location (lat, long, rng)
lat = str2double(sensor_data(8,:));
lon = str2double(sensor_data(9,:));
sensor_alt = str2double(sensor_data(10,:));
sensorloc =[lat,lon,sensor_alt];
coordnames = 'Spherical';
end %function