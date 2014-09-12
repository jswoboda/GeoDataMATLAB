classdef GeoData
    %GeoData 
    % This is a class to hold geophysical data from ground based sensors
    properties
        data% struct
        coordtype % type of coordinates.
        dataloc % location of data points
        sensorloc% sensor location in lla
        times% times in posix formats
    end
    
    methods
        function GD = GeoData(readmethod,varargin)
            [GD.data,GD.coordtype,GD.sensorloc] = readmethod(varargin{:});
        end
        
        function out = eq(GD,GD2)
            % check the data struct
            proplist = properties(GD);
            proplist2 = properties(GD2);
            if ~isequal(proplist,proplist2)
                error('GD or GD is not a GeoData object');
            end
            
            
            for k = 1:length(proplist)
                prop1 = get(GD,proplist{k});
                prop2 = get(GD2,proplist{k});
                if ~isequaln(prop1,prop2)
                    out=false;
                    return
                end
            end
            out=true;
        end
        
        function out=ne(GD,GD2)
            out = ~GD==GD2;
        end
        function dnames = datanames(GD)
            dnames = fieldnames(GD.data);
        function write_h5(GD,filename)
            
        end
    end
    
end

