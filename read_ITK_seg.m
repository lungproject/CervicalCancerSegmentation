function Cervixmask  = read_ITK_seg (dataset)

str1 = './Data/';

str3 = '/RTR.mha';
info =mha_read_header(strcat(str1,dataset,str3));
Cervixmask = mha_read_volume(info);
Cervixmask = transposeseq(Cervixmask);
