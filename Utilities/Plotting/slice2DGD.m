function hslice = slice2DGD(GD,varargin)

[axstr,slicenum,numtype] = varargin{1:3};
if ischar(axstr)
    tmpstr = struct('x',{1},'y',{2},'z',{3});
    axnum = tmpstr.(axstr);
else
    axnum = axstr;
end

%% extra parameters

v2014dt = datetime('September 15, 2014');
[~,d] = version();

if datetime(d)>=v2014dt
    defmap = parula(64);
else
    defmap = jet(64);
end

paramstr = varargin(4:2:end);
paramvals = varargin(5:2:end);
poss_labels={'key','Fig','axh','title','time','bounds','colormap'};
varnames = {'key','figname','axh','titlestr','timenum','vbound','cmap'};
vals = {1,nan,nan,'Generic',1,nan,defmap};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames)

if isnumeric(key)
    dnames = fieldnames(GD.data);
    key=dnames{key};
end
if isnumeric(figname)
    figname = figure();
    axh = newplot(figname);
else
    figure(figname);
end
if isnumeric(axh);
    axh=gca;
else
    axes(axh)
end
titlestr = insertinfo(titlestr,'key',key,'time',GD.times(timenum));


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
%%
hslice = imagesc(xaxis,yaxis,dataval);
title([titlestr,' ', axstr,' = ',num2str(dimval)],'FontSize',16)
caxis(vbound);
colormap(axh,cmap)
xlabel(['\bf ',xlab,' [km]']);
ylabel(['\bf ',ylab,' [km]']);
shading flat;
