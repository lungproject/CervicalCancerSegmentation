function [shrinkImage] = shrink3(Image, spacing1,spacing2,dims1,dims2)

%%spacing1,dims1: the initial image space and dim
%%spacing2,dims2: the target image space and dim

k1 = floor(spacing2(1)/spacing1(1)*dims2(1));
k2 = floor(spacing2(2)/spacing1(2)*dims2(2));
% k3 = floor(spacing2(3)/spacing1(3)*dims2(3));
k3 = round(spacing2(3)/spacing1(3)*dims2(3));

if k3==dims2(3)%spacing2(3)==spacing1(3)

    for k = 1:k3
        tempImage = Image(:,:,k);
        wnew = (k1-dims1(1))/2;
        hnew = (k2-dims1(2))/2;
        if wnew<0
            wnew=0;
        end
        if hnew < 0 ;
            hnew = 0;
        end
        tempImage = padarray(tempImage,[wnew hnew],'replicate','both');
        shrinktempImage = imresize(tempImage,[dims2(1) dims2(2)],'nearest');
        shrinkImage(:,:,k) = shrinktempImage;
    end
    
else
    error('this function only aims at shrinking images without changing slices');
end



