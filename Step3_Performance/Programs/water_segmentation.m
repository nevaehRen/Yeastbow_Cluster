function bw3 = water_segmentation(bw,Level,CellSize)


bw2 = ~bwareaopen(~bw, CellSize);
% imshow(bw2)

D = -bwdist(~bw);
% imshow(D,[])


Ld = watershed(D);
% imshow(label2rgb(Ld))


bw2 = bw;
bw2(Ld == 0) = 0;
% imshow(bw2)


mask = imextendedmin(D,Level);
% imshowpair(bw,mask,'blend')


D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = bw;
bw3(Ld2 == 0) = 0;
% imshow(bw3)
 








