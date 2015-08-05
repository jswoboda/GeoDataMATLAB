clear
clc
%% TestVidCon
% adds contours from Ne data over high speed video data

%% Create Figure directory
figdir = 'figures';
if ~exist(figdir,'dir')
    mkdir(figdir);
end

%% Read data and time register
pfisrName = '~/U/eng_research_irs/irs_archive2/HSTdata/DataField/2013-04-14/PFISR/pfa130413.002.hdf5';
pfisrGD = GeoData(@readMadhdf5,pfisrName,{'nel'});

% Change the log electron density to linear density
myfunc = @(ex,base)(base.^ex);
pfisrGD.changedata('nel','ne',myfunc,{10});

%% Lol jk
% %% Load video
% vidName = '~/U/eng_research_irs/Auroral_Video/X1387_032307_112005.36_full_30fps.avi';
% vidLocName = '~/U/eng_research_irs/Auroral_Video/Mar2007calibration/X1387_03_23_2007_031836.mat';
% 
% aviGD = GeoData(@readAVI,vidName,vidLocName);

%% Load video
vidName = '~/U/eng_research_irs/irs_archive2/HSTdata/DataField/2013-04-14/HST0/2013-04-14T07-00-CamSer7196_frames_363000-1-369200.DMCdata';
vidLocName = '~/U/eng_research_irs/HiST/calibration/hst0cal.h5';

vidGD = GeoData(@readDMCdata,vidName,vidLocName);

% Determine times
Notimes = size(vidGD.times,1);
vid_times = zeros(1,Notimes);

regcell_orig = vidGD.timeregister(pfisrGD);

combreg = [regcell_orig{:}];
unreg = unique(combreg);

% Get the vid data that has cooresponding risrdata.
vidkeep = [];
for k = 1:length(vid_times)
    
    if ~isempty(regcell_orig{k})
        vidkeep = [vidkeep,k];
    end
end

% Reduce the time points in the original data so we don't have to do a
% whole lot of interpolation
pfisrGD.timereduce(unreg);
% do time registration gain 
regcell = vidGD.timeregister(pfisrGD);
vidGD.timereduce(unreg);

vidGDorig = copy(vidGD);
% %% Interpolation
% % Reduce the time points in the original data so we don't have to do a
% % whole lot of interpolation
% % pfisrGD.timereduce(1:6);
% % vidGD.timereduce(1:6);
% xvec = linspace(-900,900);
% yvec = linspace(-900,900);
% 
% [xmat,ymat] = meshgrid(xvec,yvec);
% coords = [xmat(:),ymat(:),120*ones(numel(xmat),1)];
% 
% vidGD.interpolate(coords,'ENU','natural','nearest',true);
% vidGDfirstint = copy(vidGD);
%% Interpolation
xvec = linspace(-1000,1000,50);
yvec = linspace(-1000,1000,50);
zvec = linspace(100,500,50);

[X,Y,Z] = meshgrid(xvec,yvec,zvec);

[Xmat,Ymat] = meshgrid(xvec,yvec);

newcoords = [X(:),Y(:),Z(:)];
newcoords2 = [Xmat(:),Ymat(:),120*ones(numel(Xmat),1)];
% copy so you can keep the original beam pattern.
pfisrGDorig = copy(pfisrGD);

pfisrGD.interpolate(newcoords,'Cartesian','natural');
vidGD.interpolate(newcoords2,'Cartesian','natural','nearest',true);
%% Plotting
% plot the data with frame by frame 
fname = 'example';

for k = 1:length(unreg)
    risrtimes = regcell{k};
    for irt = 1:length(risrtimes)
        curirt = risrtimes(irt);
        hfig = figure('Color',[1,1,1],'Position',[680,250,1100,725]);
        
        % plots ne data
        hax1 = subplot(2,2,1);
        [risr2dslic, hcb1] = slice2DGD(pfisrGD,'z',400,'value','key','ne','Fig',hfig,'axh',hax1...
            ,'time',k,'bounds',[5e9,5e11]);
        ylabel(hcb1,'N_e in m^{-3}');
        hold all
        
        % plots video frame with contours over it
        hax2 = subplot(2,2,2);
        h = Vidslice(vidGD,k);
        colormap('gray')
        axis tight
        hold all
        freezeColors
        [contimg, hcb2] = contourGD(pfisrGD,'z',400,'value','key','ne','Fig',hfig,'axh',hax2...
            ,'time',k,'bounds',[200,800],'colormap','cool');
        ylabel(hcb2,'N_e in m^{-3}');
        
        % plots first interpolation data
        hax3 = subplot(2,2,3);
%         pic = reshape(vidGDfirstint.data.image(:,k),[100 100]);
%         imagesc(pic);
%         colormap('gray')
        
        % plots original 
        hax4 = subplot(2,2,4);
        pic = reshape(vidGDorig.data.image(:,k),[512 512]);
        imagesc(pic);
        colormap('gray')
        
        %     curfilename = [fname,num2str(k,'%0.2d'),'.fig'];
        %     saveas(hfig,fullfile(figdir,curfilename));
        close(hfig);
    end
end
