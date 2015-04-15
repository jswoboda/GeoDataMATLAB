classdef GeoData <handle
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
        %% Init
        function self = GeoData(readmethod,varargin)
            % This function will be the contructor for the GeoData class.
            % The two inputs are a file handle and the set of inputs for
            % the file handle. The outputs must follow the output structure
            % below.
            [self.data,self.coordnames,self.dataloc,self.sensorloc,self.times] = readmethod(varargin{:});
        end
        %% == ~=
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
        %% datanames
        function dnames = datanames(GD)
            % This will output a cell array of strings which hold the data
            % names.
            dnames = fieldnames(GD.data);
        end
        %% Interpolate
        function interpolate(self,new_coords,newcoordname,varargin)
            % This will interpolate the data
            
            if nargin <4
                method = 'linear';
                extrapmethod = 'none';
            elseif nargin <5
                method = varargin{1};
                extrapmethod = 'none';
            else
                method = varargin{1};
                extrapmethod = varargin{2};
            end
            
            curavalmethods = {'linear', 'nearest', 'cubic','natural'};
            interpmethods = {'linear', 'nearest', 'cubic','natural'};
            if ~any(strcmp(curavalmethods,method))
                error(['Must be one of the following methods: ', strjoin(curavalmethods,', ')]);
            end
            Nt = length(self.times);
            NNlocs = size(new_coords,1);


            curcoords = self.changecoords(newcoordname);
            % Loop through parameters and create temp variable
            paramnames = fieldnames(self.data);
            for iparam =1:length(paramnames)
                fprintf('Interpolating parameter %s, %d of %d\n',paramnames{iparam},iparam,length(paramnames));
                iparamn = paramnames{iparam};
                New_param = zeros(NNlocs,Nt);
                for itime = 1:Nt
                    fprintf('\tInterpolating time %d of %d\n',itime,Nt);
                    curparam =self.data.(iparamn)(:,itime);
                    if any(strcmp(method,interpmethods))
                        F = scatteredInterpolant(curcoords(:,1), curcoords(:,2),curcoords(:,3),curparam,method,extrapmethod);
                        intparam = F(new_coords(:,1),new_coords(:,2),new_coords(:,3));
                        New_param(:,itime)= intparam;
                    end
                end
                self.data.(iparamn) = New_param;
                
            end
            self.coordnames=newcoordname;
            self.dataloc = new_coords;       
        end
        %% Coordinate change
        function oc = changecoords(self,newcoordname)
            cc = self.dataloc;
            if strcmpi(self.coordnames,'spherical')&&strcmpi(newcoordname,'ENU')
                [x,y,z] = sphere2cart(cc(:,1),cc(:,2),cc(:,3));
                oc = [x,y,z];
            elseif strcmpi(self.coordnames,'spherical')&&strcmpi(newcoordname,'cartisian')
                [x,y,z] = sphere2cart(cc(:,1),cc(:,2),cc(:,3));
                oc = [x,y,z];
            elseif strcmpi(self.coordnames,'ENU')&&strcmpi(newcoordname,'spherical')
                [r,az,el] = cart2sphere(cc(:,1),cc(:,2),cc(:,3));
                oc = [r,az,el];
            elseif strcmpi(self.coordnames,'wgs84')&&strcmpi(newcoordname,'ENU')
                ECEF_COORDS = wgs2ecef(self.dataloc.');
                locmat = repmat(self.sensorloc',[1,size(ECEF_COORDS,2)]);
                oc = ecef2enul(ECEF_COORDS,locmat);
                oc = oc.';
            else strcmpi(self.coordnames,newcoordname)
                oc = cc;
            end
        end
        %% Write out
        function write_h5(self,filename)
            % This will write out the h5 file in our defined format.
            proplist = properties(self);
%             file_id  = H5F.create(filename, 'H5F_ACC_TRUNC', ...
%                              'H5P_DEFAULT', 'H5P_DEFAULT');
%             H5F.close(file_id);            
            for k = 1:length(proplist)
                prop1 = self.(proplist{k});
                if isa(prop1,'struct')
                    fnames = fieldnames(prop1);
                    for l = 1:length(fnames)
                        value = prop1.(fnames{l});
                        rvalue = permute(value,ndims(value):-1:1);
                        location = ['/',proplist{k},'/',fnames{l}];
                        h5create(filename,location,size(rvalue));
                        h5write(filename,location,rvalue)
                    end
                else
                    location = ['/',proplist{k}];
                    % TODO make this into a seperate function
                    % For some god damn reason matlab can not write strings
                    % to HDF files so for now we have this bull shit.
                    if ischar(prop1)
%                        
                        file_id = H5F.open(filename,'H5F_ACC_RDWR','H5P_DEFAULT');
                        space_id = H5S.create('H5S_SCALAR');
                        stype = H5T.copy('H5T_C_S1'); 
                        sz = numel(prop1);  
                        H5T.set_size(stype,sz);
                        
                        dataset_id = H5D.create(file_id,proplist{k}, ...
                            stype,space_id,'H5P_DEFAULT');
                        H5D.write(dataset_id,stype,'H5S_ALL','H5S_ALL','H5P_DEFAULT',prop1);
                        H5D.close(dataset_id)
                        H5S.close(space_id)
                        H5F.close(file_id);
                    else % for none char values.
                        rprop = permute(prop1,ndims(prop1):-1:1);
                        h5create(filename,location,size(rprop));
                        h5write(filename,location,rprop);
                    end
                end
            end
        end
    end
    
end

