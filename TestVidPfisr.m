clc
clear
%% TestVidPfisr

%% Read pfisr data
pfisrName = '~/data/pfa130413.002.hdf5';
key = 'nel';
pfisrGDnel = GeoData(@readMadhdf5,pfisrName,{key});

key = 'dnel';
pfisrGDdnel = GeoData(@readMadhdf5,pfisrName,{key});
%% Load video
vidName = '~/data/2013-04-14T07-00-CamSer7196_frames_363000-1-369200.DMCdata';
vidLocName = '~/data/hst0cal.h5';

vidGD = GeoData(@readDMCdata,vidName,vidLocName);

% Determine times
Notimes = size(vidGD.times,1);
vid_times = zeros(1,Notimes);

regcell_orig = vidGD.timeregister(pfisrGDnel);

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
pfisrGDnel.timereduce(unreg);
pfisrGDdnel.timereduce(unreg);
% do time registration gain 
regcell = vidGD.timeregister(pfisrGDnel);

vidGDorig = copy(vidGD);
vidGD.timereduce(unreg);
%% Plotting
% pfisr data
el = 77.5;
figure(1)
[~, ~, nel, t1, rang1] = RangevTime(pfisrGDnel,'key','nel','desiredel',el,'timeunit','minute');
figure(2)
[~, ~, dnel, t2, rang2] = RangevTime(pfisrGDdnel,'key','dnel','desiredel',el,'timeunit','minute');

relerr = 10.^(dnel/10) ./ 10.^(nel/10);
relerr(isnan(relerr)) = 0.1;
figure(10)
imagesc(t1,rang1,relerr);
datetick('x','MM')
set(gca,'YDir','Normal')
xlabel(['Time'])
ylabel('Range (km)')
b = datestr(t1(1));
title(['Relative Error Start T: ' b])
axis tight
colorbar()

% % video data
% figure(3)
% 
% subplot(2,2,1)
% pic = reshape(vidGD.data.image(:,1),[512 512]);
% imagesc(pic);
% colormap('gray')
% 
% subplot(2,2,2);
% pic = reshape(vidGD.data.image(:,2),[512 512]);
% imagesc(pic);
% colormap('gray')
% 
% subplot(2,2,3)
% pic = reshape(vidGD.data.image(:,3),[512 512]);
% imagesc(pic);
% colormap('gray')
% 
% subplot(2,2,4)
% pic = reshape(vidGD.data.image(:,4),[512 512]);
% imagesc(pic);
% colormap('gray')