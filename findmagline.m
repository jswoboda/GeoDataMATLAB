function [lat, lon, alt] = findmagline(GD)
%% Desciption
% this function calculates the magnetic lines for the input
% geodata
% required IGRF toolbox
% http://www.mathworks.com/matlabcentral/fileexchange/34388-international-geomagnetic-reference-field--igrf--model

%% Inputs
t = GD.times(:,1);
t = squeeze(t);
senloc = GD.sensorloc;

% convert times
newt = zeros(1,length(t));
for i = 1:length(t)
    newt(i) = datenum([1970 1 1 0 0 t(i)]);
end

%% Do work
for i = 1:length(t)
    [lat(:,i), lon(:,i), alt(:,i)] = igrfline(newt(i), senloc(1), senloc(2), ...
        senloc(3),[], 90e3, 100);
end

end