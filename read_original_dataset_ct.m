function [ct,Width_ct, Height_ct, Zcnt_ct,sp1,sp2,sp3] = read_original_dataset_ct(dataset)

str1 = './Data/';

str3 = '/rescalect-part1.mat';
pathname_ct = sprintf(strcat(str1,dataset,str3));
load(pathname_ct)

str3 = '/rescalect-part2.mat';
pathname_ct = sprintf(strcat(str1,dataset,str3));
load(pathname_ct)

str3 = '/rescalect-part3.mat';
pathname_ct = sprintf(strcat(str1,dataset,str3));
load(pathname_ct)


ct = cat(3,rescalect1,rescalect2,rescalect3);


Width_ct = double(datahead.Size(1));
Height_ct = double(datahead.Size(2));
Zcnt_ct = double(datahead.Size(3));
sp1 = double(datahead.VoxelSpacing(1));
sp2 = double(datahead.VoxelSpacing(2));
sp3 = double(datahead.VoxelSpacing(3));