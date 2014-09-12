function [ varargout ] = read_h5( filename )
%% read_h5.m
% By John Swoboda
% This function will read in data from the specifed h5 format for the
% GeoData class. This 

varnames = {'data','coordnames','dataloc','sensorloc','times'};

fileinfo = hdf5info(filename);
varargout = cell(1,length(varnames));
for k = 1:length(varnames)
    ivar = varnames{k};
    isstructvar = false;
    groupnames = {fileinfo.GroupHierarchy.Groups(:).Name};
    for l = 1:length(groupnames)
        igro = groupnames{l};
        if strcmp(ivar,igro(2:end))
            
            isstructvar=true;
            tempstruct = struct();
            setnames = {fileinfo.GroupHierarchy.Groups.Datasets(:).Name};
            for m=1:length(setnames)
                iset = setnames{m};
                isetname = iset(length(ivar)+3:end);
                tempstruct.(isetname) = h5read(filename,iset);
            end
            varargout{k} = tempstruct;
        end
    end 
    if isstructvar
        continue;
    end
    setnames = {fileinfo.GroupHierarchy.Datasets(:).Name};
    for l = 1:length(setnames)
        iset = setnames{l};
        if strcmp(ivar,iset(2:end))
            varargout{k} = h5read(filename,iset);
        end
    end
end

