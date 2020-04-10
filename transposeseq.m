function out = transposeseq(in)
out = zeros(size(in));
in(in~=0)=1;
% for slice = 1:size(in,3)
%     out(:,:,slice) = in(:,:,size(in,3)-slice+1)';
% end
for slice = 1:size(in,3)
    temp = in(:,:,slice);
    temp = imfill(temp,'holes');
    out(:,:,slice) = temp';
end
        