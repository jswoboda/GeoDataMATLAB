function hplot = plotsamples(GD,outcoords,varargin)
% plotsamples
% by John Swoboda
% This function will plot the sample points from the current coordinate
% system and plot them in the desired coordinate system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% GD - An instance of the geodata class in Cartisian coordinates.
% outcoords - The desired coordinate system the user wants to see the
% sample points in.
% Properties - These are Name Value pairs that are optional inputs like in 
% MATLAB's plotting function. The name will be listed first and the
% internal variable name will be stated in the description.

% Fig- The value will be a MATLAB figure handle. The internal variable name
% is figname. The default value is nan and new figure will be created.
% axh- The value will be a MATLAB axis handle. The internal variable name
% is axh. The default value is nan and a new axis will be created.
% title- The value will be a MATLAB string for the plot title. The internal
% variable name is titlestr. The default value is an empty string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output
% hslice - The handle for the plotted object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inputs
% Determine the properties
paramstr = varargin(1:2:end);
paramvals = varargin(2:2:end);
poss_labels={'Fig','axh','title','MarkerSize'};
varnames = {'figname','axh','titlestr','mksize'};
vals = {nan,nan,'',10};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames)

% apply default parameters 
if isnumeric(figname)
    figname = figure();
    axh = newplot(figname);
else
    figure(figname);
end
if isnumeric(axh);
    axh=gca;
end

%% Plotting

newcoords = GD.changecoords(outcoords);

if size(newcoords,2)==3
    hplot = plot3(axh,newcoords(:,1),newcoords(:,2),newcoords(:,3),'k.','MarkerSize',mksize);
    xlabel('\bf x [km]','FontSize',14);
    ylabel('\bf y [km]','FontSize',14);
    zlabel('\bf z [km]','FontSize',14);
elseif size(newcoords,2)==2
    hplot = plot(axh,newcoords(:,1),newcoords(:,2),'k.','MarkerSize',mksize);
    xlabel('\bf x [km]','FontSize',14);
    ylabel('\bf y [km]','FontSize',14);
end
grid on
title(titlestr,'FontSize',16);
