function [xrange,yrange,zrange]= Getregion(Segmentation)

    draw=0;
    [x1,y1,z1] = ind2sub(size(Segmentation),find(Segmentation~=0));
    xrange = max(min(x1)-5,1):min(max(x1)+5,size(Segmentation,1));
    yrange = max(min(y1)-5,1):min(max(y1)+5,size(Segmentation,2));
    
    zrange = max(min(z1)-2,1):min(max(z1)+2,size(Segmentation,3));

