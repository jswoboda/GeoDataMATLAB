function [X,Y,Z,P] = reshapegen(coords,p)

[xvec,~,icx] = unique(coords(:,1));
[yvec,~,icy] = unique(coords(:,2));
[zvec,~,icz] = unique(coords(:,3));

[X,Y,Z] = meshgrid(xvec,yvec,zvec);
P = zeros(size(X));
linearInd = sub2ind(size(X), icy,icx,icz);
P(linearInd) = p(:);



