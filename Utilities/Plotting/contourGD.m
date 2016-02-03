function [varargout] = contourGD(GD,varargin)
% contourGD.m
% by John Swoboda
% This function will take a slice out of the data volume and plot its
% image on a 2-D plane using contour.
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
[axstr,slicenum,numtype] = varargin{1:3};
if ischar(axstr)
    tmpstr = struct('x',{1},'y',{2},'z',{3});
    axnum = tmpstr.(axstr);
else
    axnum = axstr;
end

%% extra parameters

if verLessThan('matlab','8.4')
    defmap = 'jet';
else
    defmap = 'parula';
end

paramstr = varargin(4:2:end);
paramvals = varargin(5:2:end);
poss_labels={'key','Fig','axh','title','time','bounds','colormap'};
varnames = {'key','figname','axh','titlestr','timenum','vbound','cmap'};
vals = {1,nan,nan,'',1,nan,defmap};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames)

if isnumeric(key)
    dnames = fieldnames(GD.data);
    key=dnames{key};
end

if isnumeric(figname)
    figure();
else
    set(0, 'CurrentFigure',figname);
end

if isnumeric(axh);
    axh=gca;
else
    axes(axh)
end 

titlestr = insertinfo(titlestr,'key',key,'time',GD.times(timenum,1),'timend',GD.times(timenum,2));

%% Create meshgrids
v = GD.data.(key)(:,timenum);
[X,Y,Z,V] = reshapegen(GD.dataloc,v);
xvec = squeeze(X(1,:,1));
yvec = squeeze(Y(:,1,1));
zvec = squeeze(Z(1,1,:));
%% 
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
%% Plotting
[Xmat,Ymat] = meshgrid(xaxis,yaxis);
[~, h] = contour(Xmat,Ymat,dataval);

Ntics = 5;
caxis(vbound);
hbar = colorbar();
clevel = linspace(vbound(1),vbound(2),Ntics);
newtics = linspace(hbar.Limits(1),hbar.Limits(2),Ntics);
ticstr = cell(size(clevel));
for k=1:length(clevel)
    ticstr{k} = num2str(clevel(k),'%0.1e');
end
hbar.Ticks = newtics;
hbar.TickLabels = ticstr;
%title([titlestr,' ', axstr,' = ',num2str(dimval),' [km]'],'FontSize',16)
title(titlestr,'FontSize',16);

% hbar =contourcmap(cmap,'SourceObject',axh,'Colorbar','on');

xlabel(['\bf ',xlab,' [km]']);
ylabel(['\bf ',ylab,' [km]']);
varargout=cell(1,nargout);
varargout{1}=h;
if nargout==2
    varargout{2}=hbar;
end