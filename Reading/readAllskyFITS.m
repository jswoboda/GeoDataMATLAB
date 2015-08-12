function [ varargout ] = readAllskyFITS(all_sky,az,el,alt,varargin)
% allsky2enu.m
% [X_out,Y_out,d_image] = allsky2enu(all_sky,az,el,rng,im_sz)
% This function will take allsky data and from either a FITS file or memory
% and output the data on to a cartisian grid.  That is determined from the
% parameter im_sz.  
%% Inputs
% all_sky - This can either be an NxM image or the name of a FITS file that
% holds the data.
% az - This can either be an NxM image or the name of a FITS file that
% holds the az locations.
% el- This can either be an NxM image or the name of a FITS file that
% holds the el locations
% alt - A scalar that holds determines where the image will be projected to
% in meters.
% im_sz = The final size of the image in the lat/long space [N_lat, N_lon].
% if it a scalar N_lat = N_long = im_sz.
%% Outputs
% X_out - A 1xN X array that holds the X dimension (east) spacing.
% Y_out - A 1xN Y array that holds the Y dimesion (north) spacing.
% d_image - The final image on lat long space of size[N_lat,N_lon]
%% Check input
% open allsky file or just use matrix
if ischar(all_sky)
    d=fitsread(all_sky);
    allskysize = size(d);
    datamat = d(:);
    all_sky = {all_sky};
elseif iscell(all_sky)
    passed = true(size(all_sky));
    d=fitsread(all_sky{1});
    allskysize = size(d);
    datamat = zeros(numel(d),length(all_sky));
    datamat(:,1) = d(:);
    for k=2:length(all_sky)
        try
            d=fitsread(all_sky{k});
            datamat(:,k)=d(:);
        catch
            disp(['File ', all_sky{k},' cannot be read or wrong size']);
            passed(k)=false;
        end
    end
    datamat = datamat(:,passed);
    all_sky=all_sky(passed);
end
data = struct('optical',datamat);
% open az file or just use matrix

if ischar(az)
    az_i=fitsread(az);
else
    az_i =az;
end
% open el file or just use matrix

if ischar(el)
    el_i = fitsread(el);
else
    el_i = el;
end
% check to make sure az and el
if ~all(size(el_i)==allskysize) || ~all(size(az_i)==allskysize)
    error('El and Az need to be same size as data');
end
%% Set up Time array
aldtnum = fitsfiletimestamp(all_sky);
timevec = (aldtnum-datenum('jan-01-1970'))*(24*3600);
if nargin==5
    times=[timevec(:),timevec+varargin{1}];
elseif nargin<5
    avdiff = mean(diff(timevec(:)));
    times = [timevec(:),circshift(timevec(:),-1)];
    times(end,end)=timevec(end)+avdiff;
    
end   
%% Fix problems with the coordinate matrix
% Look for large gradients in the az mapping because the in between values
% will put the data in the wrong spot.
grad_thresh = 15;
[Fx,Fy] = gradient(az_i);
bad_data_logic = hypot(Fx, Fy) > grad_thresh;
az_i(bad_data_logic) = 0;
zerodata = az_i==0 & el_i==0;
keepdata = ~zerodata(:);
coordnames = 'Spherical';
dataloc = [alt*ones(prod(allskysize),1)./cosd(90-el_i(:)),az_i(:),el_i(:)];
dataloc = dataloc(keepdata,:);
data.optical=data.optical(keepdata,:);
%% FIX This

sensorloc = [65.1260,-147.4789,689 ];
varargout = {data,coordnames,dataloc,sensorloc,times};