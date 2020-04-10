clear
close all
dataset = 'PA5';%PA0 PA5
[ct,Width_ct, Height_ct, Zcnt_ct,sp1ct,sp2ct,sp3ct] = read_original_dataset_ct(dataset);
[pet,Width_pet, Height_pet, Zcnt_pet,sp1pet,sp2pet,sp3pet] = read_original_dataset_pet(dataset);

maskpet = pet;%(:,:,nRangez);
sumz=[];
for zr = 2:size(maskpet,3)
 temp = maskpet(:,:,zr);
 sumz(zr,1) = calculatePeak(temp,5);
end
sumz(round(length(sumz)/2):end)=0;
thre=0.38; 
sRangez = Getrange (sumz,thre);

maskpet = pet(:,:,sRangez);
sumx = [];
for xr = 1:size(maskpet,1)
 temp = maskpet(xr,:,:);
 sumx(xr,1) = max(temp(:));
end
sumy = [];
for yr = 1:size(maskpet,2)
 temp = maskpet(:,yr,:);
 sumy(yr,1) = max(temp(:));
end

thre=0.3;
sRangex = Getrange (sumx,thre);
sRangex = sRangex(1)-5:sRangex(end)+5;
sRangey = Getrange (sumy,thre);
sRangey = sRangey(1)-5:sRangey(end)+5;
sRangez = max(sRangez(1)-2,1):sRangez(end)+2;

nRangex = floor((sRangex(1)-3)*size(ct,1)/size(pet,1)):ceil((sRangex(end)+3)*size(ct,1)/size(pet,1));
nRangey = floor((sRangey(1)-3)*size(ct,2)/size(pet,2)):ceil((sRangey(end)+3)*size(ct,2)/size(pet,2));
nRangez=sRangez;

WindowWidth = 110;
WindowLevel = 24;
low = WindowLevel - WindowWidth/2 ;
high = WindowLevel + WindowWidth/2 ;
maskct0 = ct(nRangex,nRangey,nRangez);
maskct = ct(nRangex,nRangey,nRangez);
maskct(maskct<low) = 0;%low;
maskct(maskct>high) = 0;%high;
magpet = magnify3(pet, [sp1pet,sp2pet,sp3pet],[sp1ct sp2ct sp3ct],[Width_pet Height_pet Zcnt_pet],[Width_ct Height_ct Zcnt_ct]);
maskpet = double(magpet(nRangex,nRangey,nRangez));  %rea;
sigma = 2;%10
filsize = ceil(6*sigma);

smoothmaskpet = Gaussian3D(filsize,sigma,maskpet);
smoothmaskct = medfilt3d(maskct,1,filsize);%Gaussian3D(filsize,sigma,maskct);
cutpet = smoothmaskpet;
cutct = smoothmaskct;
cutpet = (cutpet - min(cutpet(:)))/(max(cutpet(:))-min(cutpet(:)));
cutct = (cutct - min(cutct(:)))/(max(cutct(:))-min(cutct(:)));
%%%FCM
clusno = 4;
[center,U,obj_fcn] = fcm([cutct(:) cutpet(:) cutpet(:).*cutct(:)],clusno);% cutct(:)-cutpet(:)
[~,classindex] = max(U',[],2);

attributy = zeros(clusno,1);
class = reshape(classindex,size(cutpet));
% nouse = SliceBrowser(class,'c');

maxcenterindex = 1;
center2 = zeros(size(center));
location = zeros(clusno,1);
for no = 1:clusno
    temp = class;
    temp(class~=no)=0;
    temp(class==no)=1;
    se = ones(5,5,5);
    temp = imerode(temp,se);
    temp = ConnectRegion(temp,18);%20 (class3,18,2);
    temp = imdilate(temp,se);

    tempct = temp.*cutct;
    temppet = temp.*cutpet;
    temppetct = temp.*cutpet.*cutct;
    templocation = zeros(length(find(temp)),3);
    [templocation(:,1) templocation(:,2) templocation(:,3)] = ind2sub(size(temp),find(temp));
    center2(no,:) = [mean(tempct(tempct~=0)) mean(temppet(temppet~=0)) mean(temppet(temppetct~=0))];
    location(no,:) = mean(templocation(:,1));
end
[maxct,ctindex] = max(center2(:,1));
[maxpet,petindex] = max(center2(:,2));
[maxpetct,petctindex] = max(center2(:,3));
[maxsum,sumpetctindex] = max(sum(center2,2));
[maxsum,sumindex] = max(sum(center2(:,1:2),2));



if ctindex == petindex
    maxcenterindex = petindex;
    display(' definitely');
else

   if location(sumindex)>=location(ctindex)|| location(sumindex)>=location(petindex)
             maxcenterindex = sumindex;
        else
           if location(ctindex)>location(petindex)
            maxcenterindex = ctindex;
            else 
            maxcenterindex = petindex;
           end
   end
end
        
class2 = class;
class2(class~=maxcenterindex)=0;

for slice = 1:size(class2,3)
  img = class2(:,:,slice);
  img = imfill(img,'holes');
  class2(:,:,slice)=img;
end

se = ones(5,5,5);%9;54->6 19;55->8  22,23,62;7;66-> 3
class2 = imerode(class2,se); 
class2 = ConnectRegion(class2,18);%20 (class3,18,2);
class2 = imdilate(class2,se);


magCervixmask = padarray(class2,[nRangex(1)-1 nRangey(1)-1 nRangez(1)-1],0,'pre');
magCervixmask = padarray(magCervixmask,[Width_ct-nRangex(end) Height_ct-nRangey(end) Zcnt_ct-nRangez(end)],0,'post');
shrinkCervixmask = shrink3(magCervixmask, [sp1ct sp2ct sp3ct],[sp1pet,sp2pet,sp3pet],[Width_ct Height_ct Zcnt_ct],[Width_pet Height_pet Zcnt_pet]);
Cervixmask = shrinkCervixmask(sRangex,sRangey,sRangez);

shrinkct = shrink3(ct, [sp1ct sp2ct sp3ct],[sp1pet,sp2pet,sp3pet],[Width_ct Height_ct Zcnt_ct],[Width_pet Height_pet Zcnt_pet]);
maskct3 = shrinkct(sRangex,sRangey,sRangez);%.*mask;
maskpet3 = pet(sRangex,sRangey,sRangez);%.*mask;

sigma = 0.5;%10
filsize = ceil(6*sigma);
smoothmaskpet3 = Gaussian3D(filsize,sigma,maskpet3);
cutpet3 = smoothmaskpet3;
tempcutpet3 = cutpet3;
tempmaskpet3 = maskpet3;
Cervix = cutpet3.*Cervixmask;

%%自动找零水平集
thre = 0.42;%0.5; %%PA3 0.7 PA5 0.5
[seedobjectmap] = findobjectseed(Cervix,thre);  

c0=2;% 2  levelsegement12 -2  levelsegment11 2
newphi = zeros(size(cutpet3,1),size(cutpet3,2),size(cutpet3,3));
initialLSF = seedobjectmap;
initialLSF (initialLSF~=0) = c0;
initialLSF (initialLSF==0) = -c0;
iter = 250;
newphi = levelsetsegment12(initialLSF,tempcutpet3,c0,0.5,iter,sigma);%cutpet3

tumormask = newphi;
tumormask = Refinesegment3(tumormask);

imshow3( maskpet3, tumormask,'Name','tumormask' ,'colormap','jet' );


allmask = zeros(size(pet));
allmask(sRangex,sRangey,sRangez)=tumormask;
magallmask = magnify3(allmask, [sp1pet,sp2pet,sp3pet],[sp1ct sp2ct sp3ct],[Width_pet Height_pet Zcnt_pet],[Width_ct Height_ct Zcnt_ct]);
cttumormask = magallmask(nRangex,nRangey,nRangez); cttumormask(maskct<0)=0;
cttumormask = Refinesegment4(cttumormask);
imshow3( maskct0,cttumormask,'Name','cttumormask' ,'colormap','gray' );

petnodule = cutpet3.*tumormask;
petnoduletemp = petnodule;
petnoduletemp(tumormask==0) = nan;
nSep = 2; tolX = 0.001;
[IDX, threh, sep] = otsu(petnoduletemp,nSep);
petmask_part1 = zeros(size(IDX));
petmask_part1(IDX==1)=1;
petmask_part2 = zeros(size(IDX));
petmask_part2(IDX==2)=1;
petnodule_part1 = petmask_part1.*petnodule;
petnodule_part2 = petmask_part2.*petnodule;
meanvpart1 = mean(petnodule_part1(petmask_part1~=0));
meanvpart2 = mean(petnodule_part2(petmask_part2~=0));
if meanvpart1>meanvpart2
   petmask_highpart = petmask_part1;
else
   petmask_highpart = petmask_part2;
end
for f = 1:nSep
    Img = petmask_highpart;
    [L,numsep] = bwlabeln(Img,6);
    count = length(L(L==1));
    index = 1;
    for i = 2:numsep
        if length(L(L==i)) > count
            count = length(L(L==i));
            index = i;
        end
    end
    Img(find(L~=index)) = 0;
    petmask_highpart = Img;
end
petmask_highpart =Refinesegment5(petmask_highpart);

petmask_lowpart = tumormask;
petmask_lowpart(petmask_highpart~=0)=0;
petmask_lowpart =Refinesegment5(petmask_lowpart);

imshow3( maskpet3, petmask_highpart,'name','PEThigh' ,'colormap','jet' );
imshow3( maskpet3, petmask_lowpart,'name','PETlow' ,'colormap','jet' );

allmask = zeros(size(pet));
allmask(sRangex,sRangey,sRangez)=petmask_highpart;
ctmask_highpart = magnify3(allmask, [sp1pet,sp2pet,sp3pet],[sp1ct sp2ct sp3ct],[Width_pet Height_pet Zcnt_pet],[Width_ct Height_ct Zcnt_ct]);
imshow3( maskct,ctmask_highpart(nRangex,nRangey,nRangez),'Name','ctmask_highpart' ,'colormap','gray' );

allmask = zeros(size(pet));
allmask(sRangex,sRangey,sRangez)=petmask_lowpart;
ctmask_lowpart = magnify3(allmask, [sp1pet,sp2pet,sp3pet],[sp1ct sp2ct sp3ct],[Width_pet Height_pet Zcnt_pet],[Width_ct Height_ct Zcnt_ct]);
imshow3( maskct,ctmask_lowpart(nRangex,nRangey,nRangez),'Name','ctmask_lowpart' ,'colormap','gray' );
