function [himage, varargout] = RangevTime(GD,varargin)
% will plot range vs time
%% inputs
% key - A string of the variable name in the data set that will be plotted.
% The internal variable name is key and the default value will be the first 
% string in the data struct of GD.
% beam - The number beam of the beam relating to what data will be graphed
% timeunit - The time units of the x-axis (day or hour)
% Fig- The value will be a MATLAB figure handle. The internal variable name
% is figname. The default value is nan and new figure will be created.
% axh- The value will be a MATLAB axis handle. The internal variable name
% is axh. The default value is nan and a new axis will be created.
% title- The value will be a MATLAB string for the plot title. The internal
% variable name is titlestr. The default value is an empty string.
% colormap - This the colormap for the data. The internal variable name is
% cmap and its default value is MATLAB's default colormap.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output
% himage - The handle for the plotted object.
% hcb - The handle of the colorbar.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inputs
assert(strcmpi(GD.coordnames,'Spherical'),'Data needs to be in spherical.')

% determine which is the default colormap
v2014dt = datetime('September 15, 2014');
[~,d] = version();

if datetime(d)>=v2014dt
    defmap = parula(64);
else
    defmap = jet(64);
end

paramstr = varargin(1:2:end);
paramvals = varargin(2:2:end);
poss_labels={'key','beam','timeunit','Fig','axh','title','colormap'};
varnames = {'key','beamnum','tunit','figname','axh','titlestr','cmap'};
vals = {1,1,1,nan,nan,'Generic',defmap};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames);

if strcmp(tunit,'day') == 1
    tid = 'dd';
elseif strcmp(tunit,'hour') == 1
    tid = 'HH';
end

%% Do work
% check unique
[~, ~, ic] = unique(GD.dataloc(:,[2,3]),'rows');

% find related ranges for selected beam
rang = GD.dataloc(ic == beamnum);

% pull out data values for selected beam
keydata = GD.data.(key)(ic == beamnum,:);
t = GD.times(:,1);

% convert times
newt = zeros(1,length(t));
for i = 1:length(t)
    newt(i) = datenum([1970 1 1 0 0 t(i)]);
end

%% Plot
himage = imagesc(newt,rang,keydata);
datetick('x',tid)
set(gca,'YDir','Normal')
xlabel(['Time (' tunit 's)'])
ylabel('Range (km)')
title(key)
axis tight
colormap(cmap)
hcb = colorbar();
varargout{1} = hcb;
end