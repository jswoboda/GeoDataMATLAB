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
poss_labels={'key','beam','desiredel','timeunit','Fig','axh','title','colormap','time'};
varnames = {'key','beamnum','el','tunit','figname','axh','titlestr','cmap','t'};
vals = {1,[],[],1,nan,nan,'Generic',defmap,1};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames);

if strcmp(tunit,'day') == 1
    tid = 'dd';
elseif strcmp(tunit,'hour') == 1
    tid = 'HH';
elseif strcmp(tunit,'minute') == 1
    tid = 'MM';
end

%% Do work
% check unique
[azel, ~, ic] = unique(GD.dataloc(:,[2,3]),'rows');

if ~isempty(beamnum)
    % find related ranges for selected beam
    rang = GD.dataloc(ic == beamnum);
    
    % pull out data values for selected beam
    keydata = GD.data.(key)(ic == beamnum,:);
    t = GD.times(:,1);
    
elseif ~isempty(el)
    % find desired beam
    beamnum = find(azel(:,2) == el);
    
    % find related ranges for selected beam
    if length(beamnum) == 1
        rang = GD.dataloc(ic == beamnum);
        % pull out data values for selected beam
        keydata = GD.data.(key)(ic == beamnum,:);
    else
        for k = 1:length(beamnum)
            rang{k} = GD.dataloc(ic == beamnum(k));
            % pull out data values for selected beam
            keydata{k} = GD.data.(key)(ic == beamnum(k),:);
        end
    end
    t = GD.times(:,1);
end

% convert times
newt = zeros(1,length(t));
for i = 1:length(t)
    newt(i) = datenum([1970 1 1 0 0 t(i)]);
end

%% Plot
if length(beamnum) == 1
    himage = imagesc(newt,rang,keydata);
    datetick('x',tid)
    set(gca,'YDir','Normal')
    xlabel(['Time (' tunit 's)'])
    ylabel('Range (km)')
    b = datestr(newt(1,1));
    title([key ' Start Time: ' b])
    axis tight
    colormap(cmap)
    keydata(isnan(keydata)) = 3;
    hcb = colorbar();
    ylabel(hcb,'N_e in m^{-3}');
    varargout{1} = hcb;
    varargout{2} = keydata;
    varargout{3} = newt;
    varargout{4} = rang;
else
    for j = 1:length(beamnum)
        fig = 10+j;
        figure(fig)
        himage = imagesc(newt,rang{j},keydata{j});
        datetick('x',tid)
        set(gca,'YDir','Normal')
        xlabel(['Time (' tunit 's)'])
        ylabel('Range (km)')
        b = datestr(newt(1,1));
        title([key ' Start Time: ' b])
        axis tight
        colormap(cmap)
%         keydata(isnan(keydata)) = 3;
        hcb = colorbar();
        ylabel(hcb,'N_e in m^{-3}');        
        varargout{1} = hcb;
        varargout{2} = keydata;
        varargout{3} = newt;
        varargout{4} = rang;
    end
end
end