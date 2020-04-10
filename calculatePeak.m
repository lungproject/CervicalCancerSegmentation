function P = calculatePeak(Img,distance)
  
  if size(Img,3)==1
      [peaks indexrow]= max(Img);
      [peak nouse] = max(peaks);
      cs = find(peaks==peak);
      rs = indexrow(peaks==peak);
      r2s = rs - distance;
      c2s = cs - distance;
      r3s = rs + distance;
      c3s = cs + distance;
      P = zeros(1,length(rs));
      for i = 1:length(rs)
           r2 = r2s(i);
           c2 = c2s(i);
           r3 = r3s(i);
           c3 = c3s(i);
           [nRow nCol] = size(Img);
%            outsideBounds = find(c2 < 1 | c2 > nCol | r2 < 1 | r2 > nRow |  ...
%                            c3 < 1 | c3 > nCol | r3 < 1 | r3 > nRow );
%            r2(outsideBounds) = []; 
%            c2(outsideBounds) = []; 
%            r3(outsideBounds) = []; 
%            c3(outsideBounds) = []; 
           [tempr,tempc] = meshgrid(r2:r3,c2:c3);
           tempr = tempr(:);
           tempc = tempc(:);
           outsideBounds = find(tempc < 1 | tempc > nCol | tempr < 1 | tempr> nRow );
           tempr(outsideBounds) = []; 
           tempc(outsideBounds) = []; 
           index = tempr + (tempc - 1) * nRow ;
           v2 = Img(index);
           v2(isnan(v2))=[];
           P(i) = mean(v2(:));
      end
%           P = P/length(r);
  else
          s = size(Img);
          [r0,c0,w0] = meshgrid(1:s(1),1:s(2),1:s(3));
          r0 = r0(:);
          c0 = c0(:);
          w0 = w0(:);
          for i = 1:s(3)
            Img2(:,:,i) = shiftdim(Img(:,:,i),1);
          end
          Img2 = Img2(:);
          [peak,nouse] = max(Img2);
          index = find(Img2==peak);
          rs = r0(index)';
          cs = c0(index)';
          ws = w0(index)';
          r2s = rs - distance;
          c2s = cs - distance;
          w2s = ws - distance;
          r3s = rs + distance;
          c3s = cs + distance;
          w3s = ws + distance;
          P = zeros(1,length(rs));
      for i = 1:length(rs)
           r2 = r2s(i);
           c2 = c2s(i);
           w2 = w2s(i);
           r3 = r3s(i);
           c3 = c3s(i);
           w3 = w3s(i);
          [nRow nCol nWidth] = size(Img);
            % Determine locations where subscripts outside the image boundary
%           outsideBounds = find(c2 < 1 | c2 > nCol | r2 < 1 | r2 > nRow | w2 < 1 | w2 > nWidth |  ...
%                                  c3 < 1 | c3 > nCol | r3 < 1 | r3 > nRow | w3 < 1 | w3 > nWidth);
%            r2(outsideBounds) = []; 
%            c2(outsideBounds) = []; 
%            w2(outsideBounds) = []; 
%            r3(outsideBounds) = []; 
%            c3(outsideBounds) = []; 
%            w3(outsideBounds) = []; 
           [tempr,tempc,tempw] = meshgrid(r2:r3,c2:c3,w2:w3);
           tempr = tempr(:);
           tempc = tempc(:);
           tempw = tempw(:);
           outsideBounds = find(tempc < 1 | tempc > nCol | tempr < 1 | tempr > nRow | tempw < 1 | tempw > nWidth );
           tempr(outsideBounds) = []; 
           tempc(outsideBounds) = [];
           tempw(outsideBounds) = [];
           index = tempr + (tempc - 1) * nRow + (tempw - 1) * nRow * nCol;
           v2 = Img(index);
           v2(isnan(v2))=[];
           P(i) = mean(v2(:));                  
      end
%          P = P/length(r);
  end