function varargout = slice2DGD(GD,varargin)
% slice2DGD.m
% by John Swoboda
% This function will take a slice out of the data volume and plot its
% image on a 2-D plane using imagesc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% GD - An instance of the geodata class in Cartisian coordinates.
% axstr - A string that is x y or z to determine the axis that the slice
% will come from.
% slicenum - The index or value that will will coorespond to the slice
% value.
% numtype - This is either the strings value or index. If value is choosen
% then it will use the location values if index is choosen then it will use
% the array index numbers.
% Properties - These are Name Value pairs that are optional inputs like in 
% MATLAB's plotting function. The name will be listed first and the
% internal variable name will be stated in the description.

% key - A string of the variable name in the data set that will be plotted.
% The internal variable name is key and the default value will be the first 
% string in the data struct of GD.
% Fig- The value will be a MATLAB figure handle. The internal variable name
% is figname. The default value is nan and new figure will be created.
% axh- The value will be a MATLAB axis handle. The internal variable name
% is axh. The default value is nan and a new axis will be created.
% title- The value will be a MATLAB string for the plot title. The internal
% variable name is titlestr. The default value is an empty string.
% time - The value will be an integer that cooresponds to the time value in
% GD. The internal variable name is timenum and the default value is 1.
% bounds - A vector of two elements, the first is the lower bound and the
% second is the higher bound for the Caxis. The internal variable name is 
% vbound and its default value will be the max and min of the data to be
% plotted.
% colormap - This the colormap for the data. The internal variable name is
% cmap and its default value is MATLAB's default colormap.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output
% hslice - The handle for the plotted object.
% hbar - A handle for the colorbar.(optional);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
assert(strcmpi(GD.coordnames,'cartesian'),'GeoData object needs to be in cartisian coordinates.')
%% Main inputs
[axstr,slicenum,numtype] = varargin{1:3};
if ischar(axstr)
    tmpstr = struct('x',{1},'y',{2},'z',{3});
    axnum = tmpstr.(axstr);
else
    axnum = axstr;
end

%% Extra parameters

% determine which is the default colormap
if verLessThan('matlab','8.4')
    defmap = 'jet';
else
    defmap = 'parula';
end

% Determine the properties
paramstr = varargin(4:2:end);
paramvals = varargin(5:2:end);
poss_labels={'key','Fig','axh','title','time','bounds','colormap','overlay','cbar'};
varnames = {'key','figname','axh','titlestr','timenum','vbound','cmap','overlay','cbar'};
vals = {1,nan,nan,'',1,[nan,nan],defmap,false,false};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames)
% apply default parameters 
if isnumeric(key)
    dnames = fieldnames(GD.data);
    key=dnames{key};
end

if isnumeric(figname)
    figname = figure();
    axh = newplot(figname);
else
    set(0, 'CurrentFigure',figname);
end
if isnumeric(axh);
    axh=gca;
else
    axes(axh)
end 
% Augment the title string to remove the wildcard characters
if ismatrix(GD.times)&&~isempty(titlestr)
    if size(GD.times,2)>1
        titlestr = insertinfo(titlestr,'key',key,'time',GD.times(timenum,1),'timend',GD.times(timenum,2));
    else
        titlestr = insertinfo(titlestr,'key',key,'time',GD.times(timenum,1));
    end
end
%% Create meshgrids
v = GD.data.(key)(:,timenum);
if all(isnan(vbound))
    vbound = [min(v),max(v)];
end
[X,Y,Z,V] = reshapegen(GD.dataloc,v);
xvec = squeeze(X(1,:,1));
yvec = squeeze(Y(:,1,1));
zvec = squeeze(Z(1,1,:));
%% Determine axis
% fill in variables for title, x and y labels depending on the choosen
% slice axis.
if strcmp(axstr,'x')
    if strcmpi(numtype,'index')
        indxnum = slicenum;
        dimval = xvec(indxnum);
    elseif strcmpi(numtype,'value')
        [~,indxnum] = min(abs(xvec-slicenum));
        dimval = slicenum;
    end
    dataval  = squeeze(V(:,indxnum,:)).';
    xaxis = yvec;
    yaxis = zvec;
    xlab = 'y';
    ylab = 'z';
elseif strcmp(axstr,'y')
    if strcmpi(numtype,'index')
        indxnum = slicenum;
        dimval = yvec(indxnum);
    elseif strcmpi(numtype,'value')
        [~,indxnum] = min(abs(yvec-slicenum));
        dimval = slicenum;
    end
    dataval  = squeeze(V(indxnum,:,:));
    xaxis = xvec;
    yaxis = zvec;
    xlab = 'x';
    ylab = 'z';
elseif strcmp(axstr,'z')
    if strcmpi(numtype,'index')
        indxnum = slicenum;
        dimval = zvec(indxnum);
    elseif strcmpi(numtype,'value')
        [~,indxnum] = min(abs(zvec-slicenum));
        dimval = slicenum;
    end
    dataval  = squeeze(V(:,:,indxnum));
    xaxis = xvec;
    yaxis = yvec;
    xlab = 'x';
    ylab = 'y';
end
%% Plot image
if overlay
    cdata = makecdata(dataval,cmap,vbound);
    hslice = image(xaxis,yaxis,cdata);
else
    hslice = imagesc(xaxis,yaxis,dataval,vbound);
    colormap(axh,cmap)
end
if ~isspace(titlestr)
    title([titlestr,' ', axstr,' = ',num2str(dimval)],'FontSize',16)
end
xlabel(['\bf ',xlab,' [km]']);
ylabel(['\bf ',ylab,' [km]']);
set(gca,'Ydir','normal')
shading flat;
varargout = cell(1,nargout);
    
varargout{1} = hslice;
if cbar || nargout==2
    hbar = colorbar(axh); 
    varargout{2} = hbar;
end
