function [varargout] = readomti(filelist,latfile,lonfile,height,omtishape)
% readomti.m
% By John Swoboda

varnames = {'data','coordnames','dataloc','sensorloc','times'};
ntimes = length(filelist);
%% Determine the times
times = zeros(1,length(filelist));

for iomti = 1:length(filelist)
    times(iomti) = datenum(filelist{iomti}(end-20:end-9),'yymmddHHMMSS');
end
times = (times-datenum('jan-01-1970'))*3600*24;
%% Sensor Location
% RISR position
lon0=-94.90576;
lat0=74.72955;  
h0=145;

% height = h0;
sensorloc = [lat0,lon0,h0];
%% Data Point location
lat = load(latfile);
lat=reshape(lat,omtishape(1),omtishape(2));
lat=imrotate(lat,270);

lon = load(lonfile);
lon=reshape(lon,256,256);
lon=imrotate(lon,270);

nanpoint = find(lat<-998 | lon <-998);
lat(nanpoint) = NaN;
lon(nanpoint) = NaN;
lon = lon-360;
hmat = height*ones(size(lon));
hmat(nanpoint) = NaN;
ECEF = wgs2ecef([lat(:),lon(:),hmat(:)]);
latlongheightmat = repmat(sensorloc,size(ECEF,2),1)';
ENU = ecef2enul(ECEF,latlongheightmat);
% enu is in meters
xkm = reshape(ENU(1,:),omtishape)/1e3;
ykm = reshape(ENU(2,:),omtishape)/1e3;
RE=6370;

r=sqrt(xkm.^2 + ykm.^2);


%% van Rhijn correction
%Function that corrects an OMTI image for the van Rhijn effect as well as
%atmospheric extinction, following the paper by Kubota et al., 2001
%(Characteristics of medium- and large-scale TIDs over Japan derived from
%OI 630-nm nightglow observation)

%zenith angle
theta = atan(r./height);
%correction factor for van Rhijn
V = (1 - (RE/(RE+height))^2 .* (sin(theta)).^2).^(-1/2);
%finding the values that are not NaN
nonanind1=~isnan(V);
%Correction for atmospheric extinction
% display('Correcting for atmospheric extinction')
F = (cos(theta) + 0.15 .* (93.885-theta.*180/pi).^(-1.253)).^(-1);

factor = 10.^(-0.4*0.4.*F);
nonanind2=~isnan(factor);
dataloc = [lat(nonanind2),lon(nonanind2),hmat(nonanind2)];
nlocs = size(dataloc,1);

data = struct('optical',zeros(nlocs,ntimes));
coordnames = 'wgs84';


%% Read in image data
for k_file = 1:length(filelist)
    filename = filelist{k_file};
    % This function will read the .abs data
    fid=fopen(filename, 'rb');
    fseek(fid,8,'bof');% seek ahead to remove the header
    % use uint16, seems like it works
    curdata=fread(fid,[256,256],'uint16=>uint16'); 
    fclose(fid);
    % Do a bishift, can also be divide by 4 and a floor command if double.
    curdata = bitshift(curdata,-2);
    % Do a leftright flip and then a 270 deg rotation
    im = rot90(fliplr(double(curdata)),3);

   

    image=im;
    image(nonanind1) = im(nonanind1)./V(nonanind1);
    image(nonanind2) = image(nonanind2)./factor(nonanind2);
    data.optical(:,k_file) = image(nonanind2);
end

%% Output 
varargout = {data,coordnames,dataloc,sensorloc,times};