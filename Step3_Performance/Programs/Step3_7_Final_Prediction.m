clear;
clc;

load('../Result/Output.mat')

% index for frame
for i=1:length(Output)

Image = Output(i).Image;
Prediction = Output(i).Prediction;
ROIs  = Output(i).ROIs;
centroids = Output(i).centroids;

close all;


figure(1)
set(1,'Position',[100,100,600,300],'color','w')

subplot(121);
imagesc(Image); axis off; colormap(gray);freezeColors;
title('Input')

subplot(122);
imagesc(Prediction); axis off; colormap(gray);freezeColors;
title('Prediction')


subplot(121);

% 2. centroids
hold on
plot(centroids(:,1), centroids(:,2), 'w+','markersize',5,'linewidth',1)
hold off

% 3. ROIs
Colors = jet(length(ROIs));
for j=1:length(ROIs)
    patch('XData',ROIs(j).ConvexHull(:,1),'YData',ROIs(j).ConvexHull(:,2),'facecolor','none','edgecolor',Colors(j,:),'linewidth',1.5,'edgealpha',0.57)
end



saveas(1,strcat('../Result/',num2str(i),'.png'));

end


disp('Segmentation Done!')


