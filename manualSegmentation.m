clear
close all
dataset = 'PA0';
[ct,Width_ct, Height_ct, Zcnt_ct,sp1ct,sp2ct,sp3ct] = read_original_dataset_ct(dataset);
[pet,Width_pet, Height_pet, Zcnt_pet,sp1pet,sp2pet,sp3pet] = read_original_dataset_pet(dataset);
Cervixmask = read_ITK_seg (dataset);

[sRangex,sRangey,sRangez] = Getregion(Cervixmask);

Cervixmask = Cervixmask(sRangex,sRangey,sRangez);

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

nRangex = floor((sRangex(1)-3)*size(ct,1)/size(pet,1)):ceil((sRangex(end)+3)*size(ct,1)/size(pet,1));
nRangey = floor((sRangey(1)-3)*size(ct,2)/size(pet,2)):ceil((sRangey(end)+3)*size(ct,2)/size(pet,2));
nRangez=sRangez;

allmask = zeros(size(pet));
allmask(sRangex,sRangey,sRangez)=tumormask;
magallmask = magnify3(allmask, [sp1pet,sp2pet,sp3pet],[sp1ct sp2ct sp3ct],[Width_pet Height_pet Zcnt_pet],[Width_ct Height_ct Zcnt_ct]);
cttumormask = magallmask(nRangex,nRangey,nRangez); 
maskct = ct(nRangex,nRangey,nRangez); 
cttumormask = Refinesegment4(cttumormask);
imshow3( maskct,cttumormask,'Name','cttumormask' ,'colormap','gray' );

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
