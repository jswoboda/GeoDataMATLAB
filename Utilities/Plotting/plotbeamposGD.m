function plotbeamposGD(GD,varargin)
% plotbeamposGD.m
% by John Swoboda
% This function will plot the beam grid in a polar grid with the az angle
% as the azimithal commponent of the grid and the el angle as the range in
% decending order.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% GD - An instance of the geodata class in Spherical coordinates.
%
% Properties - These are Name Value pairs that are optional inputs like in 
% MATLAB's plotting function. The name will be listed first and the
% internal variable name will be stated in the description.
% 
% Fig- The value will be a MATLAB figure handle. The internal variable name
% is figname. The default value is nan
% axh- The value will be a MATLAB axis handle. The internal variable name
% is axh. The default value is nan
% title- The value will be a MATLAB string for the plot title. The internal
% variable name is titlestr. The default value is an empty string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input
% Determine the properties
paramstr = varargin(1:2:end);
paramvals = varargin(2:2:end);
poss_labels={'Fig','axh','title','minring'};
varnames = {'figname','axh','titlestr','minring'};
vals = {nan,nan,'Beampositions',30};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames)


if isnumeric(figname)
    figure();
    axh = newplot(figname);
else
    figure(figname);
end
if isnumeric(axh);
    axh=gca;
end
maxel=90-minring;
%% Determine angles

assert(strcmpi(GD.coordnames,'spherical'),'The GeoData instance must be in spherical coordinates');
angles = GD.dataloc(:,2:end);
uang = unique(angles,'rows');

az = uang(:,1);
el = uang(:,2);
az = az*pi/180;


%% Plotting
plotring=maxel+10;
theta = linspace(0,2*pi,100);
r10 = plotring*ones(1,100);
[xx1,yy1] = pol2cart(theta,r10);
fill(xx1,yy1,'w')
hold on

axis off 
axis equal
hold on

%plotting the radar beams
[xx,yy]=pol2cart(-az+pi/2,90-el);
plot(xx,yy,'o','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',10)


%Plotting the cardinal directions


lin1x=linspace(-plotring,plotring,700);
lin1y=linspace(0,0,700);
plot(lin1x,lin1y,':k')
lin1x=linspace(0,0,700);
lin1y=linspace(-plotring,plotring,700);
plot(lin1x,lin1y,':k')
lin1x=linspace(-plotring*sind(45),plotring*sind(45),700);
lin1y=linspace(-plotring*cosd(45),plotring*cosd(45),700);
plot(lin1x,lin1y,':k')
lin1x=linspace(-plotring*sind(45),plotring*sind(45),700);
lin1y=linspace(plotring*cosd(45),-plotring*cosd(45),700);
plot(lin1x,lin1y,':k')

text(plotring+3,0,'E')
text((plotring+3)*cosd(45),(plotring+3)*sind(45),'NE')
text(-1,(plotring+3),'N')
text(-(plotring+6),0,'W')
text(-(plotring+11)*cosd(45),(plotring+6)*sind(45),'NW')
text(-1,-(plotring+3),'S')
text(-(plotring+11)*cosd(45),-(plotring+6)*sind(45),'SW')
text((plotring+3)*cosd(45),-(plotring+3)*sind(45),'SE')

%plotting elevation rings

elev=10:10:maxel;%[10,20,30,40,50,60];
theta = linspace(0,2*pi,100);
r20 = elev'*ones(1,100);
for i=1:length(elev)
    [x,y] = pol2cart(theta,r20(i,:));
    plot(x,y,':k')
    text(elev(i)*sind(22.5),-elev(i)*cosd(22.5)-2,sprintf('%d',90-elev(i)))
end
title({titlestr;''},'FontSize',16);
axis off
% 
% for i=1:1:length(xx)
%     text(xx(i)+2,yy(i)+2,sprintf('%d',i))     
% end       
        