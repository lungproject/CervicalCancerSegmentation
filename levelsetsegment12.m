function [newphi,boundary] = levelsetsegment12(initialLSF,FulcutImage,c0,timestep,iter,sigma,lamda)
%%加入梯度值*灰度值的影响
%%采用tanh(ctan<x,y>)夹角接近九十度时乘的很小
%%在ZLS边缘  高斯滤波连续化
%%加入CV模型 两项乘积

%%连续计算
if nargin<7
    lamda = 0.5;
    if nargin<6
        sigma = 0.5;
        if nargin<5
           iter =85;
           if nargin<4
               timestep =0.1;
           end
        end
    end
end
display(['iter=',num2str(iter)]);
phi = initialLSF;

   [fx,fy,fz] = gradient(FulcutImage);
   amplivect = sqrt(fx.^2 + fy.^2 + fz.^2);
   amplivect = (amplivect -min(amplivect(:)))/(max(amplivect(:))-min(amplivect(:)));
   norminten = (FulcutImage - min(FulcutImage(:)))/(max(FulcutImage(:))-min(FulcutImage(:)));
   amplivect = norminten.*amplivect;
   
for k = 1:iter
    

    mask2 = Gaussian3D(ceil(6*sigma),sigma,phi);
    boundary0 =  Dirac(mask2, 1.5);
    boundary = boundary0;
    boundary(boundary0<0)=0;
    if length(find(boundary-boundary0))
        nouse = SliceBrowser(boundary,'b');
    end
    boundary(find(boundary))=1;

   
   [phi_x,phi_y,phi_z] = gradient(mask2);
   term1 = (phi_x.*fx + phi_y.*fy + phi_z.*fz)./(sqrt(phi_x.^2 + phi_y.^2 + phi_z.^2) .* sqrt(fx.^2 + fy.^2 + fz.^2)+eps);
   term1 = tanh(cot(acos(term1)));
%    term1(sqrt(fx.^2 + fy.^2 + fz.^2)<0.2|sqrt(phi_x.^2 + phi_y.^2 + phi_z.^2)<0.2)=0;
%    term2 = -term1.*amplivect.*boundary;
   term2 = term1.*boundary;
%    phi = phi + timestep * term2;
    force_image = 0;
    inidx = find(phi>=0); % frontground index
    outidx = find(phi<0); % background index
     % initial image force for each layer 
    c1 = sum(sum(sum(FulcutImage.*Heaviside(phi))))/(length(inidx)+eps); % average inside of Phi0
    c2 = sum(sum(sum(FulcutImage.*(1-Heaviside(phi)))))/(length(outidx)+eps); % verage outside of Phi0
    force_image=-lamda*(FulcutImage-c1).^2+ (FulcutImage-c2).^2+force_image; 
%     force = 1/force_image;
    force = force_image.*boundary;
    phi = phi + timestep.*(force.*term2);

end
        newphi = zeros(size(phi));
        newphi(phi>=0)=1;
        newphi = Refinesegment3(newphi);
        boundary = bwperim(newphi,4);
%         [dx,dy,dz]=gradient(newphi);
%         boundary = newphi.*(abs(dx)+abs(dy)+abs(dz));
%         boundary(boundary~=0)=1;
%         nouse = SliceBrowser(boundary,'b');
        
%         slice_outline = bwperim(newphi,4);
%          maskpetv = FulcutImage;
%          maskpetv(slice_outline) = 1.1 * max(maskpetv(:));
%          nouse = SliceBrowser(maskpetv,num2str(k));

            
%         for slice = 1:size(newphi,3)
%             img = newphi(:,:,slice);
%             img = imerode(img,ones(3,3));
% %             img = medfilt2(img);
%             img = imfill(img);
%             if sum(img(:))
%                 img = ConnectRegion(img);
%             end
%             img = imdilate(img,ones(3,3));
%             newphi(:,:,slice)=img;
%             
%         end
%         newphi = ConnectRegion(newphi);

% newphi = Refinesegment3(newphi);

function f = Dirac(x, sigma)
f=(1/2/sigma)*(1+cos(pi*x/sigma));
b = (x<=sigma) & (x>=-sigma);
f = f.*b;
