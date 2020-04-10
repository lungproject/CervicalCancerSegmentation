function tempnewphi2 = Refinesegment4(newphi)
tempnewphi2 = zeros(size(newphi));
se = ones(3,3);
% se = strel('disk',2);
for slice = 1:size(newphi,3)

  img =  newphi(:,:,slice);
  tempimg = padarray(img,[1 1],0,'pre');
  tempimg = padarray(tempimg,[1 1],0,'post');
   tempimg = medfilt2(tempimg,[3,3]);
    tempimg = imerode(tempimg,se);
   tempimg = imdilate(tempimg,se);
     


  
 

  tempimg2 = tempimg(2:end-1,2:end-1);
  tempnewphi2 (:,:,slice) = tempimg2;
end

%

    [L,num] = bwlabeln(tempnewphi2,6);
    % ���������Ĳ��ֱض������������Ĳ���
    count = length(L(L==1));
    index = 1;
    for i = 2:num
        if length(L(L==i)) > count
            count = length(L(L==i));
            index = i;
        end
    end
    % ���������ֵ�mask��Ϊ0
    tempnewphi2(find(L~=index)) = 0;
% %     dif = tempnewphi - tempnewphi2;

end
