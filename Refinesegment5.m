function tempnewphi2 = Refinesegment5(newphi)

tempnewphi2 = zeros(size(newphi));
se = strel('disk',1);
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

[L,num] = bwlabeln(tempnewphi2,6);
for i=1:num
    counts(i,1) = length(L(L==i));
    if counts(i,1)<=4
        L(L==i)=0;
    end
end
% ind = find(counts<=4);

tempnewphi2(L==0)=0;

end
