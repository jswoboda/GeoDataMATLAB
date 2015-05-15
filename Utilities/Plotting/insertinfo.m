function strout = insertinfo(strin,varargin)

paramstr = varargin(1:2:end);
paramvals = varargin(2:2:end);
poss_labels={'key','time'};
varnames = {'key','posix'};
vals = {'',nan};
checkinputs(paramstr,paramvals,poss_labels,vals,varnames);


strout = strrep(strin,'$k',key);
if isnan(posix);
    strout=strrep(strout,'$tu','');
    strout=strrep(strout,'$tdu','');
else
    curdt = unixtime2matlab(posix);
    markers = {'$thms',...%UT hours minutes seconds
        '$thm',...%UT hours minutes
        '$tmdyhms',...%UT month/day/year hours minutes seconds
        '$tmdyhm',...%UT month/day/year hours minutes
        '$tmdhm'...%UT month/day hours minutes
        };
    datestrcell = {[datestr(curdt,'HH:MM:SS'),' UT'],[datestr(curdt,'HH:MM'),' UT'],...
        [datestr(curdt,'mm/dd/yyyy HH:MM:SS'),' UT'],[datestr(curdt,'mm/dd/yyyy HH:MM'),' UT'],...
        [datestr(curdt,'mm/dd HH:MM'),' UT']};
    for imark =1:length(markers)
        strout=strrep(strout,markers{imark},datestrcell{imark});
    end   
end
