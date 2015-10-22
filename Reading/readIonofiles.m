function [ varargout ]=readIonofiles(ionofn)
%% readIonofiles
% by John Swoboda 
% Reads in Mahali iono files with TEC
% Input
% filename: path to hdf5 file

% Returns:
% The variables for the GeoData structure. The locations will be the pierce
% points of the TEC. The coordinate system will be in WGS84. Also the time
% vector will be given a 15 second time window. Also this will be set up
% like satilite data where the time and location vector will be the same
% length.
% 


%iono file format
%           1) time (as float day of year 0.0 - 366.0)
%           2) year
%           3) rec. latitude
%           4) rec. longitude
%           5) line-of-sight tec (TECu)
%           6) error in line-of-sight tec (TECu)
%           7) vertical tec (TECu)
%           8) azimuth to satellite
%           9) elevation to satellite
%           10) mapping function (line of sight / vertical)
%           11) pierce point latitude (350 km)
%           12) pierce point longitude (350 km)
%           13) satellite number (1-32)
%           14) site (4 char)
%           15) recBias (TECu)
%           16) recBiasErr(TECu) 


%% Open and read in from the text file
fid = fopen(ionofn,'r');
%[time2,year2,lat2,long2,tec2,tecerr2,vtec2,az2,el2,map2,pplat2,pplong2,satid2,site2,recbias2,recbiaserr2]=...
    data = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %s %s %s');
fclose(fid);
%% Get in GeoData format
doy = data{1};
year=data{2};
if all(year==year(1))
    unixyear = datestr2unix(['1-01-',num2str(year(1))]);
    uttime = unixyear+24*3600*[doy,doy+1];
else
    for k = 1:length(year)
        yearstr = {['1-01-',num2str(data{2}(:))]};
    end
    unixyear = datestr2unix(yearstr);
    uttime = unixyear+24*3600*[doy,doy+1];
end
reclat = data{3};
reclong = data{4};
TEC = data{5};

nTEC = data{6};

vTEC = data{7};
az2sat = data{8};
el2sat = data{9};
mapfunc = data{10};

piercelat = data{11};
piercelong = data{12};
satnum= data{13};
site = {14};
recBias = data{15};
nrecBias = data{16};

data = struct('TEC',{TEC},'nTEC',{nTEC},'vTEC',{vTEC},'recBias',{recBias},'nrecBias',{nrecBias});
coordnames = 'WGS84';
sensorloc = [nan,nan,nan];
dataloc = [piercelat,piercelong,350e3*ones(size(piercelat))];
varargout = {data,coordnames,dataloc,sensorloc,uttime};