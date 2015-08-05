%% Set up
%Omtidir
outfile = 'OMTIdata.h5';
delete(outfile);
omtidir = '/Users/Bodangles/Documents/MATLAB/myomti/omtidata';
omtisize = [256,256];

coordfolder =  '/Users/Bodangles/Documents/MATLAB/omti/OMTI';

filelist = strsplit(ls(fullfile(omtidir,'*C61*.abs')));
filelist = filelist(1:end-1);
omtih = 140;
latfile = fullfile(coordfolder,['omti_glat_',num2str(omtih),'km.dat']);
lonfile = fullfile(coordfolder,['omti_glon_',num2str(omtih),'km.dat']);
%%
datecell = {'20-Feb-2012 06:00:00','20-Feb-2012 08:00:00'};
GD = GeoData(@readomti,filelist,latfile,lonfile,omtih,omtisize,datecell);

xvec = linspace(-900,900);
yvec = linspace(-900,900);

[xmat,ymat] = meshgrid(xvec,yvec);
coords = [xmat(:),ymat(:),omtih*ones(numel(xmat),1)];

GD.interpolate(coords*1e3,'ENU','natural','nearest');
GD.write_h5(outfile);
myim = reshape(GD.data.optical(:,25),size(xmat));
figure,imagesc(xvec,yvec,myim,[200,500]);colormap gray;colorbar;