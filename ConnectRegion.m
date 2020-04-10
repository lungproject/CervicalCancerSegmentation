function vol = ConnectRegion(img,patch,flag)
%%flag = 1 取像素数最多的部分
%%flag = n 取像素做多的n个区域

if nargin<4
    
    if nargin<3
        if nargin<2
            if ndims(img)==3
               patch = 6;
        else if ndims(img)==2
            patch = 4;
            end
            end
        end
       flag = 1;
    end

end

vol = zeros(size(img));
[L,num] = bwlabeln(img,patch);
Lnum = zeros(num,1);
for i = 1:num
    Lnum(i) = length(find(L==i));
end
[~,indexsort] = sort(Lnum,'descend');

for i = 1:flag
   index = indexsort(i);
   vol(find(L==index)) = 1;
end
