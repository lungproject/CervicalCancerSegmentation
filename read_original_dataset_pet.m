function [pet,Width_pet, Height_pet, Zcnt_pet,sp1,sp2,sp3] = read_original_dataset_pet(dataset)

str1 = './Data/';

str3 = '/suvpetnoc.mat';
pathname_pet = sprintf(strcat(str1,dataset,str3));

load(pathname_pet)
pet = suv;

Width_pet = double(datahead.Size(1));
Height_pet = double(datahead.Size(2));
Zcnt_pet = double(datahead.Size(3));
sp1 = double(datahead.VoxelSpacing(1));
sp2 = double(datahead.VoxelSpacing(2));
sp3 = double(datahead.VoxelSpacing(3));