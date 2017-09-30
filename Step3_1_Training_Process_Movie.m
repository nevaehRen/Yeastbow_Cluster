
function Step3_1_Training_Process_Movie()

clear;clc;

File=dir('process*.mat');


for m=1:length(File)


load([File(m).name]);

Image      = reshape(Image,PatchSize,PatchSize,[]);
Prediction = double(reshape(Prediction,PatchSize,PatchSize,[]));

close all;




figure(1);set(1,'Position',[100,100,800,400],'Color','w')

for i=1:size(Prediction,3)
    i
    subplot(1,2,1)
    imagesc(Image); axis off; colormap(gray);title('Input','fontsize',20,'Fontname','Comic sans ms')

    subplot(1,2,2)
    imagesc(Prediction(:,:,i)'); axis off; colormap(gray);title('Output','fontsize',20,'Fontname','Comic sans ms')
    text(59,243,strcat('Epochs:', num2str(i),' (x100) steps '),'fontsize',15,'Fontname','Comic sans ms','color','w')

    figure(1)
    Gif([File(m).name(1:end-4),'.gif'],i)
end




M=getframe(gcf);
% M.cdata=imresize(M.cdata(:,:,:),[400,400]);
nn=frame2im(M);
[nn,cm]=rgb2ind(nn,256);

imwrite(nn,cm,[File(m).name(1:end-4),'.gif'],'gif','WriteMode','append','DelayTime',10)


close all;


end

end



function Gif(Name,i)

M=getframe(gcf);
% M.cdata=imresize(M.cdata(:,:,:),[400,400]);
nn=frame2im(M);
[nn,cm]=rgb2ind(nn,256);

if i==1
imwrite(nn,cm,Name,'gif','LoopCount',inf,'DelayTime',0.002);
else 
imwrite(nn,cm,Name,'gif','WriteMode','append','DelayTime',0.002)
end

end


