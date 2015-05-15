function hslice = sliceGD(GD,varargin)

emptyarr = false(1,3);
for k=1:3
    emptyarr(k)= isempty(varargin{k});
end
if (ndims(varargin{1})==1)||any(emptyarr)
    [sx,sy,sz] = varargin{1:3};
    surftype = 2;
elseif ismatrix(varargin{1})
    [Xi,Yi,Zi] = varargin{1:3};
    surftype = 1;

end  


v2014dt = datetime('September 15, 2014');
[~,d] = version();

if datetime(d)>=v2014dt
    defmap = parula(64);
else
    defmap = jet(64);
end
paramstr = varargin(4:2:end);
paramvals = varargin(5:2:end);
poss_labels={'key','Fig','axh','title','time','bounds','twodplot','colormap'};
varnames = {'key','figname','axh','titlestr','timenum','vbound','twodplot','cmap'};
vals = {1,nan,nan,'Generic',1,nan,false,defmap};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames)


if isnumeric(key)
    dnames = fieldnames(GD.data);
    key=dnames{key};
end

if isnumeric(figname)
    figure();
    axh = newplot(figname);
else
    figure(figname);
end
if isnumeric(axh);
    axh=gca;
end
titlestr = insertinfo(titlestr,'key',key,'time',GD.times(timenum));

v = GD.data.(key)(:,timenum);
[X,Y,Z,V] = reshapegen(GD.dataloc,v);
if twodplot
    origloc = GD.dataloc(1,:);
    ONlocs = size(GD.dataloc,1);
    loclog = origloc(ones(ONlocs,1),:)==GD.dataloc;
    dimrm = all(loclog,1);
    if dimrm(1)&&~emptyarr(1)
        X=ones(size(Y))*sx;
    elseif dimrm(2)&&~emptyarr(2)
        Y=ones(size(Z))*sy;
    elseif dimrm(3)&&~emptyarr(3)
        Z=ones(size(X))*sz;
    end
    curcdata = makecdata(V,cmap,vbound);
    hslice=surf(axh,X,Y,Z,'Cdata',curcdata,'EdgeColor','none');
else
    if surftype==1
        hslice=slice(axh,X,Y,Z,V,Xi,Yi,Zi);
    elseif surftype==2
        hslice=slice(axh,X,Y,Z,V,sx,sy,sz);
    end
    colormap(axh,cmap)
    caxis(vbound);
end


xlabel('\bf x [km]');
ylabel('\bf y [km]');
zlabel('\bf z [km]');
title(titlestr);
shading flat;
