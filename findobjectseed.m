function [seedobjectmap] = findobjectseed(tumor,threper)    
    
    seedobjectmap= zeros(size(tumor));
    tempseedbackmap = zeros(size(tumor)); 
    seedbackmap = zeros(size(tumor)); 
    
    [nRow nCol nWidth] = size(tumor);
    
    [seedobjectvalue,~] = max(tumor(:));
    thre = seedobjectvalue*threper;
    for i = 1:nWidth
       tumor2(:,:,i) = shiftdim(tumor(:,:,i),1);
    end

%     seedobjectindex = find(tumor2==seedobjectvalue);
%     seedobjectmap(tumor==seedobjectvalue)=1;
    seedobjectindex = find(tumor2>=thre);
    seedobjectmap(tumor>=thre)=1;

    
  