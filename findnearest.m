function flattenedindex = findnearest(array,searchval)
[~,flattenedindex] = min(abs(array-searchval));
end %function