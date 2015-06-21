function [ varargout ]=readMadhdf5(filename, paramstr)
%% readMad_hdf5
% by John Swoboda and Anna Stuhlmacher
% madgrigal h5 read in function for the python implementation of GeoData for Madrigal Sondrestrom data
% Input
% filename: path to hdf5 file
% paramstr: list of parameters to look at written as strings
% Returns:
% dictionary with keys are the Madrigal parameter string, the value is an array
% rows are unique data locations (data_loc) = (rng, azm, el1)
% columns are unique times
% 


%open hdf5 file
all_data = h5read(filename,'/Data/Table Layout');
sensor_struct = h5read(filename,'/Metadata/Experiment Parameters');
sensor_data = sensor_struct.value';

sensorname = sensor_data(1,:);

if strmatch('Sondrestrom', sensorname)
    radar = 1;
    disp('Sondrestrom data')
elseif strmatch('Poker Flat' , sensorname)
    radar = 2;
    disp('PFISR data')
elseif strmatch('Resolute Bay' , sensorname)
    radar = 3;
    disp('RISR data')
else
    error('Sensor type not supported by program in this version')   
end
%get the data location (range, el1, azm)

if radar == 1
    angle1 = 'elm';
    rng = all_data.('range');
    azm = (all_data.az1+all_data.az2)/2;
    el = (all_data.el1+all_data.el2)/2;
    evnend = all_data.posf;  
    
else
    angle1 = 'elm';
    rng = all_data.('range');


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
end
% take out nans
nan_ar = isnan(rng)|isnan(el)|isnan(azm);
notnan = ~nan_ar;
all_loc= zeros(sum(notnan),3);

icount=1;
for i =1:length(rng)
    if notnan(i)
        all_loc(icount,:) = [rng(i),azm(i),el(i)];
        icount=icount+1;
    end
end

%create list of unique data location lists
[dataloc,~,icloc] = unique(all_loc,'rows');
times1 = all_data.('ut1_unix')(notnan);
times2 = all_data.('ut2_unix')(notnan);
all_times = [times1,times2];

[uniq_times,~,ictime] = unique(all_times,'rows');
% for sondastrom data

%initialize and fill data dictionary with parameter arrays
data = struct();
maxcols = size(uniq_times,1);
maxrows = size(dataloc,1);

% for sondastrom data

if radar==1
    times1 = all_data.('ut1_unix');
    times2 = all_data.('ut2_unix');
    all_times = [times1,times2];

    [uniq_times1,~,ictime1] = unique(all_times,'rows');
    scansend = unique(ictime1(logical(evnend)));
    scansbeg = circshift(scansend(:),1);
    scansbeg(1) =0;
    scansbeg = scansbeg+1;    
    uniq_times = [uniq_times(scansbeg,1),uniq_times(scansend,2)];
end
nanar1 = true(maxrows,1);
% fill the arrays
for ip =1:length( paramstr)
    p=paramstr{ip};
    if isempty(strmatch(p, fieldnames(all_data)))
        warning( [ p,  ' is not a valid parameter name.'])
        continue
    end
    notnandata = find(~isnan(all_data.(p)(notnan)));
    datared = all_data.(p)(notnan);
    datared(datared==0) = NaN;
    tempdata = datared(notnandata); %list of parameter pulled from all_data
%     temparray = sparse(maxrows,maxcols); %converting the tempdata list into array form
    temparray = sparse(icloc(notnandata),ictime(notnandata),double(tempdata),maxrows,maxcols);
    
    if radar==1
        NNt = length(scansbeg);
        temparr2 = sparse(maxrows,NNt);
        for iscan = 1:NNt
            ibeg = scansbeg(iscan);
            iend = scansend(iscan);
            scanvec = ibeg:iend;
            [rows1,~] = find(temparray(:,scanvec));
            tempsum = sum(temparray(:,scanvec),2);
            [counts,locs]=hist(rows1,unique(rows1));
            tempsum(locs) = tempsum(locs)./counts';
            temparr2(:,iscan) = tempsum;
        end
        temparray = temparr2;
    end
    nanar1 = all(~temparray,2)&nanar1;
    data.(p)=temparray;
end
for ip =1:length( paramstr)
    p=paramstr{ip};
    data.(p) = data.(p)(~nanar1,:);
    data.(p) = full(data.(p));
    [rowsz,colsz] = find(isnan(data.(p)));
    nnentries = data.(p)~=0;
    data.(p)(rowsz,colsz) = 0;
     
    tzero = nan(size(data.(p)));
    tzero(nnentries) = data.(p)(nnentries);
    data.(p)=tzero;
end
dataloc = dataloc(~nanar1,:);
%get the sensor location (lat, long, rng)
lat = str2double(sensor_data(8,:));
lon = str2double(sensor_data(9,:));
sensor_alt = str2double(sensor_data(10,:));
sensorloc =[lat,lon,sensor_alt];
coordnames = 'Spherical';

varargout = {data,coordnames,dataloc,sensorloc,double(uniq_times)};