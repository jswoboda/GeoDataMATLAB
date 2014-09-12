classdef GeoData
    %GeoData 
    % This is a class to hold geophysical data from different types of 
    % sensors to study near earth space physics.
    properties
        data% struct
        coordnames % type of coordinates.
        dataloc % location of data points
        sensorloc% sensor location in lla
        times% times in posix formats
    end
    
    methods
        function self = GeoData(readmethod,varargin)
            % This function will be the contructor for the GeoData class.
            % The two inputs are a file handle and the set of inputs for
            % the file handle. The outputs must follow the output structure
            % below.
            [self.data,self.coordnames,self.dataloc,self.sensorloc,self.times] = readmethod(varargin{:});
        end
        
        function out = eq(self,GD2)
            % This is the == operorator for the GeoData class 
            proplist = properties(self);
            proplist2 = properties(GD2);
            
            if ~isequal(proplist,proplist2)
                error('GD or GD is not a GeoData object');
            end
            
            for k = 1:length(proplist)
                prop1 = self.(proplist{k});
                prop2 = GD2.(proplist{k});
                if ~isequaln(prop1,prop2)
                    out=false;
                    return
                end
            end
            out=true;
        end
        
        function out=ne(GD,GD2)
            % This is the ~= operorator for the GeoData class 
            out = ~(GD==GD2);
        end
        
        function dnames = datanames(GD)
            % This will output a cell array of strings which hold the data
            % names.
            dnames = fieldnames(GD.data);
        end
        
        
        function write_h5(self,filename)
            % This will write out the h5 file in our defined format.
            proplist = properties(self);
            
            for k = 1:length(proplist)
                prop1 = self.(proplist{k});
                if isa(prop1,'struct')
                    fnames = fieldnames(prop1);
                    for l = 1:length(fnames)
                        value = prop1.(fnames{l});
                        location = ['/',proplist{k},'/',fnames{l}];
                        h5create(filename,location,size(value));
                        h5write(filename,location,value)
                    end
                else
                    location = ['/',proplist{k}];
                    h5create(filename,location,size(prop1));
                    h5write(filename,location,prop1);
                end
            end
        end
    end
    
end

