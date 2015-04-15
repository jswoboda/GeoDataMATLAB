function hslice = sliceGD(GD,varargin)

if ismatrix(varargin{1})
    [Xi,Yi,Zi] = varargin{1:3};
    surftype = 1;
elseif ndims(varargin{1})==1
    [sx,sy,sz] = varargin{1:3};
    surftype = 2;
end  
paramstr = varargin(4:2:end);
paramvals = varargin(5:2:end);
poss_labels={'key','Fig','axh','title','time','bounds'};
varnames = {'key','figname','axh','titlestr','timenum','vbound'};
vals = {1,nan,nan,'Generic',1,nan};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames)



if isnumeric(key)
    dnames = fieldnames(GD.data);
    key=dnames{key};
end
if isnumeric(figname)
    figure();
end
if isnumeric(axh);
    axh=gca;
end
v = GD.data.(key)(:,timenum);
[X,Y,Z,V] = reshapegen(GD.dataloc,v);
if surftype==1
    hslice=slice(X,Y,Z,V,Xi,Yi,Zi);
elseif surftype==2
    hslice=slice(X,Y,Z,V,sx,sy,sz);
    
end
caxis(vbound);
xlabel('\bf x [km]');
ylabel('\bf y [km]');
zlabel('\bf z [km]');
shading flat;
