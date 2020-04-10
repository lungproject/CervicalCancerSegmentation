function tempnewphi2 = Refinesegment3(newphi)

% tempnewphi = newphi;
% se = ones(3,3,3);
% tempnewphi = padarray(tempnewphi,[1 1 1],0,'pre');
% tempnewphi = padarray(tempnewphi,[1 1 1],0,'post');
% 
% tempnewphi = imdilate(tempnewphi,se);
% tempnewphi = imerode(tempnewphi,se);
% 
% tempnewphi = imerode(tempnewphi,se);
% tempnewphi = imdilate(tempnewphi,se);
% 
% tempnewphi2 = tempnewphi(2:end-1,2:end-1,2:end-1);
tempnewphi2 = zeros(size(newphi));
se = ones(3,3);
% se = strel('disk',3);
for slice = 1:size(newphi,3)

  img =  newphi(:,:,slice);
  tempimg = padarray(img,[1 1],0,'pre');
  tempimg = padarray(tempimg,[1 1],0,'post');
  
  tempimg = medfilt2(tempimg,[3,3]);
     
  tempimg = imdilate(tempimg,se);
  tempimg = imfill(tempimg,'holes');
  tempimg = imerode(tempimg,se);

  
  
%   tempimg = imerode(tempimg,se);
%   tempimg = imdilate(tempimg,se);
  
%   tempimg = imdilate(tempimg,se);
%   tempimg = imerode(tempimg,se);


  tempimg2 = tempimg(2:end-1,2:end-1);
  tempnewphi2 (:,:,slice) = tempimg2;
end

% tempnewphi2 = zeros(size(tempnewphi));
% dif = tempnewphi - tempnewphi2;
% panel = 1;
% while(sum(dif(:)))
%     tempnewphi2 = tempnewphi;
%     for slice = 1:size(tempnewphi,3)     
%         
%        Img = tempnewphi(:,:,slice);
%        if length(find(Img))~=0 
%           Img = medfilt2(Img,[3 3]);%ConnectRegion(Img);
%        end
%        tempnewphi(:,:,slice)= Img; 
% 
% 
% %        slice_outline = double(bwperim(Img,4));
% %        padImg = padarray(Img,[panel panel],0,'both');
% %        padslice_outline = padarray(slice_outline,[panel panel],0,'both');
% %        
% %        padImg2 = shiftdim(padImg,1);
% %        padslice_outline2 = shiftdim(padslice_outline,1);
% %        exindex = find(padslice_outline2==0);
% %        i(exindex)=[];j(exindex)=[];
% %        countcoccr = zeros(length(i),8);
% %        for count = 1:length(i)
% %                 feature = [];
% %                 newVoxel = double(padImg((i(count)-panel):(i(count)+panel),(j(count)-panel):(j(count)+panel)));
% %                 newVoxel(2,2) = 2;
% %                 offset = [0 1;-1 1;-1 0;-1 -1;0 -1;1 -1;1 0; 1 1];
% %                 coccurrma =graycomatrix2s(newVoxel,'NumLevel',3,'Offset',offset);
% %     %             if i(count)==21&&j(count)==23&&slice==6
% %     %                 coccurrma
% %     %             end
% %                 for no = 1:8
% %                    countcoccr(count,no) = coccurrma(3,2,no);
% %                 end
% %        end  
% % 
% %        partcoccr1 = countcoccr;
% %        partcoccr1(:,[1 5])=[];
% %        sumpartcoccr1 = sum(partcoccr1,2);
% % 
% %        partcoccr2 = countcoccr;
% %        partcoccr2(:,[3 7])=[];
% %        sumpartcoccr2 = sum(partcoccr2,2);
% % 
% %        index = find(sumpartcoccr1<2|sumpartcoccr2<2);
% %        padImg(i(index),j(index))=0;
% %        Img = padImg(panel+1:size(padImg,1)-panel,panel+1:size(padImg,2)-panel);
% %        tempnewphi(:,:,slice)= Img; 
%     end

    [L,num] = bwlabeln(tempnewphi2,6);
    % 属于肿瘤的部分必定是像素数最多的部分
    count = length(L(L==1));
    index = 1;
    for i = 2:num
        if length(L(L==i)) > count
            count = length(L(L==i));
            index = i;
        end
    end
    % 将其他部分的mask置为0
    tempnewphi2(find(L~=index)) = 0;
% %     dif = tempnewphi - tempnewphi2;

end
