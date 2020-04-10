
function [magImage] = magnify3(Image, spacing1,spacing2,dims1,dims2)

%%spacing1, dims1: the initial image space and dims
%%spacing2, dims2: the target image space and dims

k1 = floor(spacing1(1)/spacing2(1)*dims1(1));
k2 = floor(spacing1(2)/spacing2(2)*dims1(2));
% k3 = floor(spacing1(3)/spacing2(3)*dims1(3));
k3 = round(spacing1(3)/spacing2(3)*dims1(3));
if mod(abs(k1-dims2(1)),2)~=0
    k1 = k1+1;
end
if mod(abs(k2-dims2(2)),2)~=0
    k2 = k2+1;
end

if k3==dims1(3)%spacing2(3)==spacing1(3)
    for k = 1:k3
        tempImage = Image(:,:,k);
        magtempImage = imresize(tempImage,[k1 k2],'nearest');
        if dims2(1)<k1&&dims2(2)<k2
            magtempImage = magtempImage(ceil((k1-dims2(1))/2)+1:ceil((k1-dims2(1))/2)+dims2(1),...
            ceil((k2-dims2(2))/2)+1:ceil((k2-dims2(2))/2)+dims2(2));    
            magImage(:,:,k) = magtempImage;
        else
            magtempImage = padarray(magtempImage,[(k1-dims2(1))/2 (k2-dims2(2))/2],'replicate','both');%(:,:,k)
            magImage(:,:,k) = magtempImage;
        end
    end
else
    error('this function only aims at magnifying images without changing slices');
end
%     for k = 1:k3
%         tempmagImage(:,:,k) = imresize(Image(:,:,k),[k1 k2],'nearest');
%     end
%     [r2,c2,p2] = size(magImage);
%     tempmagImage2 = zeros(k1,k2,k3);
%     for i = 1:r2
%        tempImage = magImage(i,:,:);
%        tempImage2 = shiftdim(tempImage,1);
% %        tempImage2 = tempImage2';
%        magtemp = imresize(tempImage2,[c2 k3 ],'nearest');
% %        magtemp = magtemp';
%        magtemp = reshape(magtemp,[1,c2,round(k3)]);
%        tempmagImage2(i,:,:) = magtemp;
%     end
%     tempmagImage = tempmagImage2;
% if dims2(1)<k1
%     magImage = tempmagImage(ceil((k1-dims2(1))/2)+1:ceil((k1-dims2(1))/2)+dims2(1),...
%         ceil((k2-dims2(2))/2)+1:ceil((k2-dims2(2))/2)+dims2(2),ceil((k3-dims2(3))/2)+1:ceil((k3-dims2(3))/2)+dims2(3));   
% else
%     for k = 1:k3
%         magImage(:,:,k) = padarray(tempmagImage(:,:,k),[dims2(1) dims2(2)],'replicate','both');
%     end
% end


