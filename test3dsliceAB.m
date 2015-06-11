clear
clc

addpath('/home/amber/GeoDataMATLAB/freezeColors');
addpath('/home/amber/GeoDataMATLAB/cm_and_cb_utilities')
%% Testslice
% This is a program to test the GeoData code using the files stated below.
%% Create Figure directory
figdir = 'figures';
if ~exist(figdir,'dir')
    mkdir(figdir);
end
%% Read data and time register
risrName = 'ran120219.004.hdf5';
omtiName = 'OMTIdata.h5';

omtiGD = GeoData(@read_h5,omtiName);
risrGD = GeoData(@readMadhdf5,risrName,{'nel'});

% Change the log electron density to linear density
myfunc = @(ex,base)(base.^ex);
risrGD.changedata('nel','ne',myfunc,{10});

Notimes = size(omtiGD.times,1);
omti_times = zeros(1,Notimes);

regcell_orig = omtiGD.timeregister(risrGD);

combreg = [regcell_orig{:}];
unreg = unique(combreg);

% Get the omti data that has cooresponding risrdata.
omtikeep = [];
for k = 1:length(omti_times)
    
    if ~isempty(regcell_orig{k})
        omtikeep = [omtikeep,k];
    end
end

% Reduce the time points in the original data so we don't have to do a
% whole lot of interpolation
risrGD.timereduce(unreg);
% do time registration gain 
regcell = omtiGD.timeregister(risrGD);

%% Interpolation
xvec = linspace(-100,600,50);
yvec = linspace(0,600,50);
zvec = linspace(100,500,50);

[X,Y,Z] = meshgrid(xvec,yvec,zvec);

[Xmat,Ymat] = meshgrid(xvec,yvec);

newcoords = [X(:),Y(:),Z(:)];
newcoords2 = [Xmat(:),Ymat(:),140*ones(numel(Xmat),1)];
% copy so you can keep the original beam pattern.
risrGDorig = copy(risrGD);
risrGD.interpolate(newcoords,'Cartesian','natural');
omtiGD.interpolate(newcoords2,'Cartesian','natural','none',true);
xlist = [100];
ylist = [300];
zlist = [];
% zlist = [300];
%% Plotting
% plot the data
omtimap = gray(64);
fname = 'example';
for k =1:length(omtikeep)
    risrtimes = regcell{k};
    for irt =1:length(risrtimes)
        curirt = risrtimes(irt);
        % make a four quadrant figure with the combined data in 3-D, two
        % 2-D altitude slices and a beam pattern.
        hfig = figure('Color',[1,1,1],'Position',[680,250,1100,725]);
        hax = subplot(2,2,1);

        risrslic = sliceGD(risrGD,xlist,ylist,zlist,'key','ne','Fig',hfig,'axh',hax,'title'...
            ,'','time',curirt,'bounds',[5e9,5e11]);
        hcb = colorbar();
        ylabel(hcb,'N_e in m^{-3}');
        hold all
        omtislice = sliceGD(omtiGD,[],[],[400],'key','optical','Fig',hfig,'axh',hax,'title'...
           ,'N_e and OMTI at $thm','time',k,'bounds',[200,800],'twodplot',true,'colormap',omtimap);
        axis tight
        view(-40,30);
        
        hax2 = subplot(2,2,2);
        risr2dslic = slice2DGD(risrGD,'z',400,'value','key','ne','Fig',hfig,'axh',hax2,'title'...
            ,'N_e at $thm','time',curirt,'bounds',[5e9,5e11]);
        hcb2 = colorbar('peer', hax2);
        ylabel(hcb2,'N_e in m^{-3}');
        
        hax3 = subplot(2,2,3);     
        omti2dslic = slice2DGD(omtiGD,'z',400,'value','key','optical','Fig',hfig,'axh',hax3,'title'...
           ,'OMTI at $thm','time',k,'bounds',[200,800],'colormap',omtimap);
        hold all
        [contimg, h] = contourGD(risrGD,'z',400,'value','key','ne','Fig',hfig,'axh',hax3,'title'...
            ,'N_e at $thm','time',curirt,'bounds',[200,800],'colormap','cool');
        hcb3 = colorbar();
        
        hax4 = subplot(2,2,4);
        plotbeamposGD(risrGDorig,'Fig',hfig,'axh',hax4);
        curfilename = [fname,num2str(k,'%0.2d'),'.fig'];
        saveas(hfig,fullfile(figdir,curfilename));
        close(hfig);
    end
end