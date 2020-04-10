function outimg = medfilt3d(inimg,flag,scalar)
%MEDFILT3d 3-D median filtering.
%%flag = 1 : slice by slice,  pseudo 3D
%%flag = 2 : 3D

if nargin<3
   if nargin<2
       flag = 1;
   end
   
   if ndims(inimg)==2
       scalar = [3 3];
   else
       scalar = [1 1 1];
   end
else
    if length(scalar)==1
           if ndims(inimg)==2
                 scalar = [scalar scalar];
           else
                 scalar = [scalar scalar scalar];
           end
    end
   
end

outimg = zeros(size(inimg));
if ndims(inimg)==2
    outimg = medfilt2(inimg,scalar);
else
  m = scalar(1);n = scalar(2);p = scalar(3);
  if flag==2
    mnp = (2*m+1)*(2*n+1)*(2*p+1);
    middle = ceil(mnp/2);
    img = zeros(size(inimg,1)+2*m,size(inimg,2)+2*n,size(inimg,3)+2*p);
    for slice = 1:size(inimg,3)
       img(:,:,slice+p) = padarray(inimg(:,:,slice),[m n],'replicate','both');
    end
    if p>0
        img(:,:,1:p) = img(:,:,p+1);
        img(:,:,end-p+1:end) = img(:,:,end-p);
    end

    [nRow,nCol,nWidth] = size(img);
    [r,c,w] = meshgrid(m+1:nRow-m,n+1:nCol-n, p+1:nWidth-p);
    i = c(:);
    j = r(:);
    k = w(:);


%     img2 = zeros(nCol,nRow,nWidth);
%     for slice = 1:nWidth
%       img2(:,:,slice) = shiftdim(img(:,:,slice),1);
%     end
%     imgnorm = img2(:);
    imgnorm = img(:);
    newimg = zeros(size(inimg,1)*size(inimg,2)*size(inimg,3),mnp);
    count = 1;
    for nd = -n:1:n
          i2 = i + nd;
       for md =-m:1:m 
          j2 = j + md;
         for pd = -p:1:p
            k2 = k + pd;
            i2(i2<1) = 1;
            j2(j2<1) = 1;
            k2(k2<1) = 1;

            i2(i2>nRow)= nRow;
            j2(j2>nCol) = nCol;
            k2(k2>nWidth) = nWidth;
            index = i2  + (j2 -1) * nRow + (k2 - 1) * (nRow * nCol);
            newimg(:,count) = imgnorm(index);
            count = count + 1;
         end
       end
    end

    newimg = sort(newimg,2);
    outimg = reshape(newimg(:,middle),size(inimg,1),size(inimg,2),size(inimg,3));
  else
      for slice = 1:size(inimg,3)
          outimg(:,:,slice) = medfilt2(inimg(:,:,slice),scalar(1:2)); 
      end
  end

end





