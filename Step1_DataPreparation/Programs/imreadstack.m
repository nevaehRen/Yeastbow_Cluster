%一次读取多帧tif图片
function f=imreadstack(imname)
info = imfinfo(imname);
num_images = numel(info);
f=zeros(info(1).Height,info(1).Width,num_images);
h=waitbar(0,'Reading Image, Please wait...');
for k = 1:num_images
    waitbar(k/num_images,h,'Reading Image, Please wait...');
    f(:,:,k) =imread(imname, k);
end
close(h);