

clear;
clc;

File=dir('process*.csv');


for m=1:length(File)


Data = csvread([File(m).name]);
Size = 256;
Data = Data(2:end,:);

Prediction = reshape(Data(1:(Size^2),:),Size,Size,[]);
Image      = reshape(Data((1+Size^2):end,:),Size,Size,[]);

close all;



Prediction = Prediction(:,:,2:1:end);
Image      = Image(:,:,2:1:end);





figure(1);set(1,'Position',[100,100,800,400],'Color','w')

for i=1:size(Image,3)
    i
    subplot(1,2,1)
    imagesc(Image(:,:,i)'); axis off; colormap(gray);title('Input','fontsize',20,'Fontname','Comic sans ms')

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

% saveas(double(Image(:,:,1)),'budding.jpg')



